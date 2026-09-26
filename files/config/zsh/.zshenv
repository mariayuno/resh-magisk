export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_STATE_HOME="${HOME}/.local/state"
export XDG_CACHE_HOME="${HOME}/.cache"

export HISTFILE="$XDG_STATE_HOME/zsh/history"
export HISTSIZE=1000000
export SAVEHIST=$HISTSIZE

TERMUX_USR="/data/data/com.termux/files/usr"
REXSHELL_BIN="/data/adb/modules/rexshell/files/bin"

export PATH="$REXSHELL_BIN:$TERMUX_USR/bin:$XDG_DATA_HOME/go/bin:$XDG_DATA_HOME/cargo/bin:$HOME/.local/bin:/system/bin:/system/xbin:/sbin:$PATH"
