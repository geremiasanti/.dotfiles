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
    # Apre il file in una finestra con un file normale: se quella attiva è speciale
    # (fugitive, terminale, quickfix, ...) usa la prima finestra normale del tab
    nvim --server "$sock" --remote-expr "luaeval('(function(a)
        local function normal(w)
            local b = vim.api.nvim_win_get_buf(w)
            return vim.bo[b].buftype == \"\" and not vim.api.nvim_buf_get_name(b):match(\"^%a+://\")
        end
        if not normal(vim.api.nvim_get_current_win()) then
            for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
                if normal(w) then vim.api.nvim_set_current_win(w) break end
            end
        end
        vim.cmd((a[2] ~= \"\" and (\"edit +\" .. a[2] .. \" \") or \"edit \") .. vim.fn.fnameescape(a[1]))
    end)(_A)', ['${file}', '${line}'])" > /dev/null
else
    nvim "${fallback_args[@]}"
fi
