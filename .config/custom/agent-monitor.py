#!/usr/bin/env python3
"""Display local command activity in tmux without changing execution permissions."""

import argparse
import errno
import fcntl
import json
import os
from pathlib import Path
import pty
import selectors
import shlex
import shutil
import signal
import subprocess
import sys
import tempfile
import time


STATE_DIR = Path(tempfile.gettempdir()) / f"agent-monitor-{os.getuid()}"
SCRIPT = Path(__file__).resolve()
SESSION = "agent-monitor"
COLORS = {31: (234, 74, 90), 32: (52, 208, 88), 33: (255, 234, 127), 36: (57, 197, 207)}


def prepare_state():
    STATE_DIR.mkdir(mode=0o700, exist_ok=True)
    if STATE_DIR.is_symlink() or STATE_DIR.stat().st_uid != os.getuid():
        raise PermissionError(f"Unsafe monitoring directory: {STATE_DIR}")
    STATE_DIR.chmod(0o700)


def tmux(*args, check=True):
    return subprocess.run(
        ["tmux", "-S", str(STATE_DIR / "tmux.sock"), *args],
        check=check, capture_output=True, text=True,
    )


def ensure_session():
    with (STATE_DIR / "session.lock").open("a") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        if tmux("has-session", "-t", SESSION, check=False).returncode:
            tmux("-f", "/dev/null", "new-session", "-d", "-s", SESSION,
                 "-n", "Activity", sys.executable, str(SCRIPT), "watch")
            tmux("set-option", "-t", SESSION, "mouse", "on")
            tmux("set-option", "-t", SESSION, "status-right", "Agent Monitoring")
        if tmux("show-option", "-v", "-t", SESSION, "@overview-pane", check=False).returncode:
            overview = tmux("list-panes", "-t", f"{SESSION}:Activity", "-F", "#{pane_id}").stdout.splitlines()[0]
            tmux("set-option", "-t", SESSION, "@overview-pane", overview)
            tmux("select-pane", "-t", overview, "-T", "Activity")
            tmux("set-option", "-w", "-t", f"{SESSION}:Activity", "pane-border-status", "top")
            tmux("set-option", "-w", "-t", f"{SESSION}:Activity", "pane-border-format", " #{pane_title} ")


def layout_string(panes, width, height):
    def leaf(pane, w, h, x, y):
        return f"{w}x{h},{x},{y},{pane.lstrip('%')}"

    def column(items, w, x):
        if len(items) == 1:
            return leaf(items[0], w, height, x, 0)
        available = height - len(items) + 1
        cells = []
        y = 0
        for index, pane in enumerate(items):
            h = available // len(items) + (index < available % len(items))
            cells.append(leaf(pane, w, h, x, y))
            y += h + 1
        return f"{w}x{height},{x},0[" + ",".join(cells) + "]"

    if len(panes) == 1:
        layout = leaf(panes[0], width, height, 0, 0)
        order = panes
    else:
        groups = [[panes[0]], panes[1::2], panes[2::2]] if len(panes) > 2 else [[panes[0]], [panes[1]]]
        available = width - len(groups) + 1
        cells = []
        x = 0
        for index, group in enumerate(groups):
            w = available // len(groups) + (index < available % len(groups))
            cells.append(column(group, w, x))
            x += w + 1
        layout = f"{width}x{height},0,0{{" + ",".join(cells) + "}"
        order = [pane for group in groups for pane in group]
    checksum = 0
    for character in layout:
        checksum = (((checksum >> 1) + ((checksum & 1) << 15)) + ord(character)) & 0xffff
    return f"{checksum:04x},{layout}", order


