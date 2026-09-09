#!/bin/sh
set -euo pipefail

HTTP_SERVE_FOLDER_RETENTION_DAYS="${HTTP_SERVE_FOLDER_RETENTION_DAYS:-0}"
if [[ -n "$HTTP_SERVE_FOLDER" ]] && [[ -d "$HTTP_SERVE_FOLDER" ]] && [ "$HTTP_SERVE_FOLDER_RETENTION_DAYS" -ne "0" ]; then
    CLEAN_PATH="${HTTP_SERVE_FOLDER:=/config}"
    INTERVAL="${CLEANUP_INTERVAL_SECS:-86400}"

    echo "### Configure cleanup daemon onto $CLEAN_PATH with retention $HTTP_SERVE_FOLDER_RETENTION_DAYS days with $INTERVAL seconds interval"
    while true; do
        sleep "${INTERVAL}"
        find "${CLEAN_PATH}" -maxdepth 1 -type f -mtime +"${HTTP_SERVE_FOLDER_RETENTION_DAYS}" -print -delete > /dev/null 2>&1 || true
    done
else
    # No folder configured to serve, so assume nothing to clean up and stop service
    s6-svc -O .
    exit 0
fi
