#!/bin/sh
[ -z "$1" ] && echo "usage: $0 HOSTNAME" && exit 1
ansible-playbook --diff -i "$1," main.yml
