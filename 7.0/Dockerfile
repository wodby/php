FROM alpine:3.5

ENV PHP_VER 7.0.15-r0
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
        yaml \
        mariadb-client \
        postgresql-client\

        # Dev packages
        build-base \
        autoconf \
        libtool \
        php7-dev \
        pcre-dev \
        imagemagick-dev \
        yaml-dev \

        # PHP packages
        php7=${PHP_VER} \
        php7-fpm \
        php7-opcache \
        php7-session \
        php7-dom \
        php7-xml \
        php7-xmlreader \
        php7-ctype \
        php7-ftp \
        php7-gd \
        php7-json \
        php7-posix \
        php7-curl \
        php7-pdo \
        php7-pdo_mysql \
        php7-sockets \
        php7-zlib \
        php7-mcrypt \
        php7-mysqli \
        php7-sqlite3 \
        php7-bz2 \
        php7-phar \
        php7-openssl \
        php7-posix \
        php7-zip \
        php7-calendar \
        php7-iconv \
        php7-imap \
        php7-soap \
        php7-dev \
        php7-pear \
        php7-redis \
        php7-mbstring \
        php7-xdebug \
        php7-exif \
        php7-xsl \
        php7-ldap \
        php7-bcmath \
        php7-memcached \
        php7-oauth \
        php7-apcu \
        php7-intl \
        php7-pgsql \
        php7-pdo_pgsql \
        && \

    # Download and install Gotlp
    wget -qO- https://github.com/wodby/gotpl/releases/download/${GOTLP_VER}/gotpl-alpine-linux-amd64-${GOTLP_VER}.tar.gz \
        | tar xz -C /usr/local/bin && \

    # Install pecl imagick
    sed -ie 's/-n//g' /usr/bin/pecl && \
    yes | pecl install imagick && \
    echo 'extension=imagick.so' > /etc/php7/conf.d/20_imagick.ini && \

    # Install pecl yaml
    yes | pecl install yaml-2.0.0 && \
    echo 'extension=yaml.so' > /etc/php7/conf.d/20_yaml.ini && \

    # Install uploadprogess
    mkdir -p /tmp/uploadprogress-master && \
    wget -qO- https://github.com/Jan-E/uploadprogress/archive/master.tar.gz \
        | tar xz -C /tmp/uploadprogress-master --strip-components=1 && \
    cd /tmp/uploadprogress-master && \
    phpize && \
    ./configure --with-php-config=/usr/bin/php-config7 && \
    make && \
    make install && \
    echo 'extension=uploadprogress.so' > /etc/php7/conf.d/20_uploadprogress.ini && \

    # Remove default configs
    rm /etc/php7/conf.d/00_opcache.ini && \
    rm /etc/php7/conf.d/xdebug.ini && \

    # Install composer
    wget -qO- https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \

    # Install composer parallel install plugin
    su-exec www-data composer global require hirak/prestissimo:^0.3 && \

    # Install PHPUnit
    wget -qO- https://phar.phpunit.de/phpunit.phar > /usr/local/bin/phpunit && \
    chmod +x /usr/local/bin/phpunit && \

    # Create working dir
    mkdir -p /var/www/html && \
    chown -R www-data:www-data /var/www && \

    # Cleanup
    apk del --purge \
        *-dev \
        build-base \
        autoconf \
        libtool && \

    rm -rf \
        /usr/include/php \
        /usr/lib/php/build \
        /var/cache/apk/* \
        /tmp/* \
        /root/.composer

ENV PATH "/home/www-data/.composer/vendor/bin:$PATH"

WORKDIR /var/www/html
EXPOSE 9000

COPY templates/* /etc/gotpl/
COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["php-fpm"]
