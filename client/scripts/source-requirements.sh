#!/usr/bin/env bash

# test_command [Command to check if it's available ...]
function test_command() {
  for command in "$@"; do
    print progress "Make sure $command is installed..."

    if ! command -v "$command" >/dev/null 2>&1; then
      print error "$command is not installed!"
      return 1
    fi

    print progress-ok
  done
}

function fix_version() {
  (
    IFS=. read -r major minor release <<<"$1"

    if [ "$minor" = "" ]; then
      minor="0"
    fi

    if [ "$release" = "" ]; then
      release="0"
    fi

    echo "$major.$minor.$release"
  )
}

# test_version [command] [version to test against] [actual version] [options]
#
# Options:
# --operator    "lte" (default) or "gt"
function test_version() {
  local command versionCheck versionActual
  command="$1"
  versionCheck=$(fix_version "$2")
  versionActual=$(fix_version "$3")

  local operator
  operator="lte"
  extract_arguments --valid="operator" -- "${@:4}"

  case "$operator" in
  lte)
    print progress "Check for $command version $versionCheck or newer..."

    if ! verlte "$versionCheck" "$versionActual"; then
      print error "$command version $versionActual is incompatible!"
      return 1
    fi

    print progress-ok
    ;;
  gt)
    print progress "Check for $command version older than $versionCheck..."

    if ! vergt "$versionCheck" "$versionActual"; then
      print error "$command version $versionActual is incompatible!"
      return 1
    fi

    print progress-ok
    ;;
  *)
    print error "Unexpected value \"$operator\" for option --operator"
    return 1
    ;;
  esac
}

# Borrowed from https://stackoverflow.com/a/4024263/5337417
# verlte [version] [version]
function verlte() {
  [ "$1" = "$(echo -e "$1\n$2" | sort -V | head -n1)" ]
}

# vergt [version] [version]
function vergt() {
  if verlte "$1" "$2"; then
    return 1
  else
    return 0
  fi
}

# get_ip_from_hosts [hostname]
function get_ip_from_hosts() {
  local hostname_escaped
  hostname_escaped=$(echo "$1" | sed -r 's/([.^$\?*+{}])/\\\1/g')
  awk '/^[^#]+\s'"$hostname_escaped"'($|\s)/ {print $1}' </etc/hosts
}

# test_hosts [hostname ...]
function test_hosts() {
  local hostnames
  hostnames=("$@")
  print progress "Make sure all hostnames are configured..."

  while true; do
    local missing_hostnames
    missing_hostnames=()

    for hostname in "${hostnames[@]}"; do
      local ip
      ip=$(get_ip_from_hosts "$hostname")

      if [ -z "$ip" ]; then
        missing_hostnames+=("$hostname")
      fi
    done

    if [ "${#missing_hostnames[@]}" -gt 0 ]; then
      local answer
      answer=$(print select "Please add the following line to your /etc/hosts file" --hint="127.0.0.1 ${missing_hostnames[*]}" --default="Check again" -- "Ignore")

      if [ "$answer" = "Ignore" ]; then
        break
      fi
    else
      break
    fi
  done
}
