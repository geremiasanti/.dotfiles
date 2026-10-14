#!/usr/bin/env python3
"""Prototype: insert command monitoring through a Codex PreToolUse hook."""

import argparse
import json
import os
from pathlib import Path
import re
import shlex
import sys


MONITOR = Path(__file__).with_name('agent-monitor.py')
WORKSPACES = ['/home/geremia/dev/CardTrader', '/home/geremia/dev/CardTrader-codex-outbound']


def operation_name(command):
    words = shlex.split(command, comments=True)
    for index, word in enumerate(words):
        if Path(word).name == 'nvim-open.sh':
            file = next((arg for arg in words[index + 1:] if not arg.startswith('-')), None)
            return f'show-{Path(file).name}' if file else 'show-nvim'
    if 'rubocop' in words:
        return 'rubocop'
    if any(Path(word).name == 'eslint' for word in words):
        return 'eslint'
    if 'rails' in words or 'bin/rails' in words:
        index = next(index for index, word in enumerate(words) if word in ('rails', 'bin/rails'))
        action = words[index + 1] if len(words) > index + 1 else 'command'
        if action == 'test':
            kind = next((kind for kind in ('system', 'models', 'commands', 'services')
                         if f'test/{kind}' in command), 'non-system')
            workers = re.search(r'PARALLEL_WORKERS=(\d+)', command)
            suffix = f'-{workers[1]}-worker' if workers else ''
            return f'test-{kind}{suffix}'
        return f'rails-{action}'
    if 'git' in words:
        index = words.index('git')
        options = iter(words[index + 1:])
        for word in options:
            if word in ('-C', '-c', '--git-dir', '--work-tree', '--namespace'):
                next(options, None)
            elif not word.startswith('-'):
                return f'git-{word}'
        return 'git-command'
    for word in words:
        if '=' not in word and word not in ('env', 'nice', 'ionice', 'flock') and not word.startswith('-'):
            return Path(word).name
    return 'shell-command'


def rewrite(event, workspaces):
    if event.get('hook_event_name') != 'PreToolUse' or event.get('tool_name') != 'Bash':
        return {}
    cwd = Path(event['cwd']).resolve()
    if not any(cwd.is_relative_to(Path(workspace).resolve()) for workspace in workspaces):
        return {}
    tool_input = event['tool_input']
    command = tool_input.get('command')
    if not isinstance(command, str) or not command.strip():
        return {}
    description = re.match(r'\A[ \t]*# agent-monitor:[ \t]*([^\r\n]*)', command.lstrip())
    label = description[1].strip() if description else ''
    if label == 'off' or str(MONITOR) in command:
        return {}
    # Sensitive output still requires the explicit opt-out; these exclusions cover known local sources.
    if any(value in command for value in ('database.yml', 'master.key', 'auth.json', '.ssh/', '.env',
                                          'printenv')):
        return {}
    try:
        words = shlex.split(command, comments=True)
        if any(Path(word).name in ('nvim', 'vim', 'vi', 'ssh', 'scp', 'sftp', 'sudo') for word in words):
            return {}
        if re.search(r'\brails\s+(console|c|dbconsole)\b', command):
            return {}
        label = label or operation_name(command)
    except ValueError:
        return {}
    shell = os.environ.get('SHELL', '/bin/bash')
    updated = dict(tool_input)
    updated['command'] = shlex.join([sys.executable, str(MONITOR), 'run', '--host-ui', label, '--', shell, '-c', command])
    return {'hookSpecificOutput': {
        'hookEventName': 'PreToolUse', 'permissionDecision': 'allow', 'updatedInput': updated,
    }}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--workspace', action='append')
    args = parser.parse_args()
    event = json.load(sys.stdin)
    print(json.dumps(rewrite(event, args.workspace or WORKSPACES)))


if __name__ == '__main__':
    main()
