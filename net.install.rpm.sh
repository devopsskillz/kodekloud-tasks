#!/bin/bash
set -eu -o pipefail
ROOT_DIR=$(dirname "$0")
PROJECT_DIR="$ROOT_DIR/kodekloud-tasks"

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

# Clone project from Github
project_clone() {
    GIT_READ_TOKEN='ee8a7b61937742312e23939d62005370176242b2'
    GIT_REPO='github.com/devopsskillz/kodekloud-tasks.git'
    pgreen "Clonning project from Github repo..." && \
    git clone https://$GIT_READ_TOKEN@$GIT_REPO $PROJECT_DIR && \
    pgreen "Project has been clonned succesfully." || \
    abort "Failed to clone from https://$GIT_REPO."
}

# Deploy project on host
project_deploy() {
    GIT_INSTALLED=$(rpm -qa git)
    if [ -z $GIT_INSTALLED ]; then
        pgreen "Installing Git..." && \
        yum -y -q install git && \
        pgreen "Git has been installed successfully." || \
        abort "Failed to install Git."
    fi
    project_clone
    source $PROJECT_DIR/scripts/install.rpm.sh
}

# Deploy Kodekloud tasks
if project_deploy; then
  succeed "Kodekloud tasks project has been deployed successfully."
else
  abort "Failed to deploy Kodekloud tasks project."
fi
