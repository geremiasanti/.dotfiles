#!/usr/bin/env bash

function tmux-sessionizer() {
	if [[ $# -eq 1 ]]; then
		selected=$(find ~/dev ~/.config -mindepth 1 -maxdepth 4 -exec test -e '{}/.git' ';' -print -prune -type d | fzf --filter="$1" | head -n 1)
	else
		selected=$(find ~/dev ~/.config -mindepth 1 -maxdepth 4 -exec test -e '{}/.git' ';' -print -prune -type d | fzf)
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

	# Window 0: temp dir, nvim tempp.txt
	tmux send-keys -t "$session":0 "cd ~/temp" C-m

	# Window 1: free for whatever
	#

	# Window 2: rails server in root
	tmux new-window -t "$session":2 -n 'rails' -c "$root" "bash -c 'rails s; exec bash'"

	# Window 3: sidekiq in root
	tmux new-window -t "$session":3 -n 'sidekiq' -c "$root" "bash -c 'bundle exec sidekiq; exec bash'"

	# go back to temp
	tmux select-window -t "$session":0

	# Attach to session
	tmux attach-session -t "$session"
}
