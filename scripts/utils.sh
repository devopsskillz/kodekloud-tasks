#!/bin/bash

# Print colored text
pgreen() { echo >&1 -e "\e[32m$@\e[0m"; }
pred() { echo >&2 -e "\e[0;31m$@\e[0m"; }

# Abort script on error
abort() {
  if [[ -n $@ ]]; then
    pred "FAILED: $@"
  fi
  exit 1
}
# Script succeeded
succeed() {
  if [[ -n $@ ]]; then
    pgreen "SUCCEEDED: $@"
  fi
  exit 0
}

# Check if run with sudo privilegies
check_root() {
    if ! [ $(id -u) = 0 ]; then
    abort "The script needs to be run with sudo privilegies."
    fi
}
