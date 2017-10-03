ARG FROM_TAG

FROM wodby/base-php:${FROM_TAG}

ARG PHP_DEBUG

ENV PHP_DEBUG="${PHP_DEBUG:-0}" \
    SSHD_PERMIT_USER_ENV="yes" \
    PHP_PRESTISSIMO_VER="0.3" \
    PHP_UNIT_VER="6.3" \
    WALTER_VER="1.3.0" \

    EXT_AMQP_VER="1.9.1" \
    EXT_APCU_VER="5.1.8" \
    EXT_AST_VER="0.1.5" \
    EXT_GEOIP_VER="1.1.1" \
    EXT_IMAGICK_VER="3.4.3" \
    EXT_MEMCACHED_VER="3.0.3" \
    EXT_MONGODB_VER="1.3.0" \
    EXT_OAUTH_VER="2.0.2" \
    EXT_REDIS_VER="3.1.4" \
    EXT_XDEBUG_VER="2.5.5" \
    EXT_YAML_VER="2.0.2" \

    C_CLIENT_VER="2007f-r6" \
    FREETYPE_VER="2.7.1-r1" \
    GEOIP_VER="1.6.10-r0" \
    ICU_LIBS_VER="58.2-r2" \
    IMAGEMAGICK_VER="7.0.5.10-r0" \
    LIBBZ2_VER="1.0.6-r5" \
    LIBJPEG_TURBO_VER="1.5.1-r0" \
    LIBLDAP_VER="2.4.44-r5" \
    LIBLTDL_VER="2.4.6-r1" \
    LIBMEMCACHED_LIBS_VER="1.0.18-r1" \
    LIBMCRYPT_VER="2.5.8-r7" \
    LIBPNG_VER="1.6.29-r1" \
    LIBXSLT_VER="1.1.29-r3" \
    MARIADB_CLIENT_VER="10.1.26-r0" \
    POSTGRESQL_CLIENT_VER="9.6.5-r0" \
    RABBITMQ_C_VER="0.8.0-r2" \
    YAML_VER="0.1.7-r0"

ENV EXT_AST_URL="https://github.com/nikic/php-ast/archive/v${EXT_AST_VER}.tar.gz" \
    EXT_UPLOADPROGRESS_URL="https://github.com/wodby/pecl-php-uploadprogress/archive/latest.tar.gz" \
    WALTER_URL="https://github.com/walter-cd/walter/releases/download/v${WALTER_VER}/walter_${WALTER_VER}_linux_amd64.tar.gz" \
    BLACKFIRE_URL="https://blackfire.io/api/v1/releases/probe/php/alpine/amd64" \

    APP_ROOT="/var/www/html" \
    PATH="/home/www-data/.composer/vendor/bin:${PATH}"

