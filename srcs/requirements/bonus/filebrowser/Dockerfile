FROM alpine:3.22

RUN apk add --no-cache curl

RUN curl -fsSL https://github.com/filebrowser/filebrowser/releases/latest/download/linux-amd64-filebrowser.tar.gz \
    -o filebrowser.tgz \
 && tar -xzf filebrowser.tgz \
 && mv filebrowser /usr/local/bin/filebrowser \
 && chmod +x /usr/local/bin/filebrowser \
 && rm filebrowser.tgz

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
