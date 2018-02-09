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
    EXT_AMQP_VER="1.9.3" \
    EXT_APCU_VER="5.1.8" \
    EXT_AST_VER="0.1.6" \
    EXT_DS_VER="1.2.4" \
    EXT_GEOIP_VER="1.1.1" \
    EXT_GRPC_VER="1.9.0" \
    EXT_IMAGICK_VER="3.4.3" \
    EXT_MEMCACHED_VER="3.0.4" \
    EXT_MONGODB_VER="1.4.0" \
    EXT_OAUTH_VER="2.0.2" \
    EXT_REDIS_VER="3.1.6" \
    EXT_XDEBUG_VER="2.6.0" \
    EXT_YAML_VER="2.0.2" \
    \
    PHP72_EXT_MCRYPT_VER="1.0.1" \
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

ENV APP_ROOT="/var/www/html" \
    CONF_DIR="/var/www/conf" \
    FILES_DIR="/mnt/files" \
    PATH="/home/wodby/.composer/vendor/bin:${PATH}" \
    SSHD_HOST_KEYS_DIR="/etc/ssh" \
    \
    GIT_USER_EMAIL="wodby@example.com" \
    GIT_USER_NAME="wodby"

RUN set -xe; \
    \
	addgroup -g 1000 -S wodby; \
	adduser -u 1000 -D -S -s /bin/bash -G wodby wodby; \
	adduser www-data wodby; \
	sed -i '/^wodby/s/!/*/' /etc/shadow; \
	echo "PS1='\w\$ '" >> /home/wodby/.bashrc; \
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
    if [[ -n "${PHP_DEBUG}" ]]; then \
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
    # mcrypt moved to pecl in PHP 7.2
    if [[ "${PHP_VERSION:0:3}" == "7.2" ]]; then \
        pecl install mcrypt-${PHP72_EXT_MCRYPT_VER}; \
        docker-php-ext-enable mcrypt; \
    else \
        docker-php-ext-install mcrypt; \
    fi; \
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
    chown -R wodby:wodby /var/log/newrelic/; \
    chmod -R 775 /var/log/newrelic/; \
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
        xdebug \
        yaml; \
    \
    # Blackfire extension
    mkdir -p /tmp/blackfire; \
    version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;"); \
    blackfire_url="https://blackfire.io/api/v1/releases/probe/php/alpine/amd64/${version}"; \
    wget -qO- "${blackfire_url}" | tar xz --no-same-owner -C /tmp/blackfire; \
    mv /tmp/blackfire/blackfire-*.so $(php -r "echo ini_get('extension_dir');")/blackfire.so; \
    \
    # Uploadprogress
    mkdir -p /usr/src/php/ext/uploadprogress; \
    up_url="https://github.com/wodby/pecl-php-uploadprogress/archive/latest.tar.gz"; \
    wget -qO- "${up_url}" | tar xz --strip-components=1 -C /usr/src/php/ext/uploadprogress; \
    docker-php-ext-configure uploadprogress; \
    docker-php-ext-install uploadprogress; \
    \
    # AST
    mkdir -p /usr/src/php/ext/ast; \
    ast_url="https://github.com/nikic/php-ast/archive/v${EXT_AST_VER}.tar.gz"; \
    wget -qO- "${ast_url}" | tar xz --strip-components=1 -C /usr/src/php/ext/ast; \
    docker-php-ext-configure ast; \
    docker-php-ext-install ast; \
    \
    # Install composer
    wget -qO- https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer; \
    \
    # Plugin for parallel install
    su-exec wodby composer global require "hirak/prestissimo:^${PHP_PRESTISSIMO_VER}"; \
    \
    # Install Walter
    walter_url="https://github.com/walter-cd/walter/releases/download/v${WALTER_VER}/walter_${WALTER_VER}_linux_amd64.tar.gz"; \
    wget -qO- "${walter_url}" | tar xz -C /tmp/; \
    mv /tmp/walter_linux_amd64/walter /usr/local/bin; \
    \
    # Add composer bins to $PATH
    su-exec wodby echo "export PATH=/home/wodby/.composer/vendor/bin:${PATH}" > /home/wodby/.profile; \
    \
    # Script to fix volumes permissions via sudo.
    echo "chown wodby:wodby ${FILES_DIR} ${APP_ROOT}" > /usr/local/bin/fix-volumes-permissions.sh; \
    chmod +x /usr/local/bin/fix-volumes-permissions.sh; \
    \
    # Configure sudoers
    if [[ -n "${PHP_DEV}" ]]; then \
        echo 'wodby ALL=(root) NOPASSWD:SETENV:ALL' > /etc/sudoers.d/wodby; \
    else \
        { \
            echo -n 'wodby ALL=(root) NOPASSWD:SETENV: ' ; \
            echo -n '/usr/local/sbin/php-fpm, ' ; \
            echo -n '/usr/local/bin/gen-ssh-keys.sh, ' ; \
            echo -n '/usr/local/bin/fix-volumes-permissions.sh, ' ; \
            echo -n '/usr/sbin/sshd, ' ; \
            echo '/usr/sbin/crond' ; \
        } | tee /etc/sudoers.d/wodby; \
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
    su-exec wodby mkdir /home/wodby/.ssh; \
    \
    touch /etc/ssh/sshd_config; \
    chown wodby: /etc/ssh/sshd_config; \
    \
    rm /etc/crontabs/root; \
    touch /etc/crontabs/wodby; \
    chown root:wodby /etc/crontabs/wodby; \
    chmod 660 /etc/crontabs/wodby; \
    \
    chown -R wodby:wodby \
        /var/www \
        "${PHP_INI_DIR}/conf.d" \
        "${FILES_DIR}" \
        /usr/local/etc/php-fpm.d/ \
        /home/wodby/.profile; \
    \
    # Cleanup
    su-exec wodby composer clear-cache; \
    docker-php-source delete; \
    apk del --purge .build-deps; \
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

USER wodby

WORKDIR ${APP_ROOT}
EXPOSE 9000

COPY templates /etc/gotpl/
COPY docker-entrypoint.sh /
COPY actions /usr/local/bin/

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["sudo", "-E", "php-fpm"]
