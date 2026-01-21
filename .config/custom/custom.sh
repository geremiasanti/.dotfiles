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

	# Create session detached, starting at root
	tmux new-session -d -s "$session" -c "$root"

	# Window 0: rails server
	tmux new-window -t "$session":0 -n 'rails' -c "$root"
	tmux send-keys  -t "$session":0 "rails s" C-m

	# Window 1: sidekiq 
	tmux new-window -t "$session":1 -n 'sidekiq' -c "$root"
	tmux send-keys  -t "$session":1 "bundle exec sidekiq" C-m

	# Window 2: 
	tmux new-window -t "$session":2 -n 'ngrok'
	tmux send-keys  -t "$session":2 "ngrok http 3000" C-m

	# Window 3: temp dir, nvim tempp.txt
	tmux send-keys -t "$session":3 "cd ~/temp" C-m

	# Attach to session
	tmux attach-session -t "$session"
}
