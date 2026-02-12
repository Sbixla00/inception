FROM alpine:3.22

ARG PORTAINER_VERSION=2.21.5

RUN apk add --no-cache ca-certificates curl \
 && addgroup -S portainer \
 && adduser -S portainer -G portainer \
 && mkdir -p /data \
 && chown -R portainer:portainer /data \
 && curl -fsSL -o /tmp/portainer.tgz \
    "https://github.com/portainer/portainer/releases/download/${PORTAINER_VERSION}/portainer-${PORTAINER_VERSION}-linux-amd64.tar.gz" \
 && tar -xzf /tmp/portainer.tgz -C /tmp \
 && mv /tmp/portainer/portainer /usr/local/bin/portainer \
 && chmod +x /usr/local/bin/portainer \
 && rm -rf /tmp/portainer /tmp/portainer.tgz

USER portainer

EXPOSE 9000 9443

ENTRYPOINT ["/usr/local/bin/portainer"]
CMD ["--data", "/data"]
