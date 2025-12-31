#!/bin/bash

set -euo pipefail
set -x

# The add_user function was mostly copied from https://github.com/dockur/samba
# (file: https://github.com/dockur/samba/blob/master/samba.sh). License below:

# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# This function checks for the existence of a specified Samba user and group. If the user does not exist,
# it creates a new user with the provided username, user ID (UID), group name, group ID (GID), and password.
# If the user already exists, it updates the user's UID and group association as necessary,
# and updates the password in the Samba database. The function ensures that the group also exists,
# creating it if necessary, and modifies the group ID if it differs from the provided value.
add_user() {
    local cfg="/etc/samba/smb.conf"
    local username="$1"
    local password="$2"

    # Check if the user already exists, if not, create it
    if ! id "$username" &>/dev/null; then
        [[ $username != "${USER-}" ]] && echo "User $username does not exist, creating user..."
        adduser --shell /sbin/nologin "$username" || {
            echo "Failed to create user $username"
            return 1
        }
    fi

    # Check if the user is a samba user
    pdb_output=$(pdbedit -s "$cfg" -L) #Do not combine the two commands into one, as this could lead to issues with the execution order and proper passing of variables.
    if echo "$pdb_output" | grep -q "^$username:"; then
        # skip samba password update if password is * or !
        if [[ $password != "*" && $password != "!" ]]; then
            # If the user is a samba user, update its password in case it changed
            echo -e "$password\n$password" | smbpasswd -c "$cfg" -s "$username" >/dev/null || {
                echo "Failed to update Samba password for $username"
                return 1
            }
        fi
    else
        # If the user is not a samba user, create it and set a password
        echo -e "$password\n$password" | smbpasswd -a -c "$cfg" -s "$username" >/dev/null || {
            echo "Failed to add Samba user $username"
            return 1
        }
        [[ $username != "${USER-}" ]] && echo "User $username has been added to Samba and password set."
    fi

    return 0
}

for var in OLD_USERNAME OLD_PASSWORD NEW_USERNAME NEW_PASSWORD; do
    val="${!var-}"
    file_var="${var}_FILE"
    file_val="${!file_var-}"

    if [ -z "$val" ]; then
        if [ -f "$file_val" ]; then
            export "$var"="$(cat "$file_val")"
        else
            echo "Error: $var and ${file_var} are unset or invalid." >&2
            exit 1
        fi
    fi
done

cat <<EOF >/etc/win-credentials
username=$OLD_USERNAME
password=$OLD_PASSWORD
domain=$OLD_DOMAIN
EOF

cat <<EOF >/etc/samba/smb.conf
[global]
map to guest = Bad User
log file = /var/log/samba/%m
log level = 1
hosts allow = 192.168.0.0/16
hosts deny = 0.0.0.0/0
passdb backend = smbpasswd
[remotedir]
path = /mnt/remotedir
read only = no
guest ok = no
guest only = no
public = no
valid users = $NEW_USERNAME
browsable = yes
writeable = yes
create mask = 777
directory mask = 777
EOF

mount -t cifs //"$OLD_HOST"/"$OLD_DIRECTORY" /mnt/remotedir -o uid=0,credentials=/etc/win-credentials,x-systemd.automount,file_mode=0777,dir_mode=0666,iocharset=utf8,vers=1.0,noperm || exit 1

add_user "$NEW_USERNAME" "$NEW_PASSWORD" || exit 1

exec smbd --foreground --debug-stdout --debuglevel=1 --no-process-group
