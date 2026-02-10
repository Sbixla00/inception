FROM alpine:3.22

RUN apk add --no-cache nginx tini

# Create nginx user and directories
RUN mkdir -p /var/www/static /run/nginx

# Copy static website files
COPY conf/nginx.conf /etc/nginx/http.d/default.conf
COPY website/ /var/www/static/

EXPOSE 80

ENTRYPOINT ["/sbin/tini","--","/usr/sbin/nginx","-g","daemon off;"]
