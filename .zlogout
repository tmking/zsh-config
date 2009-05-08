if [[ -o interactive ]]; then
    case $TERM in
	xterm*|*rxvt*|Eterm*|*cygwin*)
	    : ;;
	*)
	    clear
    esac
fi
