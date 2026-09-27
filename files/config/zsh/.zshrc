#!/usr/bin/env zsh

MOD="/data/adb/modules/rexshell/files"

ZSH="$MOD/oh-my-zsh"
ZSH_CUSTOM="$ZSH/custom"
ZSH_THEME="powerlevel10k/powerlevel10k"

# p10k instant prompt
[[ -r "$XDG_CACHE_HOME/p10k-instant-prompt-${(%):-%n}.zsh" ]] &&
  source "$XDG_CACHE_HOME/p10k-instant-prompt-${(%):-%n}.zsh"

# plugins
plugins=(git sudo zsh-autosuggestions zsh-syntax-highlighting z)
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# Oh My Zsh
[[ -f "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

# completion
autoload -Uz compinit || {
  print -u2 '[rexshell] ERROR: compinit could not be loaded'
  return 1
}

autoload -Uz add-zsh-hook || {
  print -u2 '[rexshell] ERROR: add-zsh-hook could not be loaded'
  return 1
}

autoload -Uz is-at-least || {
  print -u2 '[rexshell] ERROR: is-at-least could not be loaded'
  return 1
}

autoload -Uz vcs_info || {
  print -u2 '[rexshell] ERROR: vcs_info could not be loaded'
  return 1
}

compinit -d "$XDG_CACHE_HOME/zsh/zcompdump" -C

zstyle ':completion:*' menu select
bindkey '\t' menu-complete
bindkey "$terminfo[kcbt]" reverse-menu-complete

# history
setopt EXTENDED_HISTORY HIST_IGNORE_DUPS SHARE_HISTORY
mkdir -p "$(dirname "$HISTFILE")"

# ls
if command -v eza &>/dev/null; then
  alias ls='eza -a --icons=never'
  alias l='eza -alihgSUHum --icons=never'
  alias lst='eza --tree'
else
  alias ls='ls -a --color=auto'
  alias l='ls -alh'
fi

# cat
command -v bat &>/dev/null && alias cat='bat --style=plain --paging=never'

# editor
for _ed in nvim vim vi; do
  command -v "$_ed" &>/dev/null && {
    export EDITOR="$_ed"
    alias vi="$_ed"
    break
  }
done

# aliases
alias :q='exit'
alias pk='pkill -9 -e'
alias epoch='date +%s'
alias rm='rm -i'

# functions
extract() {
  for f in "$@"; do
    [ -f "$f" ] || {
      echo "'$f' not found"
      continue
    }

    case $f in
      *.tar.bz2) bunzip2 -c "$f" | tar xvf - ;;
      *.tar.gz)  tar xvzf "$f" ;;
      *.bz2)     bunzip2 "$f" ;;
      *.gz)      gunzip "$f" ;;
      *.tar)     tar xvf "$f" ;;
      *.zip)     unzip "$f" ;;
      *.7z)      7z x "$f" ;;
      *.rar)     rar x "$f" ;;
      *)         echo "unknown: $f" ;;
    esac
  done
}

srhs() { grep "$*" "$HISTFILE"; }
try()  { while ! "$@"; do sleep 1; done; }
loop() { while true; do "$@" && sleep 1 && clear; done; }

incognito() {
  if [[ $1 == off || $1 == -d ]]; then
    fc -P
    unset incognito
    echo "Incognito OFF"
  else
    cp "$HISTFILE" /tmp/.zsh_history.tmp
    fc -p /tmp/.zsh_history.tmp
    export incognito=1
    echo "Incognito ON"
  fi
}

# p10k config
[[ -f "$ZDOTDIR/.p10k.zsh" ]] && source "$ZDOTDIR/.p10k.zsh"
