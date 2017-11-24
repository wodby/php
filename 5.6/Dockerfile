ARG FROM_TAG

FROM wodby/base-php:${FROM_TAG}

ARG PHP_DEBUG

ENV PHP_DEBUG="${PHP_DEBUG:-0}" \
    SSHD_PERMIT_USER_ENV="yes" \
    PHP_PRESTISSIMO_VER="0.3" \
    WALTER_VER="1.3.0" \

    EXT_AMQP_VER="1.9.1" \
    EXT_APCU_VER="4.0.11" \
    EXT_GEOIP_VER="1.1.1" \
    EXT_IMAGICK_VER="3.4.3" \
    EXT_MEMCACHED_VER="2.2.0" \
    EXT_MONGODB_VER="1.3.2" \
    EXT_OAUTH_VER="1.2.3" \
    EXT_REDIS_VER="3.1.4" \
    EXT_UPLOADPROGRESS_VER="1.0.3.1" \
    EXT_XDEBUG_VER="2.5.5" \
    EXT_YAML_VER="1.3.1" \

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
    POSTGRESQL_CLIENT_VER="9.6.6-r0" \
    RABBITMQ_C_VER="0.8.0-r2" \
    YAML_VER="0.1.7-r0"

ENV WALTER_URL="https://github.com/walter-cd/walter/releases/download/v${WALTER_VER}/walter_${WALTER_VER}_linux_amd64.tar.gz" \
    BLACKFIRE_URL="https://blackfire.io/api/v1/releases/probe/php/alpine/amd64" \

    APP_ROOT="/var/www/html" \
    PATH="/home/www-data/.composer/vendor/bin:${PATH}"

RUN set -xe && \

    # Recreate user with correct params
    deluser www-data && \
	addgroup -g 82 -S www-data && \
	adduser -u 82 -D -S -s /bin/bash -G www-data www-data && \
	sed -i '/^www-data/s/!/*/' /etc/shadow && \
	echo "PS1='\w\$ '" >> /home/www-data/.bashrc && \

    apk add --update --no-cache --virtual .php-rundeps \
        c-client=${C_CLIENT_VER} \
        fcgi \
        freetype=${FREETYPE_VER} \
        geoip=${GEOIP_VER} \
        git \
        icu-libs=${ICU_LIBS_VER} \
        imagemagick=${IMAGEMAGICK_VER} \
        less \
        libbz2=${LIBBZ2_VER} \
        libjpeg-turbo=${LIBJPEG_TURBO_VER} \
        libjpeg-turbo-utils=${LIBJPEG_TURBO_VER} \
        libldap=${LIBLDAP_VER} \
        libltdl=${LIBLTDL_VER} \
        libmemcached-libs=${LIBMEMCACHED_LIBS_VER} \
        libmcrypt=${LIBMCRYPT_VER} \
        libpng=${LIBPNG_VER} \
        libxslt=${LIBXSLT_VER} \
        make \
        mariadb-client=${MARIADB_CLIENT_VER} \
        nano \
        openssh \
        openssh-client \
        patch \
        postgresql-client=${POSTGRESQL_CLIENT_VER} \
        rabbitmq-c=${RABBITMQ_C_VER} \
        rsync \
        su-exec \
        sudo \
        tig \
        tmux \
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

    if [[ $PHP_DEBUG == 1 ]]; then \
        apk add --update --no-cache --virtual .debug-tools gdb; \
    fi && \

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
        mysql \
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

    pecl install \
        amqp-${EXT_AMQP_VER} \
        apcu-${EXT_APCU_VER} \
        geoip-${EXT_GEOIP_VER} \
        imagick-${EXT_IMAGICK_VER} \
        memcached-${EXT_MEMCACHED_VER} \
        mongodb-${EXT_MONGODB_VER} \
        oauth-${EXT_OAUTH_VER} \
        redis-${EXT_REDIS_VER} \
        uploadprogress-${EXT_UPLOADPROGRESS_VER} \
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
        uploadprogress \
        xdebug \
        yaml && \

    # Blackfire extension
    mkdir -p /tmp/blackfire && \
    version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") && \
    wget -qO- "${BLACKFIRE_URL}/${version}" | tar xz --no-same-owner -C /tmp/blackfire && \
    mv /tmp/blackfire/blackfire-*.so $(php -r "echo ini_get('extension_dir');")/blackfire.so && \

    # Install composer
    wget -qO- https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \

    # Install composer parallel install plugin
    su-exec www-data composer global require hirak/prestissimo:^${PHP_PRESTISSIMO_VER} && \

    # Install Walter
    wget -qO- ${WALTER_URL} | tar xz -C /tmp/ && \
    mv /tmp/walter_linux_amd64/walter /usr/local/bin && \

    # Add composer bins to $PATH
    su-exec www-data echo "export PATH=/home/www-data/.composer/vendor/bin:${PATH}" > /home/www-data/.profile && \

    # Configure sudoers
    { \
        echo -n 'www-data ALL=(root) NOPASSWD:SETENV: ' ; \
        echo -n '/usr/local/bin/sshd-generate-keys.sh, ' ; \
        echo -n '/usr/local/bin/fix-permissions.sh, ' ; \
        echo -n '/usr/sbin/sshd, ' ; \
        echo '/usr/sbin/crond' ; \
    } | tee /etc/sudoers.d/www-data && \

    # Configure ldap
    echo "TLS_CACERTDIR /etc/ssl/certs/" >> /etc/openldap/ldap.conf && \

    # We run php-fpm as non root
    sed -i '/^user = www-data/d;/^group = www-data/d' /usr/local/etc/php-fpm.d/www.conf* && \

    # Create required directories and fix permissions
    mkdir -p ${APP_ROOT} && \
    su-exec www-data mkdir /home/www-data/.ssh && \

    touch /etc/ssh/sshd_config && \
    chown www-data: /etc/ssh/sshd_config && \

    rm /etc/crontabs/root && \
    touch /etc/crontabs/www-data && \
    chown root:www-data /etc/crontabs/www-data && \
    chmod 660 /etc/crontabs/www-data && \

    chown -R www-data:www-data /var/www "${PHP_INI_DIR}/conf.d" /usr/local/etc/php-fpm.d/ /home/www-data/.profile && \

    # Cleanup
    su-exec www-data composer clear-cache && \
    docker-php-source delete && \
    apk del .build-deps && \
    pecl clear-cache && \

    rm -rf \
        /usr/src/php.tar.xz \
        /usr/include/php \
        /usr/lib/php/build \
        /tmp/* \
        /root/.composer \
        /var/cache/apk/*

USER www-data

WORKDIR ${APP_ROOT}
EXPOSE 9000

COPY templates /etc/gotpl/
COPY docker-entrypoint.sh /
COPY actions /usr/local/bin/
COPY php.ini ${PHP_INI_DIR}

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["php-fpm"]
