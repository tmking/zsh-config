if [[ -o interactive ]]; then
	if [ "$DISPLAY" ] && [ -z "$SSH_TTY" ]; then
	    clear
	fi
fi
