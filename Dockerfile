FROM debian:13.2@sha256:ea3a08b77d2d4403b17a88ede837ae147d053c971d09a278749792336c5a7606

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
