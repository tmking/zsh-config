## zshrc

case $- in 
	*i*)	: ;;
	*)	return
esac

## set paths (regular path is set in zshenv to 
## ensure it is used by non-interactive shells
cdpath=( . ~/ )
case $fpath[-1] in
    $ZDOTDIR/functions*)
        : ;;
    *)
	local -a old_fpath; old_fpath=( $fpath )
	fpath=( $ZDOTDIR/**/*(/N) )
	fpath+=( $old_fpath )
esac
fignore=(.o .c~ \~ .\~)

autoload -Uz compinit promptinit run-help colors zrecompile
compinit -i
promptinit
zmodload -i zsh/stat

## start ssh keychain and source files
if which gpg >/dev/null 2>&1; then
    local gpg_key=$(gpg --list-keys $USER 2>/dev/null| grep pub | cut -d'/' -f2 | cut -d' ' -f1)
fi

if which keychain >/dev/null 2>&1; then
    keychain -q -Q id_rsa $gpg_key 2>/dev/null
    local ssh_file="$HOME/.keychain/$HOSTNAME-sh"
    local gpg_file="$HOME/.keychain/$HOSTNAME-sh-gpg"
    [ -f "$ssh_file" ] && . $ssh_file
    [ -f "$gpg_file" ] && . $gpg_file
fi

## source other files
. $ZDOTDIR/.aliasrc 2>/dev/null
. $HOME/.aliasrc 2>/dev/null

## load prompt
setopt promptsubst
prompt zork -p blue -d white -l WHITE -u BLUE --files --dirs --com --shorthost --tty

## load color config for ls
if [ -f /etc/DIR_COLORS ]; then
    eval `dircolors /etc/DIR_COLORS -b`
elif [ -f $HOME/.dir_colors ]; then
    eval `dircolors $HOME/.dir_colors -b`
elif [ -f $ZDOTDIR/.dir_colors ]; then
    eval `dircolors $ZDOTDIR/.dir_colors`
else
    eval `dircolors`
fi

## limit core dumps
unlimit
limit stack 8192
limit core 0
limit -s

## new file permissions
if [ `id -gn` = `id -un` -a `id -u` -gt 14 ]; then
	umask 002
else
	umask 022
fi

## misc system variables
export MAILHOST=$HOSTNAME
export LESS="-ciqR -x4 -P ?f%f .?m(file %i of %m) .?ltlines%lt-%lb?L/%L. .byte %bB?s/%s. ?e(END) :?pB%pB\%..%t"
[ -x "$(which lesspipe)" ] && eval `lesspipe`
export UNAME=$(uname -r)
export WHOIS_HIDE=1
export PAGER=less
export EDITOR=nano
export VISUAL=$EDITOR

## zsh variables
NULLCMD=:
READNULLCMD=less
REPORTTIME=60
HISTSIZE=3000
SAVEHIST=3000
HISTFILE=$ZDOTDIR/.history
HELPDIR=/usr/share/zsh/zsh-help
DIRSTACKSIZE=20
MAILCHECK=60

## array for host completion
hosts=( `</etc/hosts| grep -v \#` )
[ -e $HOME/.ssh/config ] && hosts=(
	 `grep -w Host ~/.ssh/config | sed 's/=//g' | cut -d' ' -f2 | tr -d '*'`
	$hosts
)

