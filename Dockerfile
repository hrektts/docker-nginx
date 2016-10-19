FROM hrektts/debian:8.6.20160926
MAINTAINER mps299792458@gmail.com

ENV NGINX_VERSION 1.10.2-1~dotdeb+8.1

RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys E9C74FEEA2098A6E \
 && echo "deb http://packages.dotdeb.org jessie all" \
    > /etc/apt/sources.list.d/nginx-dotdeb-jessie.list \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    nginx-extras=${NGINX_VERSION} \
    gettext-base \
 && rm -rf /var/lib/apt/lists/*

RUN ln -sf /dev/stdout /var/log/nginx/access.log \
 && ln -sf /dev/stderr /var/log/nginx/error.log

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

WORKDIR /etc/nginx

EXPOSE 80 443
ENTRYPOINT ["/sbin/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
