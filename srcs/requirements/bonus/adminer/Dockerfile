FROM alpine:3.22

ARG ADMINER_VERSION=4.8.1

RUN apk add --no-cache \
    php83 php83-session \
    php83-mysqli php83-pgsql \
    php83-pdo php83-pdo_mysql php83-pdo_pgsql \
    php83-mbstring php83-xml php83-openssl \
    php83-json php83-curl \
    ca-certificates curl

# Download Adminer
RUN mkdir -p /var/www/html \
 && curl -fsSL "https://github.com/vrana/adminer/releases/download/v${ADMINER_VERSION}/adminer-${ADMINER_VERSION}.php" \
    -o /var/www/html/index.php

WORKDIR /var/www/html

# Adminer over HTTP (pick any port you want, e.g. 8080)
EXPOSE 8080

# PHP built-in web server
ENTRYPOINT ["php83", "-S", "0.0.0.0:8080", "-t", "/var/www/html"]
