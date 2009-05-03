if [[ -o interactive ]]; then
	if [ -z "$DISPLAY" ] || [ -n "$SSH_TTY" ]; then
	    clear
	fi
fi
