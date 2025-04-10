#!/usr/bin/env bash

# extract_arguments [options] -- [string to parse ...]
#
# Options:
# --valid   Space separated names of variable/argument name
# --rest    Variable name for the rest parameter (content after --)
function extract_arguments() {
  # extract [valid] [rest] [string to parse ...]
  function extract() {
    local valid_arg_names="$1"
    local rest_name="$2"
    shift 2

    while [ $# -gt 0 ]; do
      local arg_name="${1%%=*}"

      if [ "${arg_name}" == "--" ]; then
        if [ -z "${rest_name}" ]; then
          print error "Parameter --rest missing"
          return 1
        fi

        shift

        local -n value_ref="${rest_name}"
        value_ref=("$@")

        return 0
      fi

      local value="${1#*=}"
      shift

      if [ "${arg_name:0:2}" != "--" ]; then
        print error "Wrong argument $arg_name"
        continue
      fi

      # shellcheck disable=SC2086
      if ! in_list "${arg_name:2}" $valid_arg_names; then
        print error "Unknown argument $arg_name"
        continue
      fi

      local -n value_ref="${arg_name:2}"
      value_ref="$value"
    done
  }

  extract "valid rest" "restvalue" "$@"

  local valid_local="$valid"
  unset valid

  local rest_local="$rest"
  unset rest

  local restvalue_local=("${restvalue[@]}")
  unset restvalue

  extract "$valid_local" "$rest_local" "${restvalue_local[@]}"
}
