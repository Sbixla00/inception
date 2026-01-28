FROM alpine:3.22

# 1) Install php-fpm + needed PHP extensions + tools
RUN apk add --no-cache \
    php83 php83-fpm \
    php83-mysqli \
    php83-phar php83-iconv php83-mbstring php83-json \
    php83-curl php83-openssl \
    curl tar mariadb-client tini

# 2) Configure php-fpm to listen on the network (nginx is in another container)
# TODO: change listen from 127.0.0.1:9000 (or socket) to 0.0.0.0:9000
RUN sed -i 's|^listen = .*|listen = 0.0.0.0:9000|' /etc/php83/php-fpm.d/www.conf

# 3) Install WP-CLI (from official phar) into PATH
RUN curl -fsSL -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
 && chmod +x /usr/local/bin/wp

WORKDIR /var/www/html

# 4) Entrypoint does: wait db → download WP → wp-config → wp core install → create users → start php-fpm
COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["/sbin/tini","--","/entrypoint.sh"]