def reflow_locked():
    overview = tmux("show-option", "-v", "-t", SESSION, "@overview-pane").stdout.strip()
    rows = tmux("list-panes", "-t", overview, "-F",
                "#{pane_id} #{pane_left} #{pane_top} #{window_width} #{window_height}").stdout.splitlines()
    panes = [row.split() for row in rows]
    width, height = map(int, panes[0][-2:])
    tasks = sorted((pane[0] for pane in panes if pane[0] != overview), key=lambda pane: int(pane[1:]))
    signature = [width, height, overview, tasks]
    saved = STATE_DIR / "layout.json"
    if saved.exists() and json.loads(saved.read_text()) == signature:
        return
    layout, order = layout_string([overview, *tasks], width, height)
    tmux("select-layout", "-t", overview, layout)
    positions = tmux("list-panes", "-t", overview, "-F",
                     "#{pane_id} #{pane_left} #{pane_top}").stdout.splitlines()
    actual = [row.split()[0] for row in sorted(positions, key=lambda row: tuple(map(int, row.split()[1:])))]
    for index, desired in enumerate(order):
        if actual[index] != desired:
            other = actual.index(desired)
            tmux("swap-pane", "-d", "-s", desired, "-t", actual[index])
            actual[index], actual[other] = actual[other], actual[index]
    saved.write_text(json.dumps(signature))


def reflow():
    with (STATE_DIR / "layout.lock").open("a") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        reflow_locked()


def add_task_pane(label, log_path):
    with (STATE_DIR / "layout.lock").open("a") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        overview = tmux("show-option", "-v", "-t", SESSION, "@overview-pane").stdout.strip()
        pane = tmux("split-window", "-d", "-h", "-P", "-F", "#{pane_id}", "-t", overview,
                    "tail", "-n", "+1", "-f", f"--pid={os.getpid()}", str(log_path)).stdout.strip()
        tmux("select-pane", "-t", pane, "-T", label)
        reflow_locked()
        return pane


def remove_task_pane(pane):
    with (STATE_DIR / "layout.lock").open("a") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        tmux("kill-pane", "-t", pane, check=False)
        reflow_locked()


def write_record(directory, record):
    temporary = directory / "state.tmp"
    temporary.write_text(json.dumps(record, ensure_ascii=False))
    temporary.replace(directory / "state.json")


def records():
    jobs = sorted(
        (json.loads(path.read_text()) for path in STATE_DIR.glob("*/state.json")),
        key=lambda record: record["started"], reverse=True,
    )
    for job in jobs:
        if job["status"] == "RUNNING" and not Path(f"/proc/{job['pid']}").exists():
            job["status"] = "INTERRUPTED"
    return jobs


def completed_color(job, now):
    exit_code = job.get("exit_code")
    color = (33 if job["status"] == "INTERRUPTED" or exit_code in (130, 143)
             else 32 if exit_code == 0 else 31)
    finished = job.get("finished")
    if finished is None or now - finished >= 5:
        return color
    progress = max(0, (now - finished) / 5)
    rgb = [round(start + (end - start) * progress)
           for start, end in zip(COLORS[36], COLORS[color])]
    return "38;2;" + ";".join(map(str, rgb))


