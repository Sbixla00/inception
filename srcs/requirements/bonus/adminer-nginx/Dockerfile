FROM alpine:3.22

RUN apk add --no-cache nginx tini

RUN mkdir -p /run/nginx /var/www/html

COPY conf/adminer.conf /etc/nginx/http.d/default.conf

EXPOSE 80

ENTRYPOINT ["/sbin/tini","--","/usr/sbin/nginx","-g","daemon off;"]
