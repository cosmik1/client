#!/usr/bin/env bash

source "$BASE_DIR/client/scripts/default/source-in-list.sh"

imported=("in-list")

search_dirs=(
  "$BASE_DIR/client/scripts"
  "$BASE_DIR/client/scripts/base"
  "$BASE_DIR/client/scripts/default"
)

# include [source file ...]
function include() {
  for import in "$@"; do
    if ! in_list "$import" "${imported[@]}"; then
      local found
      found=false

      for dir in "${search_dirs[@]}"; do
        if [[ -f "$dir/source-$import.sh" ]]; then
          # shellcheck source=/dev/null
          source "$dir/source-$import.sh"
          found=true
          break
        fi
      done

      if [[ "$found" = false ]]; then
        echo "Couldn't find source for $import" >&2
        exit 1
      fi

      imported+=("$import")
    fi
  done
}

include print "$@"
