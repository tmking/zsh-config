case $- in 
	*i*)	: ;;
	*)	return
esac

keychain -q -Q id_rsa EE946A6E

local ssh_file="$HOME/.keychain/$HOSTNAME-sh"
local gpg_file="$HOME/.keychain/$HOSTNAME-sh-gpg"

[ -f "$ssh_file" ] && . $ssh_file
[ -f "$gpg_file" ] && . $gpg_file

. $ZDOTDIR/.zps1 2>/dev/null
. $ZDOTDIR/.functions 2>/dev/null
. ~/.aliasrc 2>/dev/null
. /etc/shfuncs

# zsh variables
HISTSIZE=3000
SAVEHIST=3000
HISTFILE=$ZDOTDIR/.history
DIRSTACKSIZE=20
MAILCHECK=60

# misc variables
export RSYNC_RSH=ssh
#export IRCNICK=cthulhain
#export EDITOR=gred
#export XEDITOR=nedit
export LANG="en_US.UTF-8"
WHOIS_HIDE=1

#. $ZDOTDIR/.vorbis 2>/dev/null

#umask 077

cdpath=(
    $cdpath
    /home/music
)

mailpath=(
	~/Mail/inbox'=> new mail'
)

fpath=( $fpath $ZDOTDIR/functions )

fignore=(.o .c~ \~ .\~)

public_dirs=( $HOME/public_html /home/www )

for func in $ZDOTDIR/functions/*; do
	autoload basename $func:t
done

compdef _hosts links yafc netscape
compdef _rsync rsync
compdef _bsetbg bsetbg
compdef _x_color bsetroot
compdef _build build
compdef _rep rep
compdef _email email
compdef _zplay zplay
compdef _notes note
compdef _tar star
compdef _zplay plnk
compdef _isync isync

zstyle ':completion:*:*:ogg123:*' file-patterns '*.(ogg|OGG):ogg\ files *(-/):directories'
zstyle ':completion:*:*:mpg(123|321):*' file-patterns '*.(mp|MP)3:mp3\ files *(-/):directories'

hinfo() 
{
	for arg in "$@"; do
		echo "------$arg------"
		echo "HEAD / HTTP/1.0\n" | nc "$arg" 80
	done
}

zrec() 
 {
      zrecompile "$@" -p -- \
        -R ~/.zshrc -- \
        -R ~/.zdump -- \
        -R ~/lib/zsh/comp/Core/compinit -- \
        -R ~/lib/zsh/comp/Core/compaudit -- \
        -R ~/lib/zsh/comp/Core/compdump -- \
        -M ~/lib/zsh/funcs.zwc \
           ~/funcs/*(.) \
           ~/lib/zsh/comp/*/_* \
           ~/lib/zsh/func/*/*
}

rep() 
{
	case $1 in [a-zA-Z]*) return 3 ;; esac
        local num=$1  && shift 1
        local count=0 
        while [ "$count" != "$num" ]
        do
                if eval $@
		then
                	local count=$(( $count + 1 )) 
		else	
			return 6
		fi
        done
}

note() 
{
	case $(tty) in
		/dev/tty/*)	ed=nano ;;
		*)		ed=mousepad
	esac
	( cd ~/notes && $ed "$@" )
}

smartpager() 
{
	local cmd
	cmd="$1"
	shift 1
	data=( "$(eval command $cmd $@ 2>&1 | tr '\\' ð)" )

	if [ $(print $data | wc -l) -gt $(( $LINES - 5 )) ]; then
		print -n $data | tr ð '\\' | $READNULLCMD
	else
		print $data | tr ð '\\'
	fi
}

