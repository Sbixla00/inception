FROM alpine:3.22

RUN apk add --no-cache redis tini

# Create redis user and directory
RUN mkdir -p /var/lib/redis /var/log/redis \
 && chown -R redis:redis /var/lib/redis /var/log/redis

COPY conf/redis.conf /etc/redis.conf
COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 6379

ENTRYPOINT ["/sbin/tini","--","/entrypoint.sh"]
