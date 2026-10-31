FROM debian:13.7@sha256:4c25275446ca371766b8b093c696782eabce06263fccacb8d5d813b3dc44b308

# renovate: suite=trixie depName=samba
ENV SAMBA_VERSION="2:4.22.11+dfsg-0+deb13u1"
# renovate: suite=trixie depName=smbclient
ENV SMBCLIENT_VERSION="2:4.22.11+dfsg-0+deb13u1"
# renovate: suite=trixie depName=cifs-utils
ENV CIFSUTILS_VERSION="2:7.4-1"
# renovate: suite=trixie depName=adduser
ENV ADDUSER_VERSION="3.152"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        samba=${SAMBA_VERSION} \
        # For healthcheck \
        smbclient=${SMBCLIENT_VERSION} \
        cifs-utils=${CIFSUTILS_VERSION} \
        adduser=${ADDUSER_VERSION} \
    && rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man \
    && apt-get clean \
    && mkdir /mnt/remotedir \
    && chmod 777 /mnt/remotedir \
    && touch /etc/win-credentials \
    && chown root /etc/win-credentials \
    && chmod 600 /etc/win-credentials

COPY entrypoint.sh healthcheck.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh /usr/bin/healthcheck.sh
HEALTHCHECK --interval=30s --timeout=15s --start-period=30s --retries=3 CMD ["healthcheck.sh"]
ENTRYPOINT ["entrypoint.sh"]
