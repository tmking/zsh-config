##
## zshenv

export ZDOTDIR=$HOME/.zsh
export HOSTNAME=$(hostname)
export LANG=en_US.UTF-8
export LC_ALL=$LANG
export POSTGRES_USER=$USER

# these settings tune the ruby garbage collector
#export RUBY_GC_HEAP_INIT_SLOTS=1000000
#export RUBY_HEAP_SLOTS_INCREMENT=1000000
#export RUBY_HEAP_SLOTS_GROWTH_FACTOR=1
#export RUBY_GC_MALLOC_LIMIT=1000000000
#export RUBY_HEAP_FREE_MIN=500000

local base_uid=500

[ "$(uname)" = 'Darwin' ] && export IS_OSX=yes

if [ "$IS_OSX" ]; then
  export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
fi

if [ $UID -ge $base_uid ] || [ $UID = 0 ]; then
  other_path_dirs=(
    /opt/local/bin
    /opt/local/sbin
    /var/lib/gems/1.8/bin/
    /usr/X11R6/bin /usr/games
    $HOME/bin
    $HOME/.rbenv/bin
  )

  path=(
    /usr/local/bin /usr/bin /bin
    /usr/local/sbin /usr/sbin /sbin
  )
  for d in $other_path_dirs; do
    [ -d "$d" ] && path=( $d $path )
  done

  if which brew >/dev/null 2>&1; then
    path=( $(/usr/local/bin/brew --prefix coreutils)/libexec/gnubin $path )
  fi

  unset other_path_dirs
else
  path=( /usr/local/bin /usr/bin /bin /usr/games )
fi


