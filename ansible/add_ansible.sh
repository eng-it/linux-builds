#!/usr/bin/env bash
path=$(dirname $(readlink -e "$BASH_SOURCE"))
export ANSIBLE_CONFIG="$path/ansible.cfg"
export ANSIBLE_HOSTS="$HOME/ansible/hosts"
if [ -d "$HOME/ansible/inventory" ]
then
	export ANSIBLE_HOSTS="$HOME/ansible/inventory"
fi
export PATH="$path/ansible-bin:$PATH"
