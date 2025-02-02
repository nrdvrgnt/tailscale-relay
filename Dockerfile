FROM python:3 AS builder

RUN pip install lastversion
ARG CHANNEL=stable
ARG ARCH=amd64
RUN mkdir /build
WORKDIR /build
RUN apt-get update && apt-get install -y curl tar
ADD "https://www.random.org/cgi-bin/randbyte?nbytes=10&format=h" /tmp/bustcache

RUN VER=$(lastversion https://github.com/mullvad/mullvadvpn-app) \
    && echo $VER &&\
    curl -L -o mullvadvpn.deb https://mullvad.net/download/app/deb/latest && \ 
    ls -a &&\
    echo apt-get install ./mullvadvpn.deb

RUN VER=$(lastversion https://github.com/tailscale/tailscale) \
    && echo $VER && curl -vsLo tailscale.tar.gz "https://pkgs.tailscale.com/${CHANNEL}/tailscale_${VER}_${ARCH}.tgz" && \
    tar xvf tailscale.tar.gz && \
    mv "tailscale_${VER}_${ARCH}/tailscaled" . && \
    mv "tailscale_${VER}_${ARCH}/tailscale" .

FROM krallin/ubuntu-tini:latest

ENV LOGINSERVER=https://controlplane.tailscale.com

RUN apt-get update && apt-get install -y iptables

RUN apt-get update && apt-get install -y tini
# Tini is now available at /usr/local/bin/tini

COPY --from=builder /build/tailscale /usr/bin/
COPY --from=builder /build/tailscaled /usr/bin/

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/usr/local/bin/tini", "--", "/bin/sh", "/entrypoint.sh"]
