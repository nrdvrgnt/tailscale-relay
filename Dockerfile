FROM python:3-alpine AS builder

RUN pip install lastversion
ARG CHANNEL=stable
ARG ARCH=amd64
RUN mkdir /build
WORKDIR /build
RUN apk add --no-cache curl tar
RUN VER=$(lastversion https://github.com/tailscale/tailscale) \
    && echo $VER && curl -vsLo tailscale.tar.gz "https://pkgs.tailscale.com/${CHANNEL}/tailscale_${VER}_${ARCH}.tgz" && \
    tar xvf tailscale.tar.gz && \
    mv "tailscale_${VER}_${ARCH}/tailscaled" . && \
    mv "tailscale_${VER}_${ARCH}/tailscale" .

FROM alpine:3.12

ENV LOGINSERVER=https://login.tailscale.com

RUN apk add --no-cache iptables

COPY --from=builder /build/tailscale /usr/bin/
COPY --from=builder /build/tailscaled /usr/bin/

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/bin/sh", "/entrypoint.sh"]