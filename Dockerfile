FROM openresty/openresty:alpine-fat AS builder

RUN luarocks install lua-resty-http && \
    luarocks install lua-resty-session && \
    luarocks install lua-resty-openidc && \
    luarocks install lua-resty-jwt

FROM openresty/openresty:alpine-slim

COPY --from=builder /usr/local/openresty/luajit/share/lua/ /usr/local/openresty/luajit/share/lua/
COPY --from=builder /usr/local/openresty/luajit/lib/lua/ /usr/local/openresty/luajit/lib/lua/

RUN chmod -R a+rX /usr/local/openresty/lualib /usr/local/openresty/nginx/modules

RUN mkdir -p /tmp/nginx/{logs,client,fastcgi,proxy,scgi,uwsgi} /etc/nginx/oidc && \
    chgrp -R 0 /tmp/nginx /var/run/openresty /usr/local/openresty/nginx/logs && \
    chmod -R g+rwX /tmp/nginx /var/run/openresty /usr/local/openresty/nginx/logs /usr/local/openresty/nginx/conf /etc/nginx/conf.d

COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf.template
COPY oidc.conf /usr/local/openresty/nginx/conf/oidc.conf.template
COPY frontend.conf /etc/nginx/oidc/.
RUN rm -f /etc/nginx/conf.d/default.conf

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY index.html /usr/local/openresty/nginx/html/
RUN chmod -R a+r /usr/local/openresty/nginx/html/

USER 1031
ENTRYPOINT [ "/entrypoint.sh" ]
