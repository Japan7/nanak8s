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

maindir="$(dirname "$0")"
envfile="${maindir}/.env"

if [ -e "${envfile}" ]; then
    einfo "sourcing ${envfile}"
    . "${envfile}"
else
    ewarn "${envfile} doesn't exist, not loading"
fi

usage() {
    die "USAGE: $0 HOSTNAME PLAYBOOK_NAME"
}

[ -z "$1" ] && usage
[ -z "$2" ] && usage

if [ "$1" = "localhost" ]; then
    [ "$2" = reboot ] && die "You shouldn't run the reboot playbook on localhost"
    args="--connection=local -i 127.0.0.1, -l 127.0.0.1"
else
    args="-i $1,"
fi

[ -n "${NANAK8S_IFACE}" ] && args="$args -e iface=${NANAK8S_IFACE}"
[ -n "${GARAGE_DATA_DIR}" ] && args="$args -e garage_data_dir=${GARAGE_DATA_DIR}"
[ -n "${GARAGE_CONFIG_PATH}" ] && args="$args -e garage_config_path=${GARAGE_CONFIG_PATH}"
if [ -n "${NANAK8S_NODE_TYPE}" ]; then
    if [ "${NANAK8S_NODE_TYPE}" = agent ] || [ "${NANAK8S_NODE_TYPE}" = "server" ]; then
        args="$args -e node_type=${NANAK8S_NODE_TYPE}"
    else
        die "node type can only be set to agent or server: found NANAK8S_NODE_TYPE=${NANAK8S_NODE_TYPE}"
    fi
fi

playbook="$2.yml"
[ -f "$playbook" ] || die "The playbook $playbook doesn't exist"

ansible-playbook --diff $args "$playbook"
