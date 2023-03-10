#!/usr/bin/env bash
if [ "$1" == "squid" ]; then
  shift
  set -- /usr/sbin/squid "$@"
elif [ "${1:0:1}" = '-' ]; then
 set -- /usr/sbin/squid "$@"
fi
exec "$@"
