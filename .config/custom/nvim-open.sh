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

# Costruisci comando vim
if [ -n "$line" ]; then
    cmd=":e +${line} ${file}<CR>"
    fallback_args=("+${line}" "${file}")
else
    cmd=":e ${file}<CR>"
    fallback_args=("${file}")
fi

if [ -S /tmp/nvim.sock ]; then
    nvim --server /tmp/nvim.sock --remote-send "<C-\\><C-n>${cmd}"
else
    nvim "${fallback_args[@]}"
fi
