#!/usr/bin/env bash

# Source all scripts in bash/ directory in lexical order.
# Numeric prefixes control ordering (e.g., 10-*, 20-*).

RV_PROJECT_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BASH_DIR="$RV_PROJECT_ROOT/bash"

if [[ -d "$BASH_DIR" ]]; then
  shopt -s nullglob
  files=( "$BASH_DIR"/*.bash "$BASH_DIR"/*.sh )
  # Sort files lexicographically and source in order
  if ((${#files[@]})); then
    IFS=$'\n' read -r -d '' -a sorted < <(printf '%s\n' "${files[@]}" | LC_ALL=C sort && printf '\0')
    for f in "${sorted[@]}"; do
      [[ -r "$f" ]] && source "$f"
    done
  fi
  shopt -u nullglob
fi
