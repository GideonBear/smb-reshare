FROM debian:13.7@sha256:913f6706df59a68922d1dd08f78c2476560a8d367897200a6005b00e5f67c2d5

# renovate: suite=trixie depName=samba
ENV SAMBA_VERSION="2:4.22.11+dfsg-0+deb13u1"
# renovate: suite=trixie depName=cifs-utils
ENV CIFSUTILS_VERSION="2:7.4-1"
# renovate: suite=trixie depName=adduser
ENV ADDUSER_VERSION="3.152"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        samba=${SAMBA_VERSION} \
        cifs-utils=${CIFSUTILS_VERSION} \
        adduser=${ADDUSER_VERSION} \
    && rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man \
    && apt-get clean \
    && mkdir /mnt/remotedir \
    && chmod 777 /mnt/remotedir \
    && touch /etc/win-credentials \
    && chown root /etc/win-credentials \
    && chmod 600 /etc/win-credentials

COPY entrypoint.sh /usr/bin
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
