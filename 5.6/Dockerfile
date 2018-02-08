ARG FROM_TAG

FROM wodby/base-php:${FROM_TAG}

ARG PHP_DEV
ARG PHP_DEBUG

ENV PHP_DEV="${PHP_DEV}" \
    PHP_DEBUG="${PHP_DEBUG}" \
    SSHD_PERMIT_USER_ENV="yes" \
    PHP_PRESTISSIMO_VER="0.3" \
    WALTER_VER="1.3.0" \
    \
    EXT_AMQP_VER="1.9.1" \
    EXT_APCU_VER="4.0.11" \
    EXT_GEOIP_VER="1.1.1" \
    EXT_GRPC_VER="1.8.5" \
    EXT_IMAGICK_VER="3.4.3" \
    EXT_MEMCACHED_VER="2.2.0" \
    EXT_MONGODB_VER="1.3.2" \
    EXT_OAUTH_VER="1.2.3" \
    EXT_REDIS_VER="3.1.4" \
    EXT_UPLOADPROGRESS_VER="1.0.3.1" \
    EXT_XDEBUG_VER="2.5.5" \
    EXT_YAML_VER="1.3.1" \
    \
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
    \
    APP_ROOT="/var/www/html" \
    CONF_DIR="/var/www/conf" \
    FILES_DIR="/mnt/files" \
    PATH="/home/www-data/.composer/vendor/bin:${PATH}" \
    SSHD_HOST_KEYS_DIR="/etc/ssh" \
    \
    GIT_USER_EMAIL="www-data@example.com" \
    GIT_USER_NAME="www-data"

