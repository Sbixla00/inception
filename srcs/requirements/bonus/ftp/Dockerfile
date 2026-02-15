FROM alpine:3.22

RUN apk add --no-cache vsftpd tini

COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 21 21100-21110

ENTRYPOINT ["/sbin/tini","--","/entrypoint.sh"]
