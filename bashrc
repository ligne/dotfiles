
# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"

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

PS1="\[\033[;32m\][\[\033[01;32m\]\h\[\033[;32m\]@\[\033[;31m\]\A\[\033[01;34m\] \w\[\033[;32m\]]\[\033[00m\]\\$ "


### Exports ####################################################################

export PATH="~/.bin:${PATH}"
export EDITOR=vim VISUAL=vim PAGER=less
export LC_ALL=en_GB.utf8

export IPOD_MOUNTPOINT='/media/iPod'  # used by GNUPod


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
[ -r ~/.keychain/`hostname -s`-sh ] && . ~/.keychain/`hostname -s`-sh || eval `ssh-agent -s` >/dev/null

export PERLBREW_ROOT=~/.perlbrew
[ -r ~/.perlbrew/etc/bashrc ] && . ~/.perlbrew/etc/bashrc

export PERL_CPANM_OPT="--local-lib=~/.perl5"


### Aliases ####################################################################

alias hd='hexdump -C'
alias less="less -R"
alias cw='cut -c-$COLUMNS'         # limit output to the width of the screen
alias iotop='iotop -d3'
alias nt='nice top'
alias aack='ack -a'                # ack over all files, not just code.
alias alf='ack -af'                # list all files in the tree.  like find -type f, but with less svn/git spuff.
alias dot='ls .[a-zA-Z0-9_]*'      # list dot files only
alias worktunnel='ssh work -T -v'


# shortcuts for debugging catalyst
alias carpcs='perl -Isupport -MCarp::Always script/*_server.pl -r'
alias csdbi='DBIC_TRACE=1 perl -Isupport script/*_server.pl -r'


### Functions ##################################################################

# show vim help on a topic.  eg. "vimhelp scrolloff"
function vimhelp() { vim -n "+help $1" "+only"; }

# view source of a perl module in Vim.  eg. "pmvim Net::SNMP"
function pmvim() { perldoc -m "$1" | vim - -RnM "+set ft=perl"; }
complete -o bashdefault -F _perldoc pmvim

# quickfix for the search terms.
function fnf() { vim -q <(aack -H --nocolor --nogroup --column "$@"); }

# create a new quilt patch, and add all the files in the tree to it.  avoids
# having to remember to "quilt edit" every file.
function qn() { quilt new "$*"; ack -af --ignore-dir patches --ignore-dir .pc | xargs quilt add; }

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
function csdiff() { svn diff "$@" | colordiff | less -RF; }

# play the same file over and over
function musicloop() { while sleep 1; do mpg321 "$@"; done; }

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

# set the xterm title
xtitle () { echo -n -e "\033]0;$*\007"; }

# work around broken Fedora perldoc
perldoc () { command perldoc "$@" | less -F; }
