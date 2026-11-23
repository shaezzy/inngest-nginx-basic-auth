FROM nginx:alpine AS runtime

ENV PROXY_PASS=http://host.docker.internal:3000 \
    PORT=4000

RUN apk add --no-cache openssl
COPY nginx.conf.template /etc/nginx/nginx.conf.template
COPY gen_passwd.sh /docker-entrypoint.d/40-configure-proxy.sh
RUN chmod +x /docker-entrypoint.d/40-configure-proxy.sh

EXPOSE 4000