## load personal functions
for func in $ZDOTDIR/functions/*(N); do
	autoload -Uz $func:t
done
compdef _hosts links yafc
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

## configure completion system
zstyle ':completion:*' completer _complete _prefix
zstyle ':completion::prefix-1:*' completer _complete
zstyle ':completion:incremental:*' completer _complete _correct
zstyle ':completion:predict:*' completer _complete
zstyle ':completion:*' menu select=20
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format $'\e[44m\e[1;37mCompleting %d\e[0m'
zstyle ':completion:*:(ssh|scp|sftp|rsync):*' hosts $hosts
zstyle ':completion:*:*:kill:*:jobs' list-colors 'no=01;31'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*' list-colors "$LS_COLORS"
zstyle ':completion::complete:*' use-cache on
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin \
                 /usr/sbin /usr/bin /sbin /bin /usr/X11R6/bin
zstyle ':completion:*:*:ogg123:*' file-patterns '*.(ogg|OGG):ogg\ files *(-/):directories'
zstyle ':completion:*:*:mpg(123|321):*' file-patterns '*.(mp|MP)3:mp3\ files *(-/):directories'

## key bindings
bindkey "^[[3~" delete-char
bindkey "^[^[[3~" delete-word
bindkey '^[\e[D' backward-word
bindkey '^[\e[C' forward-word
bindkey '\e[2~' end-of-history           #insert
bindkey '\e[5~' history-search-backward  #page up
bindkey '\e[6~' history-search-forward   #page down
bindkey '\e[1~' beginning-of-line
bindkey '\e[4~' end-of-line
case $TERM in (xterm*|*rxvt*)
	bindkey '^[[7~' beginning-of-line
	bindkey '^[[8~' end-of-line ;;
esac

## options
setopt hashlistall
setopt hashdirs
setopt nohashcmds
setopt correct
setopt append_history
setopt share_history
setopt nobeep
setopt auto_cd
setopt cdable_vars
setopt pushd_ignore_dups
setopt auto_pushd
setopt nocheckjobs nohup
setopt print_eight_bit
setopt nofunction_argzero
setopt auto_resume
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt extendedglob

## aliases
alias df='df -HT'
alias ls='ls -AFhs --color=yes --show-control-chars'
alias ll='ls -AFhs --color=yes --show-control-chars -l'
alias la='ls -AFhs --color=yes --show-control-chars -a'
alias h='fc -l'
alias d='dirs -v'
alias gw='route -n | grep UG | cut -d" " -f10'
alias grep='grep --color'
alias mv='nocorrect mv -i'
alias cp='nocorrect cp -i'
alias mkdir='nocorrect mkdir'
alias rm='nocorrect rm -i'

## A handy set of aliases for users in the 'sudo' group
if [ "$UID" -ge 1000 ] && groups $USER | grep -q sudo; then
    if [ -e /etc/debian_version ]; then
	for b in /usr/bin/{apt*(N),dpkg*(N),deb*(N)} /usr/sbin/dpkg*; do
	    a=$b:t
	    alias `eval echo \$a`="sudo $a"
	done

	alias apt=aptitude
	alias uupdate='sudo uupdate'
	alias m-a='sudo m-a'
    fi

    if [ -e /etc/gentoo-release ]; then
	alias emerge='sudo emerge'
	alias dispatch-conf='sudo dispatch-conf'
    fi

    alias modprobe='sudo modprobe'
    alias rmmod='sudo rmmod'
    alias iptables='sudo iptables'
fi

##functions
lsExec()
{
    do=$1; shift
    args=$@

    case $do in
	files)	ls $args *(.N)		;;
	dirs)	ls -d $args *(-/N)	;;
	links)	ls $args *(@N) .*(@N)		;;
	hidden)	ls $args .*(.N)
    esac
}

lsFunc()
{
    do=$1; shift
    args=()
    dirs=()
    while [ "$*" ]; do
	if [ -d "$1" ]; then
	    dirs+=$1
	else
	    case $1 in -*)	args+=$1 esac
	fi
	shift
    done

    if [ -z "$dirs" ]; then
	lsExec $do $args
    else
	for dir in $dirs; do
	    ( cd $dir && print "\n$dir:"; lsExec $do $args )
	done
    fi

    unset do args dirs
}

lsf() {	lsFunc files $@ }
lsd() { lsFunc dirs $@ }
lsa() { lsFunc hidden $@ }
lsl() { lsFunc links $@ }

reload() 
{
    [ "$TERM" = xterm ] && print -Pn '%{\e]0;[ reloading... ]\a%}'
    unhash -a -f -m \*
    local tstamp=$(date +%S)
    . $ZDIR/zshenv 2>/dev/null
    . $ZDIR/zshrc 2>/dev/null
    . $ZDOTDIR/.zshenv 2>/dev/null
    . $ZDOTDIR/.zshrc 2>/dev/null

    zrecompile -p -- \
	-R $ZDOTDIR/.zshrc -- \
	-M $ZDOTDIR/.zcompdump -- \
	-M $ZDOTDIR/functions/**/*.zwc(N)

    for f in $ZDOTDIR/functions/**/*(.N); do
	case $f in 
	    *.zwc*) : ;;
	    *)
		unfunction $f:t && autoload -Uz $f:t
	esac
    done

    precmd 2>/dev/null
    local tstamp2=$(( $(date +%S) - $tstamp ))
    print "config reloaded in $tstamp2 seconds"
}

showcfg() 
{
    getcfg_f() 
    {
	local yes
	if [ -f $1 ]; then
	    yes="(*)"
	else
	    yes="\e[1;30m( )"
	fi
	print "  $yes $1\e[0m"
    }

    global_confs=( zshenv zprofile zshrc zlogin zlogout zps1 )
    local_confs=( .zshenv .zprofile .zshrc .zlogin .ps1 .hosts .history )

    print "global:"
    for c in $global_confs; do
	getcfg_f $ZDIR/$c
    done
    getcfg_f /etc/aliasrc

    print "\nlocal:"
    for c in $local_confs; do
	getcfg_f $ZDOTDIR/$c
    done
    
    unset global_confs local_confs
}

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
         -R $ZDOTDIR/.zshrc -- \
         -R $ZDOTDIR/.z*dump -- \
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