RUN set -xe; \
    \
    # Recreate user with correct params
    deluser www-data; \
	addgroup -g 82 -S www-data; \
	adduser -u 82 -D -S -s /bin/bash -G www-data www-data; \
	adduser -u 1000 -D -S -G www-data php-fpm; \
	sed -i '/^www-data/s/!/*/' /etc/shadow; \
	echo "PS1='\w\$ '" >> /home/www-data/.bashrc; \
    \
    apk add --update --no-cache -t .php-rundeps \
        "c-client=${C_CLIENT_VER}" \
        fcgi \
        "freetype=${FREETYPE_VER}" \
        "geoip=${GEOIP_VER}" \
        git \
        "icu-libs=${ICU_LIBS_VER}" \
        "imagemagick=${IMAGEMAGICK_VER}" \
        less \
        "libbz2=${LIBBZ2_VER}" \
        "libjpeg-turbo=${LIBJPEG_TURBO_VER}" \
        "libjpeg-turbo-utils=${LIBJPEG_TURBO_VER}" \
        "libldap=${LIBLDAP_VER}" \
        "libltdl=${LIBLTDL_VER}" \
        "libmemcached-libs=${LIBMEMCACHED_LIBS_VER}" \
        "libmcrypt=${LIBMCRYPT_VER}" \
        "libpng=${LIBPNG_VER}" \
        "libxslt=${LIBXSLT_VER}" \
        make \
        "mariadb-client=${MARIADB_CLIENT_VER}" \
        nano \
        openssh \
        openssh-client \
        patch \
        "postgresql-client=${POSTGRESQL_CLIENT_VER}" \
        "rabbitmq-c=${RABBITMQ_C_VER}" \
        rsync \
        su-exec \
        sudo \
        tig \
        tmux \
        "yaml=${YAML_VER}"; \
    \
    apk add --update --no-cache -t .build-deps \
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
        yaml-dev; \
    \
    if [[ -n "${PHP_DEV}" ]]; then \
        apk add --update --no-cache -t .debug-tools gdb; \
    fi; \
    \
    # Temporary install additional packages to keep client bins.
    apk add --update --no-cache -t .bins-only \
        postgresql \
        redis; \
    mkdir -p /tmp/pkgs-bins; \
    mv \
        /usr/bin/pg_basebackup \
        /usr/bin/clusterdb \
        /usr/bin/pg_dump \
        /usr/bin/dropuser \
        /usr/bin/pg_isready \
        /usr/bin/createuser \
        /usr/bin/pg_recvlogical \
        /usr/bin/psql \
        /usr/bin/reindexdb \
        /usr/bin/vacuumdb \
        /usr/bin/pg_dumpall \
        /usr/bin/createdb \
        /usr/bin/pg_restore \
        /usr/bin/dropdb \
        /usr/bin/redis-cli \
        /tmp/pkgs-bins; \
    apk del --purge .bins-only; \
    mv /tmp/pkgs-bins/* /usr/bin; \
    \
    docker-php-source extract; \
    \
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
        zip; \
    \
    # GD
    docker-php-ext-configure gd \
        --with-gd \
        --with-freetype-dir=/usr/include/ \
        --with-png-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/; \
      NPROC=$(getconf _NPROCESSORS_ONLN); \
      docker-php-ext-install -j${NPROC} gd; \
    \
    # PECL extensions
    pecl config-set php_ini "${PHP_INI_DIR}/php.ini"; \
    \
    # NewRelic extension and agent.
    wget -r -nd --no-parent -P /tmp/newrelic -Alinux-musl.tar.gz \
        http://download.newrelic.com/php_agent/release/ >/dev/null 2>&1; \
    tar -xzf /tmp/newrelic/newrelic-php*.tar.gz --strip=1 -C /tmp/newrelic; \
    export NR_INSTALL_SILENT=true; \
    export NR_INSTALL_USE_CP_NOT_LN=true; \
    bash /tmp/newrelic/newrelic-install install; \
    rm /usr/local/etc/php/conf.d/newrelic.ini; \
    mkdir -p /var/log/newrelic/; \
    chown -R www-data:www-data /var/log/newrelic/; \
    chmod -R 775 /var/log/newrelic/; \
    \
    pecl install \
        "amqp-${EXT_AMQP_VER}" \
        "apcu-${EXT_APCU_VER}" \
        "geoip-${EXT_GEOIP_VER}" \
        "grpc-${EXT_GRPC_VER}" \
        "imagick-${EXT_IMAGICK_VER}" \
        "memcached-${EXT_MEMCACHED_VER}" \
        "mongodb-${EXT_MONGODB_VER}" \
        "oauth-${EXT_OAUTH_VER}" \
        "redis-${EXT_REDIS_VER}" \
        "uploadprogress-${EXT_UPLOADPROGRESS_VER}" \
        "xdebug-${EXT_XDEBUG_VER}" \
        "yaml-${EXT_YAML_VER}"; \
    \
    docker-php-ext-enable \
        amqp \
        apcu \
        imagick \
        geoip \
        grpc \
        memcached \
        mongodb \
        oauth \
        redis \
        uploadprogress \
        xdebug \
        yaml; \
    \
    # Blackfire extension
    mkdir -p /tmp/blackfire; \
    version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;"); \
    wget -qO- "${BLACKFIRE_URL}/${version}" | tar xz --no-same-owner -C /tmp/blackfire; \
    mv /tmp/blackfire/blackfire-*.so $(php -r "echo ini_get('extension_dir');")/blackfire.so; \
    \
    # Install composer
    wget -qO- https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer; \
    \
    # Install composer parallel install plugin
    su-exec www-data composer global require "hirak/prestissimo:^${PHP_PRESTISSIMO_VER}"; \
    \
    # Install Walter
    wget -qO- "${WALTER_URL}" | tar xz -C /tmp/; \
    mv /tmp/walter_linux_amd64/walter /usr/local/bin; \
    \
    # Add composer bins to $PATH
    su-exec www-data echo "export PATH=/home/www-data/.composer/vendor/bin:${PATH}" > /home/www-data/.profile; \
    \
    # Script to fix volumes permissions via sudo.
    echo "chown www-data:www-data ${FILES_DIR} ${APP_ROOT}" > /usr/local/bin/fix-volumes-permissions.sh; \
    chmod +x /usr/local/bin/fix-volumes-permissions.sh; \
    \
    # Configure sudoers
    if [[ -n "${PHP_DEV}" ]]; then \
        echo 'www-data ALL=(root) NOPASSWD:SETENV:ALL' > /etc/sudoers.d/www-data; \
    else \
        { \
            echo -n 'www-data ALL=(root) NOPASSWD:SETENV: ' ; \
            echo -n '/usr/local/sbin/php-fpm, ' ; \
            echo -n '/usr/local/bin/gen-ssh-keys.sh, ' ; \
            echo -n '/usr/local/bin/fix-volumes-permissions.sh, ' ; \
            echo -n '/usr/sbin/sshd, ' ; \
            echo '/usr/sbin/crond' ; \
        } | tee /etc/sudoers.d/www-data; \
    fi; \
    \
    # Configure ldap
    echo "TLS_CACERTDIR /etc/ssl/certs/" >> /etc/openldap/ldap.conf; \
    \
    # Create required directories and fix permissions
    mkdir -p \
        "${APP_ROOT}" \
        "${CONF_DIR}" \
        "${FILES_DIR}/public" \
        "${FILES_DIR}/private"; \
    \
    chmod 775 "${FILES_DIR}/public" "${FILES_DIR}/private"; \
    su-exec www-data mkdir /home/www-data/.ssh; \
    \
    touch /etc/ssh/sshd_config; \
    chown www-data: /etc/ssh/sshd_config; \
    \
    rm /etc/crontabs/root; \
    touch /etc/crontabs/www-data; \
    chown root:www-data /etc/crontabs/www-data; \
    chmod 660 /etc/crontabs/www-data; \
    \
    chown -R www-data:www-data \
        /var/www \
        "${PHP_INI_DIR}/conf.d" \
        "${FILES_DIR}" \
        /usr/local/etc/php-fpm.d/ \
        /home/www-data/.profile; \
    \
    # Cleanup
    su-exec www-data composer clear-cache; \
    docker-php-source delete; \
    apk del --purge .build-deps; \
    pecl clear-cache; \
    \
    rm -rf \
        /usr/include/php \
        /usr/lib/php/build \
        /tmp/* \
        /root/.composer \
        /var/cache/apk/*; \
    \
    if [[ -z "${PHP_DEV}" ]]; then \
        rm -rf /usr/src/php.tar.xz; \
    fi

USER www-data

WORKDIR ${APP_ROOT}
EXPOSE 9000

COPY templates /etc/gotpl/
COPY docker-entrypoint.sh /
COPY actions /usr/local/bin/

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["sudo", "-E", "php-fpm"]
