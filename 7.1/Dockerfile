FROM php:7.1-fpm-alpine

ENV GOTLP_VER 0.1.5

RUN apk add --update \
        autoconf \
        bash \
        bzip2 \
        c-client \
        git \
        gzip \
        icu-libs \
        imagemagick \
        imap \
        libbz2 \
        libmcrypt \
        libtool \
        libxslt \
        mariadb-client \
        libmemcached-libs \
        openssh-client \
        patch \
        postgresql-client \
        rsync \
        su-exec \
        tar \
        wget \
        yaml \

        # Dev packages to compile extensions
        build-base \
        bzip2-dev \
        freetype-dev \
        icu-dev \
        imagemagick-dev \
        imap-dev \
        jpeg-dev \
        libmemcached-dev \
        libmcrypt-dev \
        libpng-dev \
        libxslt-dev \
        openldap-dev \
        pcre-dev \
        postgresql-dev \
        yaml-dev

RUN docker-php-source extract && \

    # INSTALLING PHP EXTENSIONS: START

    docker-php-ext-install \
        bcmath \
        bz2 \
        calendar \
        exif \
        imap \
        intl \
        ldap \
        mcrypt \
        mysqli \
        opcache \
        pdo_mysql \
        pdo_pgsql \
        pgsql \
        phar \
        soap \
        sockets \
        xmlrpc \
        xsl \
        zip && \

    # GD
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-install gd && \

    # Uploadprogress
    git clone https://github.com/php/pecl-php-uploadprogress/ /usr/src/php/ext/uploadprogress/ && \
    docker-php-ext-configure uploadprogress && \
    docker-php-ext-install uploadprogress && \

    pecl config-set php_ini "$PHP_INI_DIR/php.ini" && \

    # OAuth
    yes | pecl install oauth && \
    docker-php-ext-enable oauth && \

    # APCu
    yes | pecl install apcu && \
    docker-php-ext-enable apcu && \

    # Memcached
    git clone --branch php7 https://github.com/php-memcached-dev/php-memcached /usr/src/php/ext/memcached/ && \
    docker-php-ext-configure memcached && \
    docker-php-ext-install memcached && \

    # Redis
    yes | pecl install redis && \
    docker-php-ext-enable redis && \

    # Imagick
    yes | pecl install imagick && \
    docker-php-ext-enable imagick && \

    # Yaml
    yes | pecl install yaml-2.0.0 && \
    docker-php-ext-enable yaml && \

    # XDebug
    yes | pecl install xdebug && \

    # INSTALLING PHP EXTENSIONS: END

    # Download and install Gotlp
    wget -qO- https://github.com/wodby/gotpl/releases/download/${GOTLP_VER}/gotpl-alpine-linux-amd64-${GOTLP_VER}.tar.gz \
        | tar xz -C /usr/local/bin && \

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
    docker-php-source delete && \
    apk del --purge \
        *-dev \
        build-base \
        autoconf \
        libtool && \

    rm -rf \
        /usr/src/php/ext/memcached \
        /usr/src/php/ext/uploadprogress \
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
