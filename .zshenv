export ZDOTDIR=$HOME/.zsh
export HOSTNAME=$(hostname)
export LANG=en_US.UTF-8
export LC_ALL=$LANG

local base_uid=500

[ "$(uname)" = 'Darwin' ] && export IS_OSX=yes

if [ $UID -ge $base_uid ] || [ $UID = 0 ]; then
	path=(
		/usr/local/bin /usr/bin /bin
		/usr/local/sbin /usr/sbin /sbin
		/usr/X11R6/bin /usr/games
		$HOME/.gem/ruby/1.8/bin
	)
	for d in /opt/local/bin /opt/local/sbin /var/lib/gems/1.8/bin/ $HOME/bin ; do
	    [ -d "$d" ] && path=( $d $path )
	done
else
	path=( /usr/local/bin /usr/bin /bin /usr/games )
fi