RUN set -xe && \

    # Recreate user with correct params
    deluser www-data && \
	addgroup -g 82 -S www-data && \
	adduser -u 82 -D -S -s /bin/bash -G www-data www-data && \
	sed -i '/^www-data/s/!/*/' /etc/shadow && \

    apk add --update --no-cache --virtual .php-rundeps \
        c-client=${C_CLIENT_VER} \
        fcgi \
        freetype=${FREETYPE_VER} \
        geoip=${GEOIP_VER} \
        git \
        icu-libs=${ICU_LIBS_VER} \
        imagemagick=${IMAGEMAGICK_VER} \
        libbz2=${LIBBZ2_VER} \
        libjpeg-turbo=${LIBJPEG_TURBO_VER} \
        libldap=${LIBLDAP_VER} \
        libltdl=${LIBLTDL_VER} \
        libmemcached-libs=${LIBMEMCACHED_LIBS_VER} \
        libmcrypt=${LIBMCRYPT_VER} \
        libpng=${LIBPNG_VER} \
        libxslt=${LIBXSLT_VER} \
        make \
        mariadb-client=${MARIADB_CLIENT_VER} \
        openssh \
        openssh-client \
        patch \
        postgresql-client=${POSTGRESQL_CLIENT_VER} \
        rabbitmq-c=${RABBITMQ_C_VER} \
        rsync \
        su-exec \
        sudo \
        yaml=${YAML_VER} && \

    apk add --update --no-cache --virtual .build-deps \
        autoconf \
        cmake \
        build-base \
        bzip2-dev \
        freetype-dev \
        geoip-dev \
        icu-dev \
        imagemagick-dev \
        imap-dev \
        jpeg-dev \
        libjpeg-turbo-dev \
        libmemcached-dev \
        libmcrypt-dev \
        libpng-dev \
        libtool \
        libxslt-dev \
        openldap-dev \
        pcre-dev \
        postgresql-dev \
        rabbitmq-c-dev \
        yaml-dev && \

    docker-php-source extract && \

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
        pcntl \
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
    docker-php-ext-configure gd \
        --with-gd \
        --with-freetype-dir=/usr/include/ \
        --with-png-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ && \
      NPROC=$(getconf _NPROCESSORS_ONLN) && \
      docker-php-ext-install -j${NPROC} gd && \

    # PECL extensions
    pecl config-set php_ini "${PHP_INI_DIR}/php.ini" && \

    pecl install -f \
        amqp-${EXT_AMQP_VER} \
        apcu-${EXT_APCU_VER} \
        geoip-${EXT_GEOIP_VER} \
        imagick-${EXT_IMAGICK_VER} \
        memcached-${EXT_MEMCACHED_VER} \
        mongodb-${EXT_MONGODB_VER} \
        oauth-${EXT_OAUTH_VER} \
        redis-${EXT_REDIS_VER} \
        xdebug-${EXT_XDEBUG_VER} \
        yaml-${EXT_YAML_VER} && \

    docker-php-ext-enable \
        amqp \
        apcu \
        imagick \
        geoip \
        memcached \
        mongodb \
        oauth \
        redis \
        xdebug \
        yaml && \

    # Blackfire extension
    mkdir -p /tmp/blackfire && \
    version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") && \
    wget -qO- "${BLACKFIRE_URL}/${version}" | tar xz --no-same-owner -C /tmp/blackfire && \
    mv /tmp/blackfire/blackfire-*.so $(php -r "echo ini_get('extension_dir');")/blackfire.so && \

    # Uploadprogress
    mkdir -p /usr/src/php/ext/uploadprogress && \
    wget -qO- ${EXT_UPLOADPROGRESS_URL} | tar xz --strip-components=1 -C /usr/src/php/ext/uploadprogress && \
    docker-php-ext-configure uploadprogress && \
    docker-php-ext-install uploadprogress && \

    # AST
    mkdir -p /usr/src/php/ext/ast && \
    wget -qO- ${EXT_AST_URL} | tar xz --strip-components=1 -C /usr/src/php/ext/ast && \
    docker-php-ext-configure ast && \
    docker-php-ext-install ast && \

    # Install composer
    wget -qO- https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \

    # Plugin for parallel install
    su-exec www-data composer global require hirak/prestissimo:^${PHP_PRESTISSIMO_VER} && \

    # Install PHPUnit
    wget -qO- https://phar.phpunit.de/phpunit-${PHP_UNIT_VER}.phar > /usr/local/bin/phpunit && \
    chmod +x /usr/local/bin/phpunit && \

    # Install Walter
    wget -qO- ${WALTER_URL} | tar xz -C /tmp/ && \
    mv /tmp/walter_linux_amd64/walter /usr/local/bin && \

    # Prepare directories.
    mkdir -p ${APP_ROOT} && \
    chown -R www-data:www-data /var/www && \
    su-exec www-data mkdir /home/www-data/.ssh && \

    # Add composer bins to $PATH
    su-exec www-data echo "export PATH=/home/www-data/.composer/vendor/bin:${PATH}" > /home/www-data/.profile && \

    # Fix permissions
    chown -R www-data:www-data "${PHP_INI_DIR}/conf.d" /usr/local/etc/php-fpm.d/ /home/www-data/.profile && \

    # Configure sudoers
    { \
        echo -n 'www-data ALL=(root) NOPASSWD: ' ; \
        echo -n '/usr/local/bin/sshd-generate-keys.sh, ' ; \
        echo -n '/usr/local/bin/fix-permissions.sh, ' ; \
        echo -n '/usr/sbin/sshd, ' ; \
        echo '/usr/sbin/crond' ; \
    } | tee /etc/sudoers.d/www-data && \

    # Configure ldap
    echo "TLS_CACERTDIR /etc/ssl/certs/" >> /etc/openldap/ldap.conf && \

    # Prepare cron files
    rm /etc/crontabs/root && \
    touch /etc/crontabs/www-data && \
    chown root:www-data /etc/crontabs/www-data && \
    chmod 660 /etc/crontabs/www-data && \

    # We run php-fpm as non root
    sed -i '/^user = www-data/d;/^group = www-data/d' /usr/local/etc/php-fpm.d/www.conf* && \

    # Configure git
    su-exec www-data git config --global user.email "www-data@example.com" && \
    su-exec www-data git config --global user.name "www-data" && \

    # Cleanup
    su-exec www-data composer clear-cache && \
    docker-php-source delete && \
    apk del .build-deps && \
    pecl clear-cache && \

    rm -rf \
        /usr/src/php.tar.xz \
        /usr/src/php/ext/ast \
        /usr/src/php/ext/uploadprogress \
        /usr/include/php \
        /usr/lib/php/build \
        /tmp/* \
        /root/.composer

USER www-data

WORKDIR ${APP_ROOT}
EXPOSE 9000

COPY templates /etc/gotpl/
COPY docker-entrypoint.sh /
COPY actions /usr/local/bin/
COPY php.ini ${PHP_INI_DIR}

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["php-fpm"]
