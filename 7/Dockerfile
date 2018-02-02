ARG FROM_TAG

FROM wodby/base-php:${FROM_TAG}

ARG PHP_DEV

ENV PHP_DEV="${PHP_DEV}" \
    SSHD_PERMIT_USER_ENV="yes" \
    PHP_PRESTISSIMO_VER="0.3" \
    WALTER_VER="1.3.0" \
    \
    EXT_AMQP_VER="1.9.1" \
    EXT_APCU_VER="5.1.8" \
    EXT_AST_VER="0.1.6" \
    EXT_DS_VER="1.2.4" \
    EXT_GEOIP_VER="1.1.1" \
    EXT_GRPC_VER="1.8.5" \
    EXT_IMAGICK_VER="3.4.3" \
    EXT_MEMCACHED_VER="3.0.4" \
    EXT_MONGODB_VER="1.3.2" \
    EXT_OAUTH_VER="2.0.2" \
    EXT_REDIS_VER="3.1.4" \
    EXT_XDEBUG_VER="2.6.0" \
    EXT_YAML_VER="2.0.2" \
    \
    PHP72_EXT_MCRYPT_VER="1.0.1" \
    \
    C_CLIENT_VER="2007f-r7" \
    FREETYPE_VER="2.8.1-r2" \
    GEOIP_VER="1.6.11-r0" \
    ICU_LIBS_VER="59.1-r1" \
    IMAGEMAGICK_VER="7.0.7.11-r1" \
    LIBBZ2_VER="1.0.6-r6" \
    LIBJPEG_TURBO_VER="1.5.2-r0" \
    LIBLDAP_VER="2.4.45-r3" \
    LIBLTDL_VER="2.4.6-r4" \
    LIBMEMCACHED_LIBS_VER="1.0.18-r1" \
    LIBMCRYPT_VER="2.5.8-r7" \
    LIBPNG_VER="1.6.34-r1" \
    LIBXSLT_VER="1.1.31-r0" \
    MARIADB_CLIENT_VER="10.1.28-r1" \
    POSTGRESQL_CLIENT_VER="10.1-r1" \
    RABBITMQ_C_VER="0.8.0-r3" \
    YAML_VER="0.1.7-r0"

ENV EXT_AST_URL="https://github.com/nikic/php-ast/archive/v${EXT_AST_VER}.tar.gz" \
    EXT_UPLOADPROGRESS_URL="https://github.com/wodby/pecl-php-uploadprogress/archive/latest.tar.gz" \
    WALTER_URL="https://github.com/walter-cd/walter/releases/download/v${WALTER_VER}/walter_${WALTER_VER}_linux_amd64.tar.gz" \
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

ADD https://patch-diff.githubusercontent.com/raw/php/php-src/pull/2955.patch /usr/src/

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
    apk add --update --no-cache --virtual .php-rundeps \
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
        yaml-dev; \
    \
    if [[ -n "${PHP_DEV}" ]]; then \
        apk add --update --no-cache --virtual .debug-tools gdb; \
    fi; \
    \
    docker-php-source extract; \
    \
    # phar extension patch https://patch-diff.githubusercontent.com/php/php-src/pull/2955
    if [[ "${PHP_VERSION}" == "7.1.12" ]]; then \
        patch -d /usr/src/php -p1 < /usr/src/2955.patch; \
    fi; \
    \
    docker-php-ext-install \
        bcmath \
        bz2 \
        calendar \
        exif \
        imap \
        intl \
        ldap \
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
      docker-php-ext-install "-j${NPROC}" gd; \
    \
    # PECL extensions
    pecl config-set php_ini "${PHP_INI_DIR}/php.ini"; \
    \
    # PHP 7.2:
    # - mcrypt moved to pecl
    if [[ "${PHP_VERSION:0:3}" == "7.2" ]]; then \
        pecl install mcrypt-${PHP72_EXT_MCRYPT_VER}; \
        docker-php-ext-enable mcrypt; \
    else \
        docker-php-ext-install mcrypt; \
        pecl install xdebug-${EXT_XDEBUG_VER}; \
        docker-php-ext-enable xdebug; \
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
    fi; \
    \
    pecl install \
        "amqp-${EXT_AMQP_VER}" \
        "apcu-${EXT_APCU_VER}" \
        "ds-${EXT_DS_VER}" \
        "geoip-${EXT_GEOIP_VER}" \
        "grpc-${EXT_GRPC_VER}" \
        "imagick-${EXT_IMAGICK_VER}" \
        "memcached-${EXT_MEMCACHED_VER}" \
        "mongodb-${EXT_MONGODB_VER}" \
        "oauth-${EXT_OAUTH_VER}" \
        "redis-${EXT_REDIS_VER}" \
        "xdebug-${EXT_XDEBUG_VER}" \
        "yaml-${EXT_YAML_VER}"; \
    \
    docker-php-ext-enable \
        amqp \
        apcu \
        ds \
        imagick \
        geoip \
        grpc \
        memcached \
        mongodb \
        oauth \
        redis \
        yaml; \
    \
    # Blackfire extension
    mkdir -p /tmp/blackfire; \
    version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;"); \
    wget -qO- "${BLACKFIRE_URL}/${version}" | tar xz --no-same-owner -C /tmp/blackfire; \
    mv /tmp/blackfire/blackfire-*.so $(php -r "echo ini_get('extension_dir');")/blackfire.so; \
    \
    # Uploadprogress
    mkdir -p /usr/src/php/ext/uploadprogress; \
    wget -qO- "${EXT_UPLOADPROGRESS_URL}" | tar xz --strip-components=1 -C /usr/src/php/ext/uploadprogress; \
    docker-php-ext-configure uploadprogress; \
    docker-php-ext-install uploadprogress; \
    \
    # AST
    mkdir -p /usr/src/php/ext/ast; \
    wget -qO- "${EXT_AST_URL}" | tar xz --strip-components=1 -C /usr/src/php/ext/ast; \
    docker-php-ext-configure ast; \
    docker-php-ext-install ast; \
    \
    # Install composer
    wget -qO- https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer; \
    \
    # Plugin for parallel install
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
    mkdir -p "${APP_ROOT}" "${FILES_DIR}" "${CONF_DIR}"; \
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
        /usr/local/etc/php-fpm.d/ \
        /home/www-data/.profile; \
    \
    # Cleanup
    su-exec www-data composer clear-cache; \
    docker-php-source delete; \
    apk del .build-deps; \
    pecl clear-cache; \
    \
    rm -rf \
        /usr/src/php/ext/ast \
        /usr/src/php/ext/uploadprogress \
        /usr/include/php \
        /usr/lib/php/build \
        /tmp/* \
        /root/.composer \
        /var/cache/apk/*; \
    \
    if [[ -z "${PHP_DEV}" ]]; then \
        rm -rf /usr/src/php.tar.xz; \
    fi;

USER www-data

WORKDIR ${APP_ROOT}
EXPOSE 9000

COPY templates /etc/gotpl/
COPY docker-entrypoint.sh /
COPY actions /usr/local/bin/

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["sudo", "-E", "php-fpm"]
