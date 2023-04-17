if [[ "$OSTYPE" == "darwin"* ]]; then
  IS_MAC=true
fi

# Shell
export PATH=~/bin:$PATH

# WSL
if [ "$IS_MAC" != "true" ]; then
  export USERPROFILE="/mnt/c/Users/Fryguy"

  # WSL inserts a lot of unneeded paths, like /mnt/c/Windows, that
  #   cause zsh completion to be extremely slow, so remove them.
  export PATH=$(echo $PATH | tr ':' '\n' | grep -v "/mnt/c/" | tr '\n' ':')
fi

# Git
#   Prompt
if [ "$IS_MAC" == "true" ]; then
  source /usr/local/etc/bash_completion.d/git-prompt.sh
else
  source /etc/bash_completion.d/git-prompt
fi
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
export PATH=$PATH:$HOME/projects/external/git-aliae/bin
export PATH=$PATH:$HOME/projects/external/git-aliae/wip
export PATH=$PATH:$HOME/projects/external/DanielVartanov/willgit/bin

# GPG
export GPG_TTY=$(tty)

# SSH
if [ "$IS_MAC" != "true" ]; then
  keychain --nogui --quiet $(ls -p $HOME/.ssh | grep -v "config\|known_hosts\|\.pub")
  source $HOME/.keychain/$HOST-sh
fi

# PostgreSQL
export PATH=/usr/local/opt/postgresql@13/bin${PATH:+:$PATH}
export LDFLAGS=-L/usr/local/opt/postgresql@13/lib${LDFLAGS:+:$LDFLAGS}
export CPPFLAGS=-I/usr/local/opt/postgresql@13/include:${CPPFLAGS:+:$CPPFLAGS}

# BFG Repo Cleaner: http://rtyley.github.io/bfg-repo-cleaner/
export PATH=$PATH:/opt/bfg

# Android
export ANDROID_HOME=/usr/local/opt/android-sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools

# Python
export PATH=$PATH:$HOME/Library/Python/3.7/bin

# Go
export PATH=$PATH:$HOME/go/bin

# NVM
export NVM_DIR="$HOME/.nvm"
[ -e "/usr/local/opt/nvm/nvm.sh" ] && source "/usr/local/opt/nvm/nvm.sh"

# LLVM
export LLVM_CONFIG=/usr/local/opt/llvm@8/bin/llvm-config

if [ "$IS_MAC" == "true" ]; then
  # Homebrew
  export HOMEBREW_SRC=/usr/local/Library/Homebrew
  export HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK=1
  export HOMEBREW_NO_INSTALL_CLEANUP=1
fi

# Bat
export BAT_THEME="Twilight (Fryguy)"

# Bundler
export BUNDLER_EDITOR=$HOME/bin/subl
alias be="bundle exec"

# Docker
docker() {
  custom_docker_cmd="docker-$1"
  if [ -x "$(which "$custom_docker_cmd")" ]; then
    shift
    $custom_docker_cmd "$@"
  else
    command docker "$@"
  fi
}

# Silver Searcher
alias ag='ag --skip-vcs-ignores --no-group --depth 999 --path-to-ignore ~/.gitignore_global'

# Tree
alias tree='tree -I bower_components -I node_modules'

# dusk
dusk(){ du -skx .[a-z]* * | sort -nr | head ${1--30}}

# Memcache
# full memcache client: http://www.commandlinefu.com/commands/view/8662/full-memcache-client-in-under-255-chars-uses-dd-sed-and-nc
memcache_client(){ if [ "$1" = "--help" ]; then echo -e "usage: memcache_client memcache-command [arguments]\nwhere memcache-command might be:\nset\nadd\nget[s] <key>*\nappend\nprepend\nreplace\ndelete\nincr\ndecr\ncas\nstats\nverbosity\nversion\nnotes:\n  exptime argument is set to 0 (no expire)\n  flags argument is set to 1 (arbitrary)"; else { case $1 in st*|[vgid]*) printf "%s " "$@";; *) dd if=$3 2>&1|sed '$!d;/^0/d;s/ .*//;s/^/'"$1"' '"$2"' 1 0 /; r '"$3"'' 2>/dev/null;;esac;printf "\r\nquit\r\n";}|nc -n 127.0.0.1 11211; fi }

# ManageIQ
alias vmdb="[ -f ~/dev/manageiq/vmdb/Gemfile ] && cd ~/dev/manageiq/vmdb || cd ~/dev/manageiq"
#   to compile rugged with SSH support
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/opt/openssl/lib/pkgconfig
#   secrets store
alias miq-pass='PASSWORD_STORE_DIR=$HOME/dev/private/secrets pass'

# Tokens
source $HOME/.profile_tokens
