FROM alpine:3.22

# Install PHP-FPM and required extensions for Adminer
RUN apk add --no-cache \
    php83 php83-fpm \
    php83-session php83-mysqli php83-pgsql \
    php83-pdo php83-pdo_mysql php83-pdo_pgsql \
    php83-mbstring php83-xml php83-openssl \
    php83-json php83-curl \
    curl tini

# Create web root + runtime dir (php-fpm uses /run/php)
RUN mkdir -p /var/www/html /run/php \
 && chown -R nobody:nobody /var/www/html /run/php

# Configure php-fpm to listen on network
RUN sed -i 's|^listen = .*|listen = 0.0.0.0:9000|' /etc/php83/php-fpm.d/www.conf

# Download Adminer
RUN curl -fsSL https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php \
    -o /var/www/html/index.php \
 && chown -R nobody:nobody /var/www/html

WORKDIR /var/www/html
EXPOSE 9000

ENTRYPOINT ["/sbin/tini","--","/usr/sbin/php-fpm83","-F"]
