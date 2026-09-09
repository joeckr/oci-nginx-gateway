#!/bin/bash
set -e

envsubst '${NGINX_RESOLVER}' < /usr/local/openresty/nginx/conf/nginx.conf.template > /usr/local/openresty/nginx/conf/nginx.conf
envsubst '${NGINX_RESOLVER}' < /etc/nginx/conf.d/oidc.conf.template > /etc/nginx/conf.d/oidc.conf

exec /usr/local/openresty/bin/openresty -g 'daemon off;'
