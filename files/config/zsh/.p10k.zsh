'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')

'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob

  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

  autoload -Uz is-at-least && is-at-least 5.1 || return

  # ─────────────────────────────────────────────
  # PROMPT LAYOUT
  # ─────────────────────────────────────────────

  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    os_icon
    dir
    vcs
    prompt_char
  )

  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    sudocheck
    username
    status
    command_execution_time
    time
  )

  # No multiline frame.
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=false
  typeset -g POWERLEVEL9K_ICON_PADDING=none

  # Clean separators.
  typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=''

  typeset -g POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=''
  typeset -g POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=''
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL=''
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_LAST_SEGMENT_END_SYMBOL=''

  # ─────────────────────────────────────────────
  # GENERAL
  # ─────────────────────────────────────────────

  typeset -g POWERLEVEL9K_MODE=nerdfont-complete

  # ─────────────────────────────────────────────
  # OS ICON
  # ─────────────────────────────────────────────

  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND=white
  typeset -g POWERLEVEL9K_OS_ICON_BACKGROUND=''

  # ─────────────────────────────────────────────
  # PROMPT CHARACTER
  # ─────────────────────────────────────────────

  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD}_FOREGROUND=76
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD}_FOREGROUND=196

  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='❮'

  # ─────────────────────────────────────────────
  # DIRECTORY
  # ─────────────────────────────────────────────

  typeset -g POWERLEVEL9K_DIR_FOREGROUND=cyan
  typeset -g POWERLEVEL9K_DIR_BACKGROUND=''

  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
  typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
  typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true
  typeset -g POWERLEVEL9K_DIR_SHOW_WRITABLE=v3

  # ─────────────────────────────────────────────
  # GIT
  # ─────────────────────────────────────────────

  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=green
  typeset -g POWERLEVEL9K_VCS_CLEAN_BACKGROUND=''

  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=yellow
  typeset -g POWERLEVEL9K_VCS_MODIFIED_BACKGROUND=''

  typeset -g POWERLEVEL9K_VCS_BACKENDS=(git)

  # Temporary until Android-native gitstatusd is bundled.
  typeset -g POWERLEVEL9K_DISABLE_GITSTATUS=true

  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON='\uF126 '

  # ─────────────────────────────────────────────
  # STATUS
  # ─────────────────────────────────────────────

  typeset -g POWERLEVEL9K_STATUS_OK_FOREGROUND=green
  typeset -g POWERLEVEL9K_STATUS_OK_BACKGROUND=''

  typeset -g POWERLEVEL9K_STATUS_OK_VISUAL_IDENTIFIER_EXPANSION='✔'

  typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=red
  typeset -g POWERLEVEL9K_STATUS_ERROR_BACKGROUND=''

  typeset -g POWERLEVEL9K_STATUS_ERROR_VISUAL_IDENTIFIER_EXPANSION='✘'

  # ─────────────────────────────────────────────
  # COMMAND TIME
  # ─────────────────────────────────────────────

  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=yellow
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND=''

  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=0
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'

  # ─────────────────────────────────────────────
  # CLOCK
  # ─────────────────────────────────────────────

  typeset -g POWERLEVEL9K_TIME_FOREGROUND=white
  typeset -g POWERLEVEL9K_TIME_BACKGROUND=''

  typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M:%S}'

  # ─────────────────────────────────────────────
  # CUSTOM SEGMENTS
  # ─────────────────────────────────────────────

  function prompt_sudocheck() {
    [[ $EUID -eq 0 ]] &&
      p10k segment -f red -t '⚡root'
  }

  function prompt_username() {
    p10k segment -f green -t "$(whoami)"
  }

  function prompt_greeting() {
    p10k segment -f 99 -t '🥷 Did you need anything, honey?'
  }

  # ─────────────────────────────────────────────

  typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose
  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true

  (( ! $+functions[p10k] )) || p10k reload
}

typeset -g POWERLEVEL9K_CONFIG_FILE=${${(%):-%x}:a}

(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}

'builtin' 'unset' 'p10k_config_opts'
