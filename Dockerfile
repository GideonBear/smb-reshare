FROM debian:bookworm

RUN apt-get update \
    && apt-get install -y samba cifs-utils \
    && rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man \
    && apt-get clean
RUN mkdir /mnt/remotedir
RUN chmod 777 /mnt/remotedir
RUN touch /etc/win-credentials
RUN chown root /etc/win-credentials
RUN chmod 600 /etc/win-credentials
RUN cat <<EOF > /etc/samba/smb.conf
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
browsable = yes
writeable = yes
create mask = 777
directory mask = 777
EOF

COPY entrypoint.sh /usr/bin
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
