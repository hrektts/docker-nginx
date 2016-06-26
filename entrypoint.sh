#!/bin/bash
set -e

NGINX_WORKERS=${NGINX_WORKERS:-1}

cat <<EOF > /etc/nginx/nginx.conf
user www-data;
worker_processes ${NGINX_WORKERS};
worker_rlimit_nofile 100000;
pid /var/run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
    worker_connections 65536;
    multi_accept on;
    use epoll;
}

http {
    server_tokens off;
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 10;
    types_hash_max_size 2048;
    client_header_timeout 10;
    client_body_timeout 10;
    reset_timedout_connection on;
    send_timeout 10;

    limit_conn_zone \$binary_remote_addr zone=addr:5m;
    limit_conn addr 100;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    charset UTF-8;

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers on;

    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    gzip on;
    gzip_disable "msie6";
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_http_version 1.1;
    gzip_min_length 1024;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    open_file_cache max=100000 inactive=20s;
    open_file_cache_valid 30s;
    open_file_cache_min_uses 2;
    open_file_cache_errors on;

    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
EOF

exec "$@"
