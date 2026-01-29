#!/bin/sh

USER_NAME=${USER_NAME:-defaultuser}

/command/exec 2>&1 /command/s6-setuidgid "${USER_NAME}" nginx -c /config/nginx/nginx.conf -e /config/logs/nginx/error.log
