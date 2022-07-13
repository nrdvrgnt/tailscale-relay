FROM python:3-alpine AS builder

RUN pip install lastversion
ARG CHANNEL=stable
ARG ARCH=amd64
RUN mkdir /build
WORKDIR /build
RUN apk add --no-cache curl tar
ADD "https://www.random.org/cgi-bin/randbyte?nbytes=10&format=h" /tmp/bustcache
RUN VER=$(lastversion https://github.com/tailscale/tailscale) \
    && echo $VER && curl -vsLo tailscale.tar.gz "https://pkgs.tailscale.com/${CHANNEL}/tailscale_${VER}_${ARCH}.tgz" && \
    tar xvf tailscale.tar.gz && \
    mv "tailscale_${VER}_${ARCH}/tailscaled" . && \
    mv "tailscale_${VER}_${ARCH}/tailscale" .


FROM alpine:3

ENV LOGINSERVER=https://controlplane.tailscale.com

RUN apk add --no-cache iptables

ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini.sha256sum /tini.sha256sum
RUN echo "$(cat /tini.sha256sum)" | sha256sum -c && chmod +x /tini

COPY --from=builder /build/tailscale /usr/bin/
COPY --from=builder /build/tailscaled /usr/bin/

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/tini", "--", "/bin/sh", "/entrypoint.sh"]
