export ZDOTDIR=$HOME/.zsh
export HOSTNAME=$(hostname)
export LANG=en_US.UTF-8
export LC_ALL=$LANG

if ([ $UID -ge 1000 ] && groups $USER | grep -q sudo) || [ $UID = 0 ]; then
	path=( /usr/local/bin /usr/bin /bin /usr/local/sbin /usr/sbin /sbin /usr/games )
	for d in /var/lib/gems/1.8/bin/ $HOME/bin ; do
	    [ -d "$d" ] && path=( $d $path )
	done
else
	path=( /usr/local/bin /usr/bin /bin /usr/games )
fi
