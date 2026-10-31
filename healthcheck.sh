#!/bin/bash

set -euo pipefail

if [ -z "${NEW_USERNAME-}" ]; then
    NEW_USERNAME="$(cat "$NEW_USERNAME_FILE")"
fi
if [ -z "${NEW_PASSWORD-}" ]; then
    NEW_PASSWORD="$(cat "$NEW_PASSWORD_FILE")"
fi
export USER="$NEW_USERNAME" PASSWD="$NEW_PASSWORD"

# Lists the share through smbd, which also checks the CIFS mount behind it
timeout 10 smbclient //127.0.0.1/remotedir -c ls >/dev/null
