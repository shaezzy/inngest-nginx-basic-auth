FROM nginx:alpine AS runtime

ARG PROXY_PASS=http://host.docker.internal:3000
ARG PORT=4000
ARG DASHBOARD_USERNAME=user
ARG DASHBOARD_PASSWORD=password

RUN echo "proxy_pass: $PROXY_PASS\nport: $PORT\nusername: $DASHBOARD_USERNAME\npassword: $DASHBOARD_PASSWORD"

COPY ./nginx.conf.template /etc/nginx/nginx.conf.template
RUN envsubst '$PROXY_PASS $PORT' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf


ENV DASHBOARD_USERNAME=$DASHBOARD_USERNAME
ENV DASHBOARD_PASSWORD=$DASHBOARD_PASSWORD
RUN apk add --no-cache openssl
COPY ./gen_passwd.sh /etc/nginx/gen_passwd.sh
RUN ["chmod", "+x", "/etc/nginx/gen_passwd.sh"]
RUN /etc/nginx/gen_passwd.sh
EXPOSE ${PORT}