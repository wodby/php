ARG FROM_TAG

FROM wodby/base-php:${FROM_TAG}

ARG PHP_DEV

ENV PHP_DEV="${PHP_DEV}" \
    SSHD_PERMIT_USER_ENV="yes" \
    RABBITMQ_C_VER="0.8.0" \
    WALTER_VER="1.3.0" \
    \
    # No imagick ext because of a bug in imagemagick library.
    EXT_AMQP_VER="1.8.0" \
    EXT_APCU_VER="4.0.11" \
    EXT_MEMCACHED_VER="2.2.0" \
    EXT_MONGO_VER="1.6.16" \
    EXT_OAUTH_VER="1.2.3" \
    EXT_UPLOADPROGRESS_VER="1.0.3.1" \
    EXT_XDEBUG_VER="2.2.7" \
    EXT_YAML_VER="1.3.1" \
    EXT_OPCACHE_VER="7.0.5" \
    \
    APP_ROOT="/var/www/html" \
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
        bzip2 \
        c-client \
        fcgi \
        findutils \
        freetype \
        git \
        icu-libs \
        imap \
        less \
        libbz2 \
        libjpeg-turbo \
        libjpeg-turbo-utils \
        libltdl \
        libmemcached-libs \
        libmcrypt \
        libpng \
        libxslt \
        make \
        mariadb-client \
        mariadb-client-libs \
        nano \
        openssh \
        openssh-client \
        openssl \
        patch \
        postgresql-client \
        rsync \
        su-exec \
        sudo \
        tig \
        tmux \
        yaml; \
    \
    apk add --update --no-cache -t .build-deps \
        autoconf \
        cmake \
        build-base \
        bzip2-dev \
        freetype-dev \
        icu-dev \
        imap-dev \
        jpeg-dev \
        libjpeg-turbo-dev \
        libmemcached-dev \
        libmcrypt-dev \
        libpng-dev \
        libtool \
        libxslt-dev \
        mariadb-dev \
        openldap-dev \
        pcre-dev \
        postgresql-dev \
        yaml-dev; \
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
    # RabbitMQ C client
    rmq_url="https://github.com/alanxz/rabbitmq-c/releases/download/v${RABBITMQ_C_VER}/rabbitmq-c-${RABBITMQ_C_VER}.tar.gz"; \
    wget -qO- "${rmq_url}" | tar xz -C /tmp/; \
    cd "/tmp/rabbitmq-c-${RABBITMQ_C_VER}"; \
    mkdir -p build && cd build; \
    cmake .. \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DCMAKE_INSTALL_LIBDIR=lib \
        -DCMAKE_C_FLAGS="${CFLAGS}"; \
    cmake --build . --target install; \
    \
    # PECL extensions
    pecl config-set php_ini "${PHP_INI_DIR}/php.ini"; \
    \
    pecl install \
        "amqp-${EXT_AMQP_VER}" \
        "apcu-${EXT_APCU_VER}" \
        "memcached-${EXT_MEMCACHED_VER}" \
        "mongo-${EXT_MONGO_VER}" \
        "oauth-${EXT_OAUTH_VER}" \
        "uploadprogress-${EXT_UPLOADPROGRESS_VER}" \
        "xdebug-${EXT_XDEBUG_VER}" \
        "yaml-${EXT_YAML_VER}" \
        "ZendOpcache-${EXT_OPCACHE_VER}"; \
    \
    docker-php-ext-enable \
        amqp \
        apcu \
        memcached \
        mongo \
        oauth \
        opcache \
        uploadprogress \
        xdebug \
        yaml; \
    \
    # Install composer
    wget -qO- https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer; \
    \
    # Install Walter tool
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
            echo -n '/usr/local/bin/migrate.sh, ' ; \
            echo -n '/usr/sbin/sshd, ' ; \
            echo "/usr/sbin/crond" ; \
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
        /usr/include/php \
        /usr/lib/php/build \
        /tmp/* \
        /root/.composer \
        /var/cache/apk/*; \
    \
    if [[ -z "${PHP_DEV}" ]]; then \
        rm -rf /usr/src/php.tar.xz; \
    fi

USER wodby

WORKDIR ${APP_ROOT}
EXPOSE 9000

COPY templates /etc/gotpl/
COPY docker-entrypoint.sh /
COPY actions /usr/local/bin/

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["sudo", "-E", "php-fpm"]
