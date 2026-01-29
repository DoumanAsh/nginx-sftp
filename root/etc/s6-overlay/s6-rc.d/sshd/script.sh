#!/bin/sh

USER_NAME=${USER_NAME:-defaultuser}

for i in /config/ssh_host_keys/ssh_host_*_key; do
    SSH_HOST_KEYS="${SSH_HOST_KEYS} -h ${i}"
done

/command/exec 2>&1 \
    s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z localhost ${LISTEN_PORT:-2222}" \
        /command/s6-setuidgid "${USER_NAME}" /usr/sbin/sshd.pam -D -e -f /config/sshd/sshd_config ${SSH_HOST_KEYS}
