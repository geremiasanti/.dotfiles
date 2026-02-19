#!/usr/bin/env bash

function tmux-sessionizer() {
	if [[ $# -eq 1 ]]; then
		selected=$(find ~/dev -mindepth 1 -maxdepth 4 -exec test -e '{}/.git' ';' -print -prune -type d | fzf --filter="$1" | head -n 1)
	else
		selected=$(find ~/dev -mindepth 1 -maxdepth 4 -exec test -e '{}/.git' ';' -print -prune -type d | fzf)
	fi

	if [[ -z $selected ]]; then
		kill -INT $$
	fi

	selected_name=$(basename "$selected" | tr . _)

	tmux new-session -A -s $selected_name -c $selected
}

function setup-ct() {
	local session="CardTrader"
	local root=~/dev/CardTrader

	tmux new-session -d -s "$session" -c "$root"

	tmux new-window -t "$session":0 -n 'rails' -c "$root"
	tmux send-keys  -t "$session":0 "rails s -b 0.0.0.0" C-m

	tmux new-window -t "$session":1 -n 'sidekiq' -c "$root"
	tmux send-keys  -t "$session":1 "bundle exec sidekiq" C-m

	tmux new-window -t "$session":2 -n 'ngrok'
	tmux send-keys  -t "$session":2 "ngrok http 3000" C-m

	# Window 3: temp dir, nvim tempp.txt
	tmux new-window -t "$session":3 -n 'temp' -c ~/temp
	tmux send-keys  -t "$session":3 "nvim tempp.txt" C-m

	# Attach to session on first page
	tmux select-window -t "$session":0
	tmux attach-session -t "$session"
}
