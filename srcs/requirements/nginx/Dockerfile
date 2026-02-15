FROM alpine:3.22

RUN apk add --no-cache nginx openssl

# SSL folder + nginx runtime folder
RUN mkdir -p /etc/nginx/ssl /run/nginx

COPY conf/default.conf /etc/nginx/http.d/default.conf
COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 443

ENTRYPOINT ["/entrypoint.sh"]
