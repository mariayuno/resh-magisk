# rexshell p10k config — adapted from github.com/rexackermann/shell
# Android-safe: no lsmod, no /sys/class/thermal check guard

'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'
  autoload -Uz is-at-least && is-at-least 5.1 || return

  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    os_icon
    newline
    dir
    vcs
    newline
    prompt_char
  )
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    sudocheck
    username
    ip
    newline
    background_jobs
    ram
    newline
    status
    command_execution_time
    time
    newline
  )

  typeset -g POWERLEVEL9K_MODE=nerdfont-complete
  typeset -g POWERLEVEL9K_ICON_PADDING=moderate
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=false

  # Multiline box drawing (your style)
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX='%244F╭─'
  typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_PREFIX='%244F├─'
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX='%244F╰─'
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_SUFFIX='%244F─╮'
  typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_SUFFIX='%244F─┤'
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_SUFFIX='%244F─╯'
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_CHAR='─'
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_FOREGROUND=244

  # Segment separators
  typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR='\uE0B5'
  typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR='\uE0B7'
  typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR='\uE0B4'
  typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR='\uE0B6'
  typeset -g POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL='\uE0B4'
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL='\uE0B6'
  typeset -g POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL='░▒▓'
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_LAST_SEGMENT_END_SYMBOL='▓▒░'

  # OS icon
  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=232
  typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND=green

  # Prompt char
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=76
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=196
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='❮'

  # Dir
  typeset -g POWERLEVEL9K_DIR_BACKGROUND=4
  typeset -g POWERLEVEL9K_DIR_FOREGROUND=254
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
  typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true
  typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
  typeset -g POWERLEVEL9K_DIR_SHOW_WRITABLE=v3

  # VCS (git)
  typeset -g POWERLEVEL9K_VCS_CLEAN_BACKGROUND=2
  typeset -g POWERLEVEL9K_VCS_MODIFIED_BACKGROUND=3
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND=2
  typeset -g POWERLEVEL9K_VCS_BACKENDS=(git)
  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON='\uF126 '

  # Status
  typeset -g POWERLEVEL9K_STATUS_OK_VISUAL_IDENTIFIER_EXPANSION='✔'
  typeset -g POWERLEVEL9K_STATUS_OK_FOREGROUND=2
  typeset -g POWERLEVEL9K_STATUS_OK_BACKGROUND=0
  typeset -g POWERLEVEL9K_STATUS_ERROR_VISUAL_IDENTIFIER_EXPANSION='✘'
  typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=3
  typeset -g POWERLEVEL9K_STATUS_ERROR_BACKGROUND=1

  # Execution time
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=0
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND=66
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=0
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PREFIX='took '

  # Time
  typeset -g POWERLEVEL9K_TIME_FOREGROUND=0
  typeset -g POWERLEVEL9K_TIME_BACKGROUND=7
  typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M:%S}'

  # RAM
  typeset -g POWERLEVEL9K_RAM_FOREGROUND=0
  typeset -g POWERLEVEL9K_RAM_BACKGROUND=9

  # IP
  typeset -g POWERLEVEL9K_IP_BACKGROUND=4
  typeset -g POWERLEVEL9K_IP_FOREGROUND=0
  typeset -g POWERLEVEL9K_IP_CONTENT_EXPANSION='$P9K_IP_IP'
  typeset -g POWERLEVEL9K_IP_INTERFACE='[ew].*|wlan.*|rmnet.*'

  # Context (user@host)
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND=1
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_BACKGROUND=0
  typeset -g POWERLEVEL9K_CONTEXT_{REMOTE,REMOTE_SUDO}_FOREGROUND=3
  typeset -g POWERLEVEL9K_CONTEXT_{REMOTE,REMOTE_SUDO}_BACKGROUND=0
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_TEMPLATE='%n@%m'
  typeset -g POWERLEVEL9K_CONTEXT_{REMOTE,REMOTE_SUDO}_TEMPLATE='%n@%m'
  typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_{CONTENT,VISUAL_IDENTIFIER}_EXPANSION=

  # Custom: sudo indicator (from your setup)
  function prompt_sudocheck() {
    if [[ $EUID -eq 0 ]]; then
      p10k segment -b red -f black -t "root" -i $'⚡'
    fi
  }

  # Custom: username
  function prompt_username() {
    p10k segment -b black -f green -t "$(whoami)" -i $'@'
  }

  # Custom: greeting (your original 🥷)
  function prompt_greeting() {
    p10k segment -b 99 -f 0 -i '' -t '🥷 Did you need anything, honey?'
  }

  typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose
  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true
  (( ! $+functions[p10k] )) || p10k reload
}

typeset -g POWERLEVEL9K_CONFIG_FILE=${${(%):-%x}:a}
(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
