#!/bin/bash
set -eu -o pipefail
ROOT_DIR=$(dirname "$0")
source "$ROOT_DIR/utils.sh"

ansible_deploy() {
    ANSIBLE_VERSION='2.9.9'
    ANSIBLE_CONFIG="$ROOT_DIR/conf/ansible.cfg"
    ANSIBLE_INVENTORY="$ROOT_DIR/conf/hosts"
    ANSIBLE_VAULT_PASS='k0d3kl0ud'
    ANSIBLE_VAULT_PASS_FILE="$ROOT_DIR/conf/.vault_pass"
    ANSIBLE_INSTALLED=$(rpm -qa ansible)
    EPEL_INSTALLED=$(rpm -qa epel-release)
    if [ -z $EPEL_INSTALLED ]; then
        pgreen "Installing EPEL repo..." && \
        yum -y -q install epel-release && \
        pgreen "EPEL repo has been installed successfully." || \
        abort "Failed to install EPEL repo."
    fi
    if [ -z $ANSIBLE_INSTALLED ]; then
        pgreen "Installing Ansible..." && \
        yum -y -q install ansible-$ANSIBLE_VERSION  && \
        pgreen "Ansible has been installed successfully." || \
        abort "Failed to install Ansible."
    fi
    if [ -e "$ANSIBLE_CONFIG" ]; then
        cp -fu $ANSIBLE_CONFIG '/etc/ansible/' && \
        pgreen "Ansible configuration has been pushed." || \
        abort "Failed to copy Ansible configuration."
    fi
    if [ -e "$ANSIBLE_INVENTORY" ]; then
        cp -fu $ANSIBLE_INVENTORY '/etc/ansible/' && \
        pgreen "Ansible inventory has been pushed." || \
        abort "Failed to copy Ansible inventory."
    fi
    if [ -e "$ANSIBLE_VAULT_PASS" ]; then
        cp -fu $ANSIBLE_VAULT_PASS '/etc/ansible/' && \
        pgreen "Ansible vault pass file has been pushed." || \
        pred "Failed to copy Ansible vault password file."
    else
        echo $ANSIBLE_VAULT_PASS > '/etc/ansible/.vault_pass'
    fi
}

# Check if run with sudo privilegies
check_root

# Deploy control node
if ansible_deploy; then
  succeed "Ansible control node has been deployed successfully."
else
  abort "Failed to deploy Ansible control node."
fi
