if [[ -o interactive ]]; then
	if [ -z "$DISPLAY" ] || [ -z "$SSH_TTY" ]; then
	    clear
	fi
fi
