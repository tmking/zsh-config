if [[ -o interactive ]]; then
	if [ -s ~/.plan ]; then
        	echo
        	cat ~/.plan
	fi
fi
