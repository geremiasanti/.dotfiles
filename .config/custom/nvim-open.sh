#!/bin/bash
# Apre file[:line] nell'istanza nvim con server socket attivo
input="$1"

# Separa file e line (se presente)
if [[ "$input" =~ : ]]; then
    file="${input%%:*}"
    line="${input##*:}"
else
    file="$input"
    line=""
fi

# Risolvi a path assoluto usando la cwd della shell
if [[ "$file" != /* ]]; then
    shell_cwd="$(cat /tmp/shell-cwd 2>/dev/null)"
    if [ -n "$shell_cwd" ]; then
        file="$(realpath "$shell_cwd/$file" 2>/dev/null || echo "$file")"
    fi
fi

# Costruisci comando vim
if [ -n "$line" ]; then
    cmd=":e +${line} ${file}<CR>"
    fallback_args=("+${line}" "${file}")
else
    cmd=":e ${file}<CR>"
    fallback_args=("${file}")
fi

# Trova il socket nvim più recente con PID ancora attivo
sock=""
for s in $(ls -t /tmp/nvim-*.sock 2>/dev/null); do
    pid="${s#/tmp/nvim-}"
    pid="${pid%.sock}"
    if kill -0 "$pid" 2>/dev/null; then
        sock="$s"
        break
    else
        rm "$s"
    fi
done

if [ -S "$sock" ]; then
    nvim --server "$sock" --remote-send "<C-\\><C-n>${cmd}"
else
    nvim "${fallback_args[@]}"
fi
