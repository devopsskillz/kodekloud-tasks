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
    ANSIBLE_INSTALLED=$(rpm -qa ansible)
    EPEL_INSTALLED=$(rpm -qa epel-release)
    if [ -z $EPEL_INSTALLED ]; then
        pgreen "Installing EPEL repo..." && \
        yum -y -q install epel-release 2>/dev/null || \
        abort "Failed to install EPEL repo."
    fi
    if [ -z $ANSIBLE_INSTALLED ]; then
        pgreen "Installing Ansible..." && \
        yum -y -q install ansible-$ANSIBLE_VERSION 2>/dev/null || \
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
