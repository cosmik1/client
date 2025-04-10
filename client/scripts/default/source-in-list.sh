#!/usr/bin/env bash

# in_list [needle] [haystack ...]
function in_list() {
  local needle="$1"
  shift

  for item in "$@"; do
    if [ "$item" = "$needle" ]; then
      return 0
    fi
  done

  return 1
}
