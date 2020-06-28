#!/bin/bash
set -eu -o pipefail
ROOT_DIR="${BASH_SOURCE%/*}"
source "$ROOT_DIR/scripts/utils.sh"

ansible_deploy() {
    ANSIBLE_CONFIG="$ROOT_DIR/conf/ansible.cfg"
    ANSIBLE_INVENTORY="$ROOT_DIR/conf/hosts"
    ANSIBLE_VAULT_PASS='k0d3kl0ud'
    ANSIBLE_VAULT_PASS_FILE="$ROOT_DIR/conf/.vault_pass"
    ANSIBLE_INSTALLED=$(dpkg-query -W --showformat='${Status}\n' ansible | grep "install ok installed")
    if [ -z "$ANSIBLE_INSTALLED" ]; then
        pgreen "Installing Ansible..." && \
        apt-get update && \
        apt-get --force-yes -qq install software-properties-common && \
        apt-add-repository -y --update ppa:ansible/ansible && \
        apt-get --force-yes -qq install ansible && \
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
