#!/bin/sh

USER_NAME=${DASHBOARD_USERNAME}
PASSWD=${DASHBOARD_PASSWORD}

echo "Generating password for dashboard user ${USER_NAME}"

CRYPTPASS=`openssl passwd -apr1 ${PASSWD}`

echo "${USER_NAME}:${CRYPTPASS}" >> /etc/nginx/.htpasswd