#!/bin/sh

USER_NAME=${USER_NAME:-defaultuser}

if pgrep -f "[n]ginx:" >/dev/null; then
    echo "### Zombie nginx processes detected, sending SIGTERM"
    pkill -ef [n]ginx:
    sleep 1
fi

if pgrep -f "[n]ginx:" >/dev/null; then
    echo "### Zombie nginx processes still active, sending SIGKILL"
    pkill -9 -ef [n]ginx:
    sleep 1
fi

/command/exec 2>&1 /command/s6-setuidgid "${USER_NAME}" nginx -c /config/nginx/nginx.conf -e /config/logs/nginx/error.log
