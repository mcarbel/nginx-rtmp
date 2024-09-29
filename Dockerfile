FROM debian:buster

LABEL maintainer="Guillaume Seznec <guillaume@seznec.fr>"

# cf. https://github.com/nginx/nginx
ENV NGINX_VERSION=nginx-1.17.9
# cf. https://github.com/arut/nginx-rtmp-module
ENV NGINX_RTMP_MODULE_VERSION=1.2.1

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y wget build-essential libpcre3 libpcre3-dev zlib1g-dev libssl-dev && \
    apt-get install -y nano

# Download and decompress Nginx
RUN mkdir -p /tmp/build/nginx && \
    cd /tmp/build/nginx && \
    wget -O ${NGINX_VERSION}.tar.gz https://nginx.org/download/${NGINX_VERSION}.tar.gz && \
    tar -zxf ${NGINX_VERSION}.tar.gz

# Download and decompress RTMP module
RUN mkdir -p /tmp/build/nginx-rtmp-module && \
    cd /tmp/build/nginx-rtmp-module && \
    wget -O nginx-rtmp-module-${NGINX_RTMP_MODULE_VERSION}.tar.gz https://github.com/arut/nginx-rtmp-module/archive/v${NGINX_RTMP_MODULE_VERSION}.tar.gz && \
    tar -zxf nginx-rtmp-module-${NGINX_RTMP_MODULE_VERSION}.tar.gz && \
    cd nginx-rtmp-module-${NGINX_RTMP_MODULE_VERSION}

# Compilation nginx
RUN cd /tmp/build/nginx/${NGINX_VERSION} && \
    ./configure \
        --sbin-path=/usr/local/sbin/nginx \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --pid-path=/var/run/nginx/nginx.pid \
        --lock-path=/var/lock/nginx/nginx.lock \
        --http-log-path=/var/log/nginx/access.log \
        --http-client-body-temp-path=/tmp/nginx-client-body \
        --with-http_ssl_module \
        --with-threads \
        --add-module=/tmp/build/nginx-rtmp-module/nginx-rtmp-module-${NGINX_RTMP_MODULE_VERSION} \
        --with-cc-opt="-Wimplicit-fallthrough=0" && \
    make && \
    make install && \
    mkdir /var/lock/nginx && \
    rm -rf /tmp/build

# Forward logs to Docker
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

# Set up config file
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 1935
CMD ["nginx", "-g", "daemon off;"]

# MCA's customization
# Install dependencies
# RUN apt-get install -y nginx libnginx-mod-rtmp ffmpeg mediainfo certbot python-certbot-nginx stunnel4
RUN apt-get install -y ffmpeg mediainfo certbot python-certbot-nginx stunnel4

# nginx config setup (folders)
RUN mkdir -p /data/hls /data/records && chown -R www-data:www-data /data

# nginx config setup (conf files)
COPY rtmp.conf /etc/nginx/modules-available/rtmp.conf
RUN ln -s /etc/nginx/modules-available/rtmp.conf /etc/nginx/modules-enabled/rtmp.conf
RUN nginx -t
RUN nginx -s reload

COPY stream.example.com.conf /etc/nginx/modules-available/stream.example.com.conf
RUN curl https://raw.githubusercontent.com/arut/nginx-rtmp-module/master/stat.xsl -o /data/stat.xsl
RUN ln -s /etc/nginx/sites-available/stream.example.com.conf /etc/nginx/sites-enabled/stream.example.com.conf
RUN nginx -t
RUN nginx -s reload

COPY stunnel.conf /etc/stunnel/stunnel.conf

