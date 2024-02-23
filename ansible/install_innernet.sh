#!/bin/sh
[ -z "$1" ] && echo "usage: $0 HOSTNAME" && exit 1
if [ "$1" = "localhost" ]; then
    args="--connection=local -i 127.0.0.1 -l 127.0.0.1"
else
    args="-i $1,"
fi

ansible-playbook --diff $args -e force_install_innernet=true innernet.yml
