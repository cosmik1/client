#!/usr/bin/env bash

# run [command] [argument ...]
function run() {
  # run_command [command] [argument ...]
  # NOTE: Due to two streams, the output is not in a deterministic order.
  function run_command() {
    # Remove named pipes if maybe exist:
    rm -f /tmp/runOut /tmp/runErr

    # Create named pipes:
    mkfifo /tmp/runOut /tmp/runErr

    # Write "runOut" pipe as "command-out" and "runErr" pipe as "command-err"
    local pid_out pid_err
    print command-out </tmp/runOut &
    pid_out=$!
    print command-err </tmp/runErr &
    pid_err=$!

    # Evaluate command and write STDOUT and STDERR to named pipes:
    local status_eval
    (eval "$@" >/tmp/runOut 2>/tmp/runErr)
    status_eval=$?

    # Wait for output:
    wait $pid_out $pid_err

    # Remove named pipes:
    rm -f /tmp/runOut /tmp/runErr

    return $status_eval
  }

  print command "$*"

  local status_eval
  run_command "$@"
  status_eval=$?

  print command-end

  return $status_eval
}
