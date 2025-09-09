FROM debian:13.1@sha256:833c135acfe9521d7a0035a296076f98c182c542a2b6b5a0fd7063d355d696be

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
