#!/usr/bin/env zsh

MOD="/data/adb/modules/rexshell/files"
OMZ="$MOD/oh-my-zsh"

# ── instant prompt (p10k) ─────────────────────────────────────────────────────
[[ -r "$XDG_CACHE_HOME/p10k-instant-prompt-${(%):-%n}.zsh" ]] &&
  source "$XDG_CACHE_HOME/p10k-instant-prompt-${(%):-%n}.zsh"

# ── history ───────────────────────────────────────────────────────────────────
setopt EXTENDED_HISTORY HIST_IGNORE_DUPS SHARE_HISTORY
mkdir -p "$(dirname "$HISTFILE")"

# ── completion + plugins that need compdef (lazy, on first tab) ───────────────
_resh_compinit_done=0
_resh_compinit() {
  (( _resh_compinit_done )) && return
  _resh_compinit_done=1

  autoload -Uz compinit && compinit -d "$XDG_CACHE_HOME/zcompdump"
  zstyle ':completion:*' menu select
  bindkey '\t' menu-complete
  [[ -n "$terminfo[kcbt]" ]] && bindkey "$terminfo[kcbt]" reverse-menu-complete

  # git plugin calls compdef — must load after compinit
  local f="$OMZ/plugins/git/git.plugin.zsh"
  [[ -f "$f" ]] && source "$f"
}
zle -N _resh_compinit
bindkey '\t' _resh_compinit

# ── plugins that don't need compdef (lazy, on first precmd) ──────────────────
_resh_plugins_done=0
_resh_load_plugins() {
  (( _resh_plugins_done )) && return
  _resh_plugins_done=1

  local f
  f="$OMZ/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
  [[ -f "$f" ]] && source "$f"
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)

  f="$OMZ/custom/plugins/z/zsh-z.plugin.zsh"
  [[ -f "$f" ]] && source "$f"

  f="$OMZ/plugins/sudo/sudo.plugin.zsh"
  [[ -f "$f" ]] && source "$f"

  # syntax-highlighting must be last
  f="$OMZ/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  [[ -f "$f" ]] && source "$f"

  add-zsh-hook -d precmd _resh_load_plugins
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _resh_load_plugins

# ── aliases ───────────────────────────────────────────────────────────────────
if command -v eza &>/dev/null; then
  alias ls='eza -a --icons=never'
  alias l='eza -alihgSUHum --icons=never'
  alias lst='eza --tree'
else
  alias ls='ls -a --color=auto'
  alias l='ls -alh'
fi
command -v bat &>/dev/null && alias cat='bat --style=plain --paging=never'
for _ed in nvim vim vi; do
  command -v "$_ed" &>/dev/null && { export EDITOR="$_ed"; alias vi="$_ed"; break; }
done
alias :q='exit'
alias pk='pkill -9 -e'
alias epoch='date +%s'
alias rm='rm -i'

# ── functions ─────────────────────────────────────────────────────────────────
extract() {
  for f in "$@"; do
    [[ -f "$f" ]] || { echo "'$f' not found"; continue; }
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
srhs()      { grep "$*" "$HISTFILE"; }
try()       { while ! "$@"; do sleep 1; done; }
loop()      { while true; do "$@" && sleep 1 && clear; done; }
incognito() {
  if [[ $1 == off || $1 == -d ]]; then
    fc -P; unset incognito; echo "Incognito OFF"
  else
    cp "$HISTFILE" "$TMPDIR/.zsh_history_incognito"
    fc -p "$TMPDIR/.zsh_history_incognito"
    export incognito=1; echo "Incognito ON"
  fi
}

# ── p10k ──────────────────────────────────────────────────────────────────────
[[ -f "$ZDOTDIR/.p10k.zsh" ]] && source "$ZDOTDIR/.p10k.zsh"

# ── user config ───────────────────────────────────────────────────────────────
[[ -f "/data/media/0/resh/config/user.zsh" ]] && source "/data/media/0/resh/config/user.zsh"
