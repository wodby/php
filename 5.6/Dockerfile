FROM alpine:3.5
MAINTAINER Wodby <admin@wodby.com>

ENV PHP_VER 5.6.30-r0
ENV GOTLP_VER 0.1.5

    # Create user and groups
RUN addgroup -S -g 82 www-data && \
    adduser -S -u 82 -s /bin/bash -D -G www-data www-data && \

    # Add testing repository
    echo 'http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories && \

    # Install packages
    apk add --update \
        bash \
        libressl \
        ca-certificates \
        su-exec \
        openssh-client \
        rsync \
        git \
        curl \
        wget \
        gzip \
        tar \
        patch \
        perl \
        pcre \
        imap \
        imagemagick \
        mariadb-client \
        postgresql-client\

        # Dev packages
        build-base \
        autoconf \
        libtool \
        php5-dev \
        pcre-dev \
        imagemagick-dev \

        # PHP packages
        php5=${PHP_VER} \
        php5-common \
        php5-cli \
        php5-fpm \
        php5-opcache \
        php5-dom \
        php5-xml \
        php5-xmlreader \
        php5-ctype \
        php5-ftp \
        php5-gd \
        php5-json \
        php5-posix \
        php5-curl \
        php5-pdo \
        php5-pdo_mysql \
        php5-sockets \
        php5-zlib \
        php5-mcrypt \
        php5-pcntl \
        php5-mysql \
        php5-mysqli \
        php5-sqlite3 \
        php5-bz2 \
        php5-pear \
        php5-exif \
        php5-phar \
        php5-openssl \
        php5-posix \
        php5-zip \
        php5-calendar \
        php5-iconv \
        php5-imap \
        php5-soap \
        php5-memcache \
        php5-redis \
        php5-xdebug \
        php5-xsl \
        php5-ldap \
        php5-bcmath \
        php5-memcached \
        php5-apcu \
        php5-pgsql \
        php5-pdo_pgsql \
        && \

    # Download and install Gotlp
    wget -qO- https://github.com/wodby/gotpl/releases/download/${GOTLP_VER}/gotpl-alpine-linux-amd64-${GOTLP_VER}.tar.gz \
        | tar xz -C /usr/local/bin && \

    # Install uploadprogress and imagick
    sed -ie 's/-n//g' /usr/bin/pecl && \
    yes | pecl install uploadprogress && \
    yes | pecl install imagick && \
    echo 'extension=imagick.so' > /etc/php5/conf.d/imagick.ini && \
    echo 'extension=uploadprogress.so' > /etc/php5/conf.d/uploadprogress.ini && \

    # Remove default configs
    rm /etc/php5/conf.d/opcache.ini && \
    rm /etc/php5/conf.d/xdebug.ini && \

    # Install composer
    wget -qO- https://getcomposer.org/installer \
        | php -- --install-dir=/usr/local/bin --filename=composer && \

    # Install composer parallel install plugin
    su-exec www-data composer global require hirak/prestissimo:^0.3 && \

    # Install PHPUnit
    wget -qO- https://phar.phpunit.de/phpunit.phar -o /usr/local/bin/phpunit && \
    chmod +x /usr/local/bin/phpunit && \

    # Create working dir
    mkdir -p /var/www/html && \
    chown -R www-data:www-data /var/www && \

    # Cleanup
    apk del --purge \
        *-dev \
        build-base \
        autoconf \
        libtool \
        && \

    rm -rf \
        /usr/include/php \
        /usr/lib/php/build \
        /var/cache/apk/* \
        /tmp/* \
        /root/.composer

WORKDIR /var/www/html
EXPOSE 9000

COPY templates/* /etc/gotpl/
COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["php-fpm"]
