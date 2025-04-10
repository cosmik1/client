#!/usr/bin/env bash

# print_help [command]
function print_help() {
  local command="$1"

  description=$(yq e '.description' -<<< "${COSMIK_YAML[$command]}")
  formatted_subcommand=$(printf "%-32s %s" "$command" "$description")
  print info "$formatted_subcommand"

  targets=$(yq e '.targets | keys' -<<< "${COSMIK_YAML[$command]}" | sed 's/- //g')

  for target in $targets; do
    description=$(yq e ".targets.$target.description" -<<< "${COSMIK_YAML[$command]}")
    formatted_description=$(printf "%-32s %s" "$target" "$description")
    print progress "$formatted_description"
  done
}

# get_command_name [filename]
function get_command_name() {
  local filename
  filename=$(basename "$1" .yaml)
  echo "${filename#*_}"
}
