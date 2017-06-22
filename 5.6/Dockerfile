FROM wodby/base-php:5.6.30

ENV GOTPL_VER 0.1.5
ENV PHP_PRESTISSIMO_VER 0.3
ENV PHP_UNIT_VER 5.7
ENV WALTER_VER 1.3.0

ENV EXT_AMQP_VER 1.9.1
ENV EXT_APCU_VER 4.0.11
ENV EXT_IMAGICK_VER 3.4.3
ENV EXT_MEMCACHED_VER 2.2.0
ENV EXT_MONGODB_VER 1.1.10
ENV EXT_OAUTH_VER 1.2.3
ENV EXT_REDIS_VER 3.1.2
ENV EXT_UPLOADPROGRESS_VER 1.0.3.1
ENV EXT_XDEBUG_VER 2.5.5
ENV EXT_YAML_VER 1.3.0

ENV AUTOCONF_VER 2.69-r0
ENV BASH_VER 4.3.48-r1
ENV BUILD_BASE 0.5-r0
ENV CA_CERTIFICATES_VER 20161130-r2
ENV C_CLIENT_VER 2007f-r6
ENV CMAKE_VER 3.8.1-r0
ENV FREETYPE_VER 2.7.1-r1
ENV GIT_VER 2.13.0-r0
ENV GZIP_VER 1.8-r0
ENV ICU_LIBS_VER 58.2-r2
ENV IMAGEMAGICK_VER 7.0.5.10-r0
ENV LIBBZ2_VER 1.0.6-r5
ENV LIBGCC_VER 6.3.0-r4
ENV LIBJPEG_TURBO_VER 1.5.1-r0
ENV LIBLDAP_VER 2.4.44-r5
ENV LIBLTDL_VER 2.4.6-r1
ENV LIBMEMCACHED_LIBS_VER 1.0.18-r1
ENV LIBMCRYPT_VER 2.5.8-r7
ENV LIBPNG_VER 1.6.29-r1
ENV LIBSTDCPP_VER 6.3.0-r4
ENV LIBTOOL_VER 2.4.6-r1
ENV LIBXML2_VER 2.9.4-r4
ENV LIBXSLT_VER 1.1.29-r3
ENV MAKE_VER 4.2.1-r0
ENV MARIADB_CLIENT_VER 10.1.22-r1
ENV OPENSSH_VER 7.5_p1-r1
ENV PATCH_VER 2.7.5-r1
ENV PCRE_VER 8.40-r2
ENV POSTGRESQL_CLIENT_VER 9.6.3-r0
ENV RABBITMQ_C_VER 0.8.0-r2
ENV RSYNC_VER 3.1.2-r5
ENV SU_EXEC_VER 0.2-r0
ENV TAR_VER 1.29-r1
ENV WGET_VER 1.19.1-r2
ENV YAML_VER 0.1.7-r0

ENV GOTPL_URL https://github.com/wodby/gotpl/releases/download/${GOTPL_VER}/gotpl-alpine-linux-amd64-${GOTPL_VER}.tar.gz
ENV WALTER_URL https://github.com/walter-cd/walter/releases/download/v${WALTER_VER}/walter_${WALTER_VER}_linux_amd64.tar.gz

ENV APP_ROOT /var/www/html

# Recreate user with correct params
RUN deluser www-data && \
	addgroup -g 82 -S www-data && \
	adduser -u 82 -D -S -s /bin/bash -G www-data www-data && \
	sed -i '/^www-data/s/!/*/' /etc/shadow

