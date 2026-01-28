FROM alpine:3.22

RUN apk add --no-cache mariadb mariadb-client tini

# Optional: ensure runtime dirs exist
RUN mkdir -p /run/mysqld /var/lib/mysql \
 && chown -R mysql:mysql /run/mysqld /var/lib/mysql

COPY conf/my.cnf /etc/my.cnf
COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 3306

ENTRYPOINT ["/sbin/tini","--","/entrypoint.sh"]
