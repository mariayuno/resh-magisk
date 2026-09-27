MOD="/data/adb/modules/rexshell/files"

export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

export PATH="$MOD/bin:/system/bin:/system/xbin"
export HISTFILE="$HOME/.local/state/zsh/history"
export HISTSIZE=1000000
export SAVEHIST=$HISTSIZE

# Do not load Termux's global zshrc.
# This prevents its broken command-not-found handler.
unsetopt GLOBAL_RCS
export TERM=xterm-256color  # override if your client supports it e.g. kitty