RUN set -xe && \

    apk add --update --no-cache --virtual .php-rundeps \
        bash=${BASH_VER} \
        ca-certificates=${CA_CERTIFICATES_VER} \
        c-client=${C_CLIENT_VER} \
        freetype=${FREETYPE_VER} \
        git=${GIT_VER} \
        gzip=${GZIP_VER} \
        icu-libs=${ICU_LIBS_VER} \
        imagemagick=${IMAGEMAGICK_VER} \
        libbz2=${LIBBZ2_VER} \
        libgcc=${LIBGCC_VER} \
        libjpeg-turbo=${LIBJPEG_TURBO_VER} \
        libldap=${LIBLDAP_VER} \
        libltdl=${LIBLTDL_VER} \
        libmemcached-libs=${LIBMEMCACHED_LIBS_VER} \
        libmcrypt=${LIBMCRYPT_VER} \
        libpng=${LIBPNG_VER} \
        libstdc++=${LIBSTDCPP_VER} \
        libxml2=${LIBXML2_VER} \
        libxslt=${LIBXSLT_VER} \
        make=${MAKE_VER} \
        mariadb-client=${MARIADB_CLIENT_VER} \
        openssh=${OPENSSH_VER} \
        openssh-client=${OPENSSH_VER} \
        patch=${PATCH_VER} \
        postgresql-client=${POSTGRESQL_CLIENT_VER} \
        rabbitmq-c=${RABBITMQ_C_VER} \
        rsync=${RSYNC_VER} \
        su-exec=${SU_EXEC_VER} \
        tar=${TAR_VER} \
        wget=${WGET_VER} \
        yaml=${YAML_VER} && \

    apk add --update --no-cache --virtual .build-deps \
        autoconf=${AUTOCONF_VER} \
        cmake=${CMAKE_VER} \
        build-base=${BUILD_BASE} \
        bzip2-dev \
        freetype-dev \
        icu-dev \
        imagemagick-dev \
        imap-dev \
        jpeg-dev \
        libjpeg-turbo-dev \
        libmemcached-dev \
        libmcrypt-dev \
        libpng-dev \
        libtool=${LIBTOOL_VER} \
        libxslt-dev \
        openldap-dev \
        pcre-dev=${PCRE_VER} \
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

    pecl install -f \
        amqp-${EXT_AMQP_VER} \
        apcu-${EXT_APCU_VER} \
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
        memcached \
        mongodb \
        oauth \
        redis \
        uploadprogress \
        xdebug \
        yaml && \

    # Install Gotpl
    wget -qO- ${GOTPL_URL} | tar xz -C /usr/local/bin && \

    # Install composer
    wget -qO- https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \

    # Install composer parallel install plugin
    su-exec www-data composer global require hirak/prestissimo:^${PHP_PRESTISSIMO_VER} && \

    # Install PHPUnit
    wget -qO- https://phar.phpunit.de/phpunit-${PHP_UNIT_VER}.phar > /usr/local/bin/phpunit && \
    chmod +x /usr/local/bin/phpunit && \

    # Install Walter
    wget -qO- ${WALTER_URL} | tar xz -C /tmp/ && \
    mv /tmp/walter_linux_amd64/walter /usr/local/bin && \

    # Create working dir
    mkdir -p ${APP_ROOT} && \
    chown -R www-data:www-data /var/www && \

    # Update SSHd config
    echo -e "Host *\n\tStrictHostKeyChecking no\n" >> /etc/ssh/ssh_config && \
    sed -i '/PermitUserEnvironment/c\PermitUserEnvironment yes' /etc/ssh/sshd_config && \

    # Add composer bins to $PATH
    su-exec www-data echo "export PATH=/home/www-data/.composer/vendor/bin:${PATH}" > /home/www-data/.profile && \

    # Clean up root crontab
    truncate -s 0 /etc/crontabs/root && \

    # Cleanup
    su-exec www-data composer clear-cache && \
    docker-php-source delete && \
    apk del .build-deps && \

    rm -rf \
        /usr/src/php.tar.xz \
        /usr/include/php \
        /usr/lib/php/build \
        /tmp/* \
        /root/.composer

ENV PATH "/home/www-data/.composer/vendor/bin:${PATH}"

WORKDIR ${APP_ROOT}
EXPOSE 9000

COPY templates /etc/gotpl/
COPY docker-entrypoint.sh /
COPY actions /usr/local/bin/
COPY php.ini ${PHP_INI_DIR}

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["php-fpm"]
