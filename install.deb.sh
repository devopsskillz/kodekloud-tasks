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

ansible_deploy() {
    ROOT_DIR="${BASH_SOURCE%/*}"
    ANSIBLE_VERSION='2.9.9'
    ANSIBLE_CONFIG="$ROOT_DIR/conf/ansible.cfg"
    ANSIBLE_INVENTORY="$ROOT_DIR/conf/hosts"
    ANSIBLE_VAULT_PASS="$ROOT_DIR/conf/.vault_pass"
    ANSIBLE_INSTALLED=$(dpkg-query -W --showformat='${Status}\n' ansible | grep "install ok installed")
    if [ -z "$ANSIBLE_INSTALLED" ]; then
        pgreen "Installing Ansible..." && \
        apt-get update 2>/dev/null && \
        apt-get --force-yes -qq install software-properties-common 2>/dev/null && \
        apt-add-repository -y --update ppa:ansible/ansible 2>/dev/null && \
        apt-get --force-yes -qq install ansible="$ANSIBLE_VERSION*" 2>/dev/null || \
        abort "Failed to install Ansible."
    fi
    if [ -e "$ANSIBLE_CONFIG" ]; then
        cp -fu $ANSIBLE_CONFIG '/etc/ansible/' 2>/dev/null || \
        abort "Failed to copy Ansible configuration."
    fi
    if [ -e "$ANSIBLE_INVENTORY" ]; then
        cp -fu $ANSIBLE_INVENTORY '/etc/ansible/' 2>/dev/null || \
        abort "Failed to copy Ansible inventory."
    fi
    if [ -e "$ANSIBLE_VAULT_PASS" ]; then
      cp -fu $ANSIBLE_VAULT_PASS '/etc/ansible/' 2>/dev/null || \
      pred "Failed to copy Ansible vault password file."
    fi
}

# Deploy control node
if ansible_deploy; then
  succeed "Ansible has been installed successfully on this node."
else
  abort "Ansible installation has failed."
fi
