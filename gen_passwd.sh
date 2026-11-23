#!/bin/sh
set -eu

: "${DASHBOARD_USERNAME:?Set DASHBOARD_USERNAME}"
: "${DASHBOARD_PASSWORD:?Set DASHBOARD_PASSWORD}"
: "${INNGEST_SIGNING_KEY:?Set INNGEST_SIGNING_KEY}"

# Values interpolated into nginx syntax must not contain config delimiters.
case "$INNGEST_SIGNING_KEY" in
  *[!a-zA-Z0-9_-]*) echo "Invalid INNGEST_SIGNING_KEY format" >&2; exit 1 ;;
esac
case "$DASHBOARD_USERNAME" in
  *:*|*'
'*) echo "Invalid DASHBOARD_USERNAME format" >&2; exit 1 ;;
esac

umask 077
CRYPTPASS=$(printf '%s' "$DASHBOARD_PASSWORD" | openssl passwd -apr1 -stdin)
printf '%s:%s\n' "$DASHBOARD_USERNAME" "$CRYPTPASS" > /etc/nginx/.htpasswd
# Workers need to read the password file; only root reads the signing-key config.
chown root:nginx /etc/nginx/.htpasswd
chmod 640 /etc/nginx/.htpasswd
envsubst '$PROXY_PASS $PORT $INNGEST_SIGNING_KEY' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf
nginx -t