def status(compact=False):
    jobs = records()
    now = time.time()
    columns, rows = shutil.get_terminal_size(fallback=(120, 40))
    active = [job for job in jobs if job["status"] == "RUNNING"]
    recent = sorted((job for job in jobs if job["status"] != "RUNNING"),
                    key=lambda job: job.get("finished") or job["started"], reverse=True)

    def display(line="", color=None):
        line = line.replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t")
        if compact and len(line) >= columns:
            line = line[:columns - 2] + "…"
        print(f"\033[{color}m{line}\033[0m" if color else line)

    if compact:
        operation_width = 25

        def operation_label(job):
            label = job['label'].replace('\n', '\\n').replace('\r', '\\r').replace('\t', '\\t')
            if len(label) > operation_width:
                label = label[:operation_width - 1] + '…'
            return label

        colors = {}
        lines = [f"Running: {len(active)} | Completed: {len(recent)}", "",
                 "RUNNING"]
        active_limit = min(len(active), max(0, (rows - 8) // 2))
        for job in active[:active_limit]:
            duration = now - job["started"]
            colors[len(lines)] = 36
            lines.append(f"{operation_label(job):{operation_width}} {duration:6.1f}s")
            lines.append(f"  {job['command']}")
        if len(active) > active_limit:
            lines.append(f"+ {len(active) - active_limit} more running")
        elif not active:
            colors[len(lines)] = 32
            lines.append("No running tasks.")
        lines.extend(["", "COMPLETED"])
        recent_limit = max(0, rows - len(lines) - 1)
        if len(recent) > recent_limit:
            recent_limit = max(0, recent_limit - 1)
        for job in recent[:recent_limit]:
            finished = job.get("finished") or job["started"]
            duration = finished - job["started"]
            exit_code = job.get("exit_code")
            result = str(exit_code) if exit_code is not None else '-'
            colors[len(lines)] = completed_color(job, now)
            label = operation_label(job)
            lines.append(f"{label:{operation_width}} {duration:6.1f}s  {result:>4}")
        if len(recent) > recent_limit:
            lines.append("...")
        if not recent:
            lines.append("No completed tasks.")
        for index, line in enumerate(lines[:max(0, rows - 1)]):
            display(line, colors.get(index))
        return

    display("AGENT MONITORING — active commands and recent history")
    display()
    display(f"Running: {sum(job['status'] == 'RUNNING' for job in jobs)} | Logs: {STATE_DIR}")
    display("Activity stays left; live task output appears in adjacent panes.")
    display()
    for job in (active + recent)[:30]:
        state = job["status"]
        duration = (job.get("finished") or now) - job["started"]
        exit_code = "" if job.get("exit_code") is None else f" | exit {job['exit_code']}"
        display(f"{state:11} {time.strftime('%H:%M:%S', time.localtime(job['started']))} "
                f"{duration:6.1f}s | {job['label']}{exit_code}")
        display(f"  {job['cwd']}")
        display(f"  $ {job['command']}")
        display(f"  log: {job['id']}/output.log")
        display()
    if not jobs:
        display("No operations yet.")


def watch():
    try:
        print("\033[?25l", end="", flush=True)
        next_reflow = 0
        while True:
            if time.monotonic() >= next_reflow:
                reflow()
                next_reflow = time.monotonic() + 1
            print("\033[H\033[2J", end="")
            status(compact=True)
            sys.stdout.flush()
            time.sleep(0.2)
    except KeyboardInterrupt:
        pass
    finally:
        print("\033[?25h", end="", flush=True)


def containers(tree):
    yield tree
    for node in tree.get("nodes", []) + tree.get("floating_nodes", []):
        yield from containers(node)


def i3_tree():
    result = subprocess.run(["i3-msg", "-t", "get_tree"], check=True,
                            capture_output=True, text=True)
    return json.loads(result.stdout)


def i3_command(command):
    result = subprocess.run(["i3-msg", command], check=True, capture_output=True, text=True)
    if not all(reply["success"] for reply in json.loads(result.stdout)):
        raise RuntimeError(f"i3 command failed: {command}")


def open_monitor(workspace):
    ensure_session()
    tree = list(containers(i3_tree()))
    existing = next((node for node in tree
                     if node.get("window_properties", {}).get("class") == "AgentMonitor"), None)
    if existing:
        i3_command(f"[con_id={existing['id']}] move container to workspace number {workspace}")
        print(f"Monitoring ready in workspace {workspace}.")
        return
    focused = next((node["id"] for node in tree if node.get("focused")), None)
    with (STATE_DIR / "terminal.log").open("ab") as log:
        terminal = subprocess.Popen(
            ["alacritty", "--class", "AgentMonitor", "--title", "Agent Monitoring",
             "-o", "font.size=13", "-e",
             "tmux", "-S", str(STATE_DIR / "tmux.sock"), "attach-session", "-t", SESSION],
            stdout=log, stderr=log, start_new_session=True,
        )
    deadline = time.monotonic() + 5
    while time.monotonic() < deadline:
        window = next((node for node in containers(i3_tree())
                       if node.get("window_properties", {}).get("class") == "AgentMonitor"), None)
        if window:
            i3_command(f"[con_id={window['id']}] move container to workspace number {workspace}")
            if focused:
                i3_command(f"[con_id={focused}] focus")
            print(f"Monitoring ready in workspace {workspace}.")
            return
        if terminal.poll() is not None:
            raise RuntimeError(f"Terminal exited; see {STATE_DIR / 'terminal.log'}")
        time.sleep(0.1)
    raise TimeoutError("Monitoring terminal did not appear in i3 within 5 seconds.")


def interrupt_process(process):
    for signum in (signal.SIGINT, signal.SIGTERM, signal.SIGKILL):
        if process.poll() is not None:
            return
        try:
            os.killpg(process.pid, signum)
        except ProcessLookupError:
            return
        try:
            process.wait(timeout=3)
            return
        except subprocess.TimeoutExpired:
            continue


def handle_interrupt(signum, _frame):
    raise KeyboardInterrupt(signum)


def run_command(args):
    command = args.command
    if command and command[0] == "--":
        command = command[1:]
    if not command:
        raise ValueError("Specify a command after --.")
    ensure_session()
    directory = Path(tempfile.mkdtemp(prefix=time.strftime("%Y%m%d-%H%M%S-"), dir=STATE_DIR))
    record = {
        "id": directory.name, "label": args.label, "cwd": str(Path.cwd()),
        "command": shlex.join(command), "pid": os.getpid(), "started": time.time(),
        "status": "RUNNING", "exit_code": None,
    }
    write_record(directory, record)
    pane_id = None
    process = None
    master = None
    exit_code = 1
    header = f"[{record['id']}] {args.label}\n{record['cwd']}\n$ {record['command']}\n\n"
    try:
        with (directory / "output.log").open("ab", buffering=0) as log:
            log.write(header.encode())
            print(header, end="", flush=True)
            master, slave = pty.openpty()
            try:
                process = subprocess.Popen(command, stdin=subprocess.DEVNULL, stdout=slave,
                                           stderr=slave, start_new_session=True)
            finally:
                os.close(slave)
            started = time.monotonic()
            with selectors.DefaultSelector() as selector:
                selector.register(master, selectors.EVENT_READ)
                while True:
                    if pane_id is None and time.monotonic() - started > 1 and process.poll() is None:
                        pane_id = add_task_pane(args.label, directory / "output.log")
                    for _key, _events in selector.select(timeout=0.1):
                        try:
                            output = os.read(master, 65536)
                        except OSError as error:
                            if error.errno != errno.EIO:
                                raise
                            output = b""
                        if not output:
                            selector.unregister(master)
                            break
                        log.write(output)
                        sys.stdout.buffer.write(output)
                        sys.stdout.buffer.flush()
                    if not selector.get_map() and process.poll() is not None:
                        break
            exit_code = process.wait()
            if exit_code < 0:
                exit_code = 128 - exit_code
    except FileNotFoundError as error:
        print(error, file=sys.stderr)
        with (directory / "output.log").open("ab") as log:
            log.write(f"{error}\n".encode())
        exit_code = 127
    except KeyboardInterrupt as error:
        if process:
            interrupt_process(process)
        exit_code = 128 + error.args[0]
    finally:
        if process and process.poll() is None:
            interrupt_process(process)
        if master is not None:
            os.close(master)
        record.update(finished=time.time(), exit_code=exit_code,
                      status="OK" if exit_code == 0 else "FAILED")
        write_record(directory, record)
        summary = f"\n{record['status']} | exit {exit_code} | {record['finished'] - record['started']:.1f}s\n"
        with (directory / "output.log").open("ab") as log:
            log.write(summary.encode())
        print(summary, end="", flush=True)
        if pane_id:
            remove_task_pane(pane_id)
    return exit_code


def main():
    os.umask(0o077)
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="action", required=True)
    opener = commands.add_parser("open", help="Open tmux monitoring in i3 workspace 7")
    opener.add_argument("--workspace", type=int, default=7)
    runner = commands.add_parser("run", help="Run a non-interactive command and preserve its exit code")
    runner.add_argument("label")
    runner.add_argument("command", nargs=argparse.REMAINDER)
    commands.add_parser("status", help="Show running operations and recent history")
    commands.add_parser("watch", help="Live activity display (used by tmux)")
    shower = commands.add_parser("show", help="Print the saved output of an operation")
    shower.add_argument("id")
    args = parser.parse_args()
    prepare_state()
    if args.action == "open":
        open_monitor(args.workspace)
    elif args.action == "run":
        signal.signal(signal.SIGTERM, handle_interrupt)
        signal.signal(signal.SIGINT, handle_interrupt)
        return run_command(args)
    elif args.action == "status":
        status()
    elif args.action == "watch":
        watch()
    elif args.action == "show":
        if Path(args.id).name != args.id:
            parser.error("Expected an operation ID, not a path.")
        sys.stdout.buffer.write((STATE_DIR / args.id / "output.log").read_bytes())
    return 0


if __name__ == "__main__":
    sys.exit(main())
