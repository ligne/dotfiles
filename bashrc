umask 0022

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"

# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

unset COLORTERM  # 256 colours makes my vim ugly.
# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion -a -z "${BASH_COMPLETION}" ]
then
    . /etc/bash_completion || true
fi


### General settings ###########################################################

PS1="\[\033[;32m\][\[\033[;39m\]\h\[\033[;32m\]@\[\033[;31m\]\A\[\033[01;34m\] \w\[\033[;32m\]]\[\033[00m\]\\$ "


### Exports ####################################################################

export PATH="~/.bin:${PATH}"
export EDITOR=vim VISUAL=vim PAGER=less
export LC_ALL=en_GB.utf8

export MANWIDTH=80   # 80-column man-pages, even when the terminal is wider


### History ####################################################################

# Append to history file, rather than overwrite it.
shopt -s histappend

export HISTIGNORE=" :&:ls:[bf]g:exit:cd"
export HISTCONTROL=ignoreboth  # ignore duplicate entries, and ones that start with a space
export HISTFILESIZE=10000 HISTSIZE=10000


### Completion #################################################################

shopt -s no_empty_cmd_completion

# autocomplete for netcat is nice.
complete -F _known_hosts nc

# Hide these files from the completion suggestions.
export FIGNORE=CVS:.svn:.git


### Miscellanea ################################################################

# load the keychain environment for this host.
[ -r ~/.keychain/`hostname -f`-sh ] && . ~/.keychain/`hostname -f`-sh


### Aliases ####################################################################

alias aack='ack -a'                # ack over all files, not just code.
alias alf='ack -af'                # list all files in the tree.  like find -type f, but with less svn/git spuff.
alias cw='cut -c-$COLUMNS'         # limit output to the width of the screen
alias fcat='grep ^ '
alias ffx-open='while read url; do firefox "$url"; sleep 0.1; done'
alias hd='hexdump -C'
alias iotop='iotop -d3'
alias less="less -R"
alias nt='nice top'

alias ozdate='TZ=Australia/Canberra date'
alias msdate='TZ=America/Los_Angeles date'

alias kindle-backup='rsync -hav --delete /run/media/mlb/Kindle/    /home/local/mlb/.kindle/ --exclude-from ~/.kindle-excludes --stats'
alias sansa-backup='rsync  -hav --delete /run/media/mlb/0123-4567/ /home/local/mlb/scratch/.sansa/  --exclude-from ~/.sansa-excludes  --stats'

### Functions ##################################################################

# show vim help on a topic.  eg. "vimhelp scrolloff"
function vimhelp() { vim -n "+help $1" "+only"; }

# view source of a perl module in Vim.  eg. "pmvim Net::SNMP"
function pmvim() { perldoc -m "$1" | vim - -RnM "+set ft=perl"; }
complete -o bashdefault -F _perldoc pmvim

# quickfix for the search terms.
function fnf() { vim -q <(ack -H --nocolor --nogroup --column "$@"); }

# scrub out stale SSH keys.
function rm_bad_ssh_key()
{
	[[ -n $1 ]] || return

	if grep -q $1 /etc/ssh/ssh_known_hosts
	then
		echo Deleting $1 from system known_hosts files
		sudo sed -i '/^\[\?'$1'/d' /etc/ssh/ssh_known_hosts
	fi
	if grep -q $1 ${HOME}/.ssh/known_hosts
	then
		echo Deleting $1 from local known_hosts files
		sed -i '/^\[\?'$1'/d' ${HOME}/.ssh/known_hosts
	fi
}

# colorified and paged version of svn diff
function csdiff() { svn diff "$@" | dos2unix | colordiff | less -RFX; }

# git-svn helpers from <http://www.fredemmott.co.uk/blog/2009/07/13/>.
#   show the commit message and full diff for an svn revision number, assuming
#   that 'master' follows trunk; usage: git-svn-revision 123
function git-svn-revision() { git log master --grep=trunk@$1 --color --full-diff -p; }
#   cherry pick a commit from master to the current branch, by revision number;
#   usage: git-svn-merge 123
function git-svn-merge()
{
	set -e
	commit=$(git log master --grep=trunk@$1 -p | head -n1 | cut -f2 '-d ')
	git cherry-pick $commit
	git commit --amend
}

# work around broken Fedora perldoc
perldoc () { command perldoc "$@" | less -F; }

# shortcut for perl one-liners
p1 () {
  case "$1" in
      -*) ;;
       *) set -- -E "$@" ;;
  esac
  perl -MData::Dumper -E "sub D(\$){ say Dumper(shift) }" "$@"
}

# lists tabs in another firefox session that aren't already open.
othertabs () {
  [ -n "$1" ] && comm -13 <(ffx-open-tabs | sort) <(ffx-open-tabs "$1" | sort)
}

