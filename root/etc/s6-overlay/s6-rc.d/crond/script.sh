#!/bin/sh

if [ "$LOG_STDOUT" == "true" ]; then
    exec crond -f -c /config/crontabs/
else
    exec crond -f -L /dev/null -c /config/crontabs/
fi
