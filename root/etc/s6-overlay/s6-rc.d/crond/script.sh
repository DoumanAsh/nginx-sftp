#!/bin/sh

if [ "$LOG_STDOUT" == "true" ]; then
    exec crond -f
else
    exec crond -f -L /dev/null
fi
