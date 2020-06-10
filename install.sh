#!/bin/bash
set -eu -o pipefail

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

# Check if run as root
if ! [ $(id -u) = 0 ]; then
   abort "The script needs to be run with sudo privilegies."
fi

ans_deploy() {
    ROOT_DIR="${BASH_SOURCE%/*}"
    ANS_OK=$(dpkg-query -W --showformat='${Status}\n' ansible | grep "install ok installed")
    ANS_VER='2.9.9'
    ANS_CFG="$ROOT_DIR/conf/ansible.cfg"
    ANS_INV="$ROOT_DIR/conf/hosts"
    if [ "" == "$ANS_OK" ]; then
        pgreen "Installing Ansible..."
        apt-get update
        apt-get --force-yes --yes install software-properties-common
        apt-add-repository --yes --update ppa:ansible/ansible
        apt-get --force-yes --yes install ansible=$ANS_VER
    fi    
    if [ -e "$ANS_CFG" ]; then
        cp -fu $ANS_CFG '/etc/ansible/'
    fi
    if [ -e "$ANS_INV" ]; then
        cp -fu $ANS_INV '/etc/ansible/'
    fi
}

# Deploy control node
if ans_deploy 2>/dev/null ; then
  succeed "Ansible was deployed successfully on this node."
else
  abort "Ansible deploying has failed."
fi
