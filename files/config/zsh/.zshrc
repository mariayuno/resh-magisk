#!/usr/bin/env zsh
# rexshell — .zshrc for root/SSH on Android
# Adapted from github.com/rexackermann/shell

# ── Oh-My-Zsh ──────────────────────────────────────────────────────────────
REXSHELL_HOME="/data/adb/modules/rexshell/files"
TERMUX_USR="/data/data/com.termux/files/usr"
TERMUX_OMZSH="$TERMUX_USR/share/oh-my-zsh"
LOCAL_OMZSH="$XDG_DATA_HOME/oh-my-zsh"

# Find oh-my-zsh: bundled → termux → local
for _omz in "$REXSHELL_HOME/oh-my-zsh" "$TERMUX_OMZSH" "$LOCAL_OMZSH" "$HOME/.oh-my-zsh"; do
  [ -f "$_omz/oh-my-zsh.sh" ] && { ZSH="$_omz"; break; }
done

# ── Powerlevel10k instant prompt ────────────────────────────────────────────
[[ -r "${XDG_CACHE_HOME}/p10k-instant-prompt-${(%):-%n}.zsh" ]] && \
  source "${XDG_CACHE_HOME}/p10k-instant-prompt-${(%):-%n}.zsh"

# ── Plugins ─────────────────────────────────────────────────────────────────
ZSH_CUSTOM="${ZSH}/custom"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Only load plugins that exist
_load_plugins=()
_plugin_dirs=(
  "git"
  "sudo"
  "systemadmin"
)
# Optional plugins — load if present
for _p in zsh-autosuggestions zsh-syntax-highlighting z; do
  [ -d "${ZSH_CUSTOM}/plugins/$_p" ] || [ -d "${ZSH}/plugins/$_p" ] && _load_plugins+=("$_p")
done
plugins=($_plugin_dirs[@] $_load_plugins[@])

# ── Zsh autocomplete settings (if plugin present) ───────────────────────────
zmodload zsh/zpty 2>/dev/null
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
zstyle ':autocomplete:*' min-input 2
zstyle ':autocomplete:tab:*' widget-style menu-select
zstyle ':autocomplete:*' fzf-completion yes

[ -n "$ZSH" ] && [ -f "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"

# ── p10k config ─────────────────────────────────────────────────────────────
[ -f "$ZDOTDIR/.p10k.zsh" ] && source "$ZDOTDIR/.p10k.zsh"

# ── History ─────────────────────────────────────────────────────────────────
mkdir -p "$(dirname "$HISTFILE")"
setopt EXTENDED_HISTORY HIST_IGNORE_DUPS SHARE_HISTORY

# ── Completion ──────────────────────────────────────────────────────────────
autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump" -C
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# ── Keybindings ─────────────────────────────────────────────────────────────
bindkey '\t' menu-complete
bindkey "$terminfo[kcbt]" reverse-menu-complete

# ── Smart ls (eza → exa → ls) ───────────────────────────────────────────────
if command -v eza &>/dev/null; then
  alias ls='eza -a --icons'
  alias l='eza -alihgSUHum --icons'
  alias lst='eza --tree'
elif command -v exa &>/dev/null; then
  alias ls='exa -a --icons'
  alias l='exa -alihgSUFHum --icons'
  alias lst='exa --tree'
else
  alias ls='/system/bin/ls -a --color=auto 2>/dev/null || ls -a'
  alias l='ls -alh'
fi

# ── Smart cat (bat → cat) ────────────────────────────────────────────────────
if command -v bat &>/dev/null; then
  alias cat='bat --style=plain --paging=never'
  alias man='batman 2>/dev/null || man'
fi

# ── Smart editor ─────────────────────────────────────────────────────────────
for _ed in lvim nvim vim vi; do
  command -v "$_ed" &>/dev/null && { export EDITOR="$_ed"; alias vi="$_ed"; break; }
done

# ── Your aliases ─────────────────────────────────────────────────────────────
alias :q='exit'
alias pk='pkill -9 -e'
alias epoch='date +%s'
alias rm='rm -i'
alias ssh='ssh -F ~/.ssh/config'

# ── Your functions ───────────────────────────────────────────────────────────
extract() {
  for archive in "$@"; do
    [ -f "$archive" ] || { echo "'$archive' not found"; continue; }
    case $archive in
      *.tar.bz2) tar xvjf "$archive" ;;
      *.tar.gz)  tar xvzf "$archive" ;;
      *.bz2)     bunzip2 "$archive"  ;;
      *.gz)      gunzip "$archive"   ;;
      *.tar)     tar xvf "$archive"  ;;
      *.zip)     unzip "$archive"    ;;
      *.7z)      7z x "$archive"     ;;
      *.rar)     rar x "$archive"    ;;
      *)         echo "Unknown: $archive" ;;
    esac
  done
}

srhs() { rg "$*" "$HISTFILE" 2>/dev/null || grep "$*" "$HISTFILE"; }
try()  { while ! "$@"; do sleep 1; done; }
loop() { while true; do "$@" && sleep 1 && clear; done; }

binpath() {
  type -a "$1" | grep -v 'function\|alias' | awk '{print $3; exit}'
}

incognito() {
  if [[ $1 == off || $1 == -d || $1 == disable ]]; then
    fc -P; incognito=false
    rm -f /tmp/.zsh_history.tmp
    echo "Incognito OFF"
  else
    cp "$HISTFILE" /tmp/.zsh_history.tmp
    fc -p /tmp/.zsh_history.tmp; incognito=true
    echo "Incognito ON"
  fi
}

# SSH agent
env=~/.ssh/agent.env
_agent_load() { test -f "$env" && . "$env" >/dev/null; }
_agent_start() { (umask 077; ssh-agent >"$env"); . "$env" >/dev/null; }
_agent_load
_run_state=$(ssh-add -l >/dev/null 2>&1; echo $?)
if [ ! "$SSH_AUTH_SOCK" ] || [ "$_run_state" = 2 ]; then _agent_start; ssh-add 2>/dev/null
elif [ "$SSH_AUTH_SOCK" ] && [ "$_run_state" = 1 ]; then ssh-add 2>/dev/null; fi
unset env

# ── Cargo/Go env ─────────────────────────────────────────────────────────────
[ -f "$CARGO_HOME/env" ] && source "$CARGO_HOME/env"
