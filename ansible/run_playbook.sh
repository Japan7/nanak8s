#!/bin/bash

# some helpers
die() {
	echo -e " ${NOCOLOR-\e[1;31m*\e[0m }${*}" >&2
	exit 1
}

einfo() {
	echo -e " ${NOCOLOR-\e[1;32m*\e[0m }${*}" >&2
}

ewarn() {
	echo -e " ${NOCOLOR-\e[1;33m*\e[0m }${*}" >&2
}

usage() {
    die "USAGE: $0 HOSTNAME PLAYBOOK_NAME"
}

[ -z "$1" ] && usage
[ -z "$2" ] && usage

if [ "$1" = "localhost" ]; then
    [ "$2" = reboot ] && die "You shouldn't run the reboot playbook on localhost"
    args="--connection=local -i 127.0.0.1 -l 127.0.0.1"
else
    args="-i $1,"
fi

playbook="$2.yml"
[ -f "$playbook" ] || die "The playbook $playbook doesn't exist"

ansible-playbook --diff $args "$playbook"
