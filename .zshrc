##
## zshrc

## set paths (regular path is set in zshenv to
## ensure it is used by non-interactive shells
. $ZDOTDIR/.zshenv 2>/dev/null

## source other files for compatibility
. $ZDOTDIR/.aliasrc 2>/dev/null
#. $HOME/.aliasrc 2>/dev/null

[ -x $HOME/.rvm/scripts/rvm ] && . $HOME/.rvm/scripts/rvm

## populate some arrays
cdpath=( . ~/ )
fignore=(.zwc .o .c~ \~ .\~ .DS_Store)

case $fpath[-1] in
  $ZDOTDIR/functions*)
  : ;;
  *)
  fpath=( $ZDOTDIR/**/*(/N) $fpath )
esac

[[ -e "$HOME/.ssh/config" ]] && hosts+=(
  ${${=${(M)${(f)"$(<~/.ssh/config)"}:#Host*}#Host }:#*[\*\?]*}
)

## load some global zsh functions
autoload -Uz compinit promptinit run-help colors zrecompile
compinit -i
promptinit
zmodload -i zsh/stat

## load personal functions
myfunctions=( $ZDOTDIR/functions/**/*(N) $ZDOTDIR/Completion/**/*(N) )
for f in ${myfunctions%*.old}; do
  [ -f "$f:r.zwc" ] || zcompile -M $f
  autoload $f:t
done
unset myfunctions
compdef _x_color bsetroot
compdef _tar star

## load prompt.
prompt zork

## start ssh keychain and source files
export GPG_TTY=$(tty)
keys=()
if which keychain >/dev/null 2>&1 && [[ $UID -ge $base_uid ]]; then
  if which gpg >/dev/null 2>&1 && [[ -e $HOME/.gnupg/pubring.gpg ]]; then
    gpg_key="EE946A6E"
  fi

  [[ -d $ZDOTDIR/keys ]] && keys+=( $ZDOTDIR/keys/* )

  eval `keychain -q -Q --eval $keys:t(N) $gpg_key`
fi
unset gpg_key keys key

## load color config for ls
if [ -f /etc/DIR_COLORS ]; then
  eval `dircolors /etc/DIR_COLORS -b`
elif [ -f $HOME/.dir_colors ]; then
  eval `dircolors $HOME/.dir_colors -b`
elif [ -f $ZDOTDIR/.dir_colors ]; then
  eval `dircolors $ZDOTDIR/.dir_colors`
elif [ -x "$(which dircolors)" ]; then
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
export EDITOR=vim
export VISUAL=$EDITOR
export VIM_APP_DIR=/opt/homebrew/Cellar/macvim/7.3-57

## zsh variables
NULLCMD=:
READNULLCMD=less
REPORTTIME=60
HISTSIZE=3000
SAVEHIST=3000
HISTFILE=$ZDOTDIR/.history
HELPDIR=/usr/share/zsh/help
DIRSTACKSIZE=20
MAILCHECK=100000000

## configure completion system
zstyle ':completion:*' completer _complete _prefix
zstyle ':completion::prefix-1:*' completer _complete
zstyle ':completion:incremental:*' completer _complete _correct
zstyle ':completion:predict:*' completer _complete
zstyle ':completion:*' menu select=zstyle
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format $'\e[44m\e[1;37mCompleting %d\e[0m'
zstyle ':completion:*:(ssh|scp|sftp|rsync|git|yafc|lftp):*' hosts $hosts
zstyle ':completion:*:*:kill:*:jobs' list-colors 'no=01;31'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*' list-colors "$LS_COLORS"
zstyle ':completion::complete:*' use-cache on
zstyle ':completion:*:sudo:*' "$path"
zstyle ':completion:*:*:ogg123:*' file-patterns '*.(ogg|OGG):ogg\ files *(-/):directories'
zstyle ':completion:*:*:mpg(123|321):*' file-patterns '*.(mp|MP)3:mp3\ files *(-/):directories'

## key bindings
bindkey "^[[3~" delete-char
bindkey "3~" delete-word
bindkey '5D' backward-word
bindkey '3D' backward-word
bindkey '5C' forward-word
bindkey '3C' forward-word
bindkey '\e[2~' end-of-history           #insert

# for OS X
bindkey "^[r" history-incremental-search-forward
bindkey '\033[5D' backward-word
bindkey '\033[5C' forward-word

bindkey '\e[5~' history-search-backward  #page up
bindkey '\e[6~' history-search-forward   #page down
bindkey '\e[1~' beginning-of-line
bindkey '\e[4~' end-of-line
bindkey '^[[7~' beginning-of-line
bindkey '^[[8~' end-of-line

## options
setopt append_history
setopt auto_cd
setopt auto_pushd
setopt auto_resume
setopt cdable_vars
setopt correct
setopt extendedglob
setopt function_argzero
setopt hashlistall
setopt hashdirs
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt nobeep
setopt nocheckjobs
setopt nohashcmds
setopt nohup
setopt print_eight_bit
setopt pushd_ignore_dups
setopt share_history

## Things to set up if I'm in the 'sudo' group
if [ "$UID" -ge $base_uid ]; then
  if [ "$IS_OSX" ]; then
    which gpgdir >/dev/null 2>&1 && alias gpgdir='gpgdir -u $HOME -a'
    alias port='sudo port'
    alias launchctl='sudo launchctl'

  elif groups $USER | grep -q sudo; then
    if [ -e /etc/debian_version ]; then
      for binary in /usr/bin/{apt*(N),dpkg*(N),deb*(N)} /usr/sbin/dpkg*; do
        alias_name=$binary:t
        alias `eval echo \$alias_name`="sudo $alias_name"
      done

      alias apt=aptitude
      alias uupdate='sudo uupdate'
      alias m-a='sudo m-a'
      alias service='sudo service'
    fi

    if [ -e /etc/gentoo-release ]; then
      alias emerge='sudo emerge'
      alias dispatch-conf='sudo dispatch-conf'
    fi

    alias modprobe='sudo modprobe'
    alias rmmod='sudo rmmod'
    alias iptables='sudo iptables'

    unset binary alias_name
  fi
fi
