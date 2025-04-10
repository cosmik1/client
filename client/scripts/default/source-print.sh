#!/usr/bin/env bash

# https://en.wikipedia.org/wiki/ANSI_escape_code#CSI_(Control_Sequence_Introducer)_sequences
# https://misc.flogisoft.com/bash/tip_colors_and_formatting

include arguments

# print_to_log_and_stdout [Formatting prefix] [Formatting postfix]
function print_to_log_and_stdout() {
  while IFS= read -rn "$(getconf ARG_MAX)" line; do
    printf -- "$1%s$2\n" "$line" | tee -a "$BASE_DIR/cosmik.log"
  done
}

# print_to_log_and_stderr [Formatting prefix] [Formatting postfix]
function print_to_log_and_stderr() {
  print_to_log_and_stdout "$1" "$2" >/dev/stderr
}

# print_to_log [Formatting prefix] [Formatting postfix]
function print_to_log() {
  if [ "$LOG_TO_CONSOLE" = "true" ]; then
    print_to_log_and_stdout "$1" "$2"
  else
    print_to_log_and_stdout "$1" "$2" >/dev/null
  fi
}

# ask_for_selection [Default value] [Options list ...]
function ask_for_selection() {
  local default options
  default="$1"
  shift

  options=()
  for option in "$@"; do
    options+=("$option")
  done

  # Add default value if it's not in list:
  if [ -n "$default" ] && ! in_list "$default" "${options[@]}"; then
    options+=("$default")
  fi

  # Print options:
  local options_length default_index
  options_length=0

  for option in "${options[@]}"; do
    ((options_length++))
    local line
    line="$options_length) $option"

    if [ "$option" = "$default" ]; then
      echo "$line" | print_to_log_and_stderr "\e[0;35m  " "\e[0m \e[1;35m[Default]\e[0m"
      default_index="$options_length"
    else
      echo "$line" | print_to_log_and_stderr "\e[0;35m  " "\e[0m"
    fi
  done

  # Ask for selection:
  local input value

  while true; do
    input=$(ask_for_input)

    # Overwrite last line:
    printf >&2 "\e[1A\e[K"

    # Selection is in range:
    if [ "$input" -ge 1 ] 2>/dev/null && [ "$input" -le "$options_length" ]; then
      value="${options[$input - 1]}"
      break
    fi

    # Use default:
    if [ "$input" = "" ] && [ -n "$default" ]; then
      input="$default_index"
      value="$default"
      break
    fi
  done

  # Only for stderr, not for log, mark selection in options list:
  local lines_up
  lines_up=$((options_length - input + 1))
  # Go back to line with selection...
  printf >&2 "\e[%sA" "$lines_up"
  # ...overwrite the number...
  printf >&2 "  \e[45m\e[1;35m%s\e[0m" "$input)"
  # ...and go back to end.
  printf >&2 "\e[G\e[%sB" "$lines_up"

  # Output selection:
  echo >&2 "$value"
  echo "$value"
}

# ask_for_input [Default value]
function ask_for_input() {
  # Clear input buffer:
  while read -rn 1 -t 0.01; do :; done

  local input
  read -r input

  if [ -z "$input" ]; then
    input="$1"
    # Overwrite last line to output default value:
    printf >&2 "\e[1A\e[K%s\n" "$input"
  fi

  echo "$input"
}

# print [type]
function print() {
  case "$1" in
  info)
    # print info [text]
    echo "$2" | print_to_log_and_stdout "\n\e[1;36m" "\e[0m"
    ;;
  progress)
    # print progress [text]
    last_progress_message="$2"
    echo "$2" | print_to_log_and_stdout "\e[0;36m " "\e[0m"
    ;;
  progress-ok)
    # print progress-ok [optional text]
    if [ -n "$last_progress_message" ]; then
      local ok
      ok="$2"

      if [ -z "$ok" ]; then
        ok=" ✓"
      fi

      echo "$last_progress_message$ok" | print_to_log_and_stdout "\e[1A\e[K\e[0;36m " "\e[0m"
    fi
    ;;
  success)
    # print success [text]
    echo "$2" | print_to_log_and_stdout "\n\e[1;32m" "\e[0m\n"
    ;;
  hint)
    # print hint [text]
    echo "$2" | print_to_log_and_stdout "\e[0;32m" "\e[0m\n"
    ;;
  note)
    # print note [text]
    echo "$2" | print_to_log_and_stdout "\e[1;33mNOTE:\e[0m \e[0;33m" "\e[0m"
    ;;
  warn)
    # print warn [text]
    echo "$2" | print_to_log_and_stderr "\e[1;33mWARNING:\e[0m \e[0;33m" "\e[0m"
    ;;
  error)
    # print error [text]
    echo "$2" | print_to_log_and_stderr "\e[1;31mERROR:\e[0m \e[0;31m" "\e[0m"
    ;;
  select)
    # print select [text] [options] -- [option ...]
    #
    # Options:
    # --default   Default value
    # --hint      Hint
    local default hint options
    extract_arguments --valid="default hint" --rest="options" -- "${@:3}"

    echo "$2" | print_to_log_and_stderr "\e[1;35m " "\e[0m"

    if [ -n "$hint" ]; then
      echo "$hint" | print_to_log_and_stderr "\e[0;35m " "\e[0m"
    fi

    ask_for_selection "$default" "${options[@]}" | print_to_log_and_stdout
    ;;
  input)
    # print input [text] [options]
    #
    # Options:
    # --default   Default value
    # --hint      Hint
    local default hint
    extract_arguments --valid="default hint" -- "${@:3}"

    local text
    text="$2"

    if [ -n "$default" ]; then
      text="$text [$default]"
    fi

    echo "$text" | print_to_log_and_stderr "\e[1;35m " "\e[0m"

    if [ -n "$hint" ]; then
      echo "$hint" | print_to_log_and_stderr "\e[0;35m " "\e[0m"
    fi

    ask_for_input "$default" | print_to_log_and_stdout
    ;;
  command)
    # print command [text]
    echo "$2" | print_to_log "\e[1m$ " "\e[0m"
    ;;
  command-out)
    # print command-out
    # Reads from stdin
    print_to_log
    ;;
  command-err)
    # print command-err
    # Reads from stdin
    print_to_log_and_stderr "\e[0;31m" "\e[0m"
    ;;
  command-end)
    # print command-end
    echo "---------- CMD END ----------" | print_to_log "\e[0;37m" "\e[0m"
    ;;
  *)
    echo "Unexpected print formatting parameter \"$1\"" | print_to_log_and_stderr "\e[0;31m" "\e[0m"
    return 1
    ;;
  esac

  if [ "$1" != "progress" ]; then
    unset last_progress_message
  fi
}
