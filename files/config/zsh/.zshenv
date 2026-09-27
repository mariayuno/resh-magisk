# rexshell zshenv — minimal, non-overwriting
# resh launcher already sets PATH/LD_LIBRARY_PATH before exec'ing zsh.
# We only set things that zshenv uniquely needs to provide.

export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

export HISTFILE="${HISTFILE:-$HOME/.local/state/zsh/history}"
export HISTSIZE=1000000
export SAVEHIST=$HISTSIZE

# Do not load Termux's global zshrc.
unsetopt GLOBAL_RCS
export TERM=xterm-256color
