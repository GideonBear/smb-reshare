FROM debian:13.2@sha256:c71b05eac0b20adb4cdcc9f7b052227efd7da381ad10bb92f972e8eae7c6cdc9

RUN apt-get update \
    && apt-get install -y samba cifs-utils \
    && rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man \
    && apt-get clean
RUN mkdir /mnt/remotedir
RUN chmod 777 /mnt/remotedir
RUN touch /etc/win-credentials
RUN chown root /etc/win-credentials
RUN chmod 600 /etc/win-credentials

COPY entrypoint.sh /usr/bin
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
