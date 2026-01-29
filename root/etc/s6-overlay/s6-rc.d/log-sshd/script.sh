#!/bin/sh

USER_NAME=${USER_NAME:-defaultuser}

if [ "$LOG_STDOUT" == "true" ]; then
    exec s6-setuidgid "${USER_NAME}" s6-log +.* 1
else
    exec s6-setuidgid "${USER_NAME}" s6-log n30 s10000000 S30000000 T !"gzip -nq9" /config/logs/sshd
fi
