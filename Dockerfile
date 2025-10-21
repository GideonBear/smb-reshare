FROM debian:13.1@sha256:72547dd722cd005a8c2aa2079af9ca0ee93aad8e589689135feaed60b0a8c08d

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
