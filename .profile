# Shell
export PATH=~/bin:$PATH

# Git
#   Prompt
source /usr/local/etc/bash_completion.d/git-prompt.sh
GIT_PS1_SHOWDIRTYSTATE=true
# GIT_PS1_SHOWUNTRACKEDFILES=true
# GIT_PS1_SHOWSTASHSTATE=true
# GIT_PS1_SHOWUPSTREAM=true
#   Autocomplete
_git_cherry_pick_to () { __gitcomp "$(__git_refs)"; }
_git_stash_index () { _git_stash "$@"; }
_git_stash_without_index () { _git_stash "$@"; }
_git_lg () { _git_log "$@"; }
#   Third Party git extensions
export PATH=$PATH:/Users/jfrey/projects/external/git-aliae/bin
export PATH=$PATH:/Users/jfrey/projects/external/git-aliae/wip
export PATH=$PATH:/Users/jfrey/projects/external/DanielVartanov/willgit/bin

# GPG
export GPG_TTY=$(tty)

# BFG Repo Cleaner: http://rtyley.github.io/bfg-repo-cleaner/
export PATH=$PATH:/opt/bfg

# Android
export ANDROID_HOME=/usr/local/opt/android-sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools

# Minishift
export PATH=$PATH:/Users/jfrey/.minishift/cache/oc/v3.6.0

# Python
export PATH=$PATH:/Users/jfrey/Library/Python/3.7/bin

# NVM
export NVM_DIR="$HOME/.nvm"
source "/usr/local/opt/nvm/nvm.sh"
# Homebrew
export HOMEBREW_SRC=/usr/local/Library/Homebrew

# Bundler
export BUNDLER_EDITOR=/Users/jfrey/bin/subl
alias be="bundle exec"
alias bundle_135=""

# Memcache
# full memcache client: http://www.commandlinefu.com/commands/view/8662/full-memcache-client-in-under-255-chars-uses-dd-sed-and-nc
memcache_client(){ if [ "$1" = "--help" ]; then echo -e "usage: memcache_client memcache-command [arguments]\nwhere memcache-command might be:\nset\nadd\nget[s] <key>*\nappend\nprepend\nreplace\ndelete\nincr\ndecr\ncas\nstats\nverbosity\nversion\nnotes:\n  exptime argument is set to 0 (no expire)\n  flags argument is set to 1 (arbitrary)"; else { case $1 in st*|[vgid]*) printf "%s " "$@";; *) dd if=$3 2>&1|sed '$!d;/^0/d;s/ .*//;s/^/'"$1"' '"$2"' 1 0 /; r '"$3"'' 2>/dev/null;;esac;printf "\r\nquit\r\n";}|nc -n 127.0.0.1 11211; fi }

# ManageIQ
alias vmdb="[ -f ~/dev/manageiq/vmdb/Gemfile ] && cd ~/dev/manageiq/vmdb || cd ~/dev/manageiq"

# Tokens
source /Users/jfrey/.profile_tokens
