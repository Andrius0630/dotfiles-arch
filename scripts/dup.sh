#!/usr/bin/env bash
SESSION="lecture"
# Create session if missing
tmux has-session -t "$SESSION" 2>/dev/null || \
   tmux new-session -d -s "$SESSION"
# Open second window attached (projector)
konsole -e tmux attach -t "$SESSION" -r &
# Attach current window (control)
tmux attach -t "$SESSION"
