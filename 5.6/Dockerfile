ARG FROM_TAG

FROM wodby/base-php:${FROM_TAG}

ARG PHP_DEV
ARG PHP_DEBUG

ARG WODBY_USER_ID=1000
ARG WODBY_GROUP_ID=1000

ENV PHP_DEV="${PHP_DEV}" \
    PHP_DEBUG="${PHP_DEBUG}" \
    \
    LD_PRELOAD="/usr/lib/preloadable_libiconv.so php"

ENV APP_ROOT="/var/www/html" \
    CONF_DIR="/var/www/conf" \
    FILES_DIR="/mnt/files"

ENV PATH="${PATH}:/home/wodby/.composer/vendor/bin:${APP_ROOT}/vendor/bin:${APP_ROOT}/bin" \
    SSHD_HOST_KEYS_DIR="/etc/ssh" \
    ENV="/home/wodby/.shrc" \
    \
    GIT_USER_EMAIL="wodby@example.com" \
    GIT_USER_NAME="wodby"

RUN set -xe; \
    \
    # Delete existing user/group if uid/gid occupied.
    existing_group=$(getent group "${WODBY_GROUP_ID}" | cut -d: -f1); \
    if [[ -n "${existing_group}" ]]; then delgroup "${existing_group}"; fi; \
    existing_user=$(getent passwd "${WODBY_USER_ID}" | cut -d: -f1); \
    if [[ -n "${existing_user}" ]]; then deluser "${existing_user}"; fi; \
    \
	addgroup -g "${WODBY_GROUP_ID}" -S wodby; \
	adduser -u "${WODBY_USER_ID}" -D -S -s /bin/bash -G wodby wodby; \
    adduser wodby www-data; \
	sed -i '/^wodby/s/!/*/' /etc/shadow; \
    \
    apk add --update --no-cache -t .php-rundeps \
        c-client=2007f-r8 \
        fcgi \
        findutils \
        freetype=2.9.1-r1 \
        git \
        gmp=6.1.2-r1 \
        icu-libs=60.2-r2 \
        imagemagick=7.0.8.38-r0 \
        jpegoptim=1.4.6-r0 \
        less \
        libbz2=1.0.6-r6 \
        libevent=2.1.8-r5 \
        libjpeg-turbo=1.5.3-r4 \
        libjpeg-turbo-utils \
        libldap=2.4.46-r0 \
        libltdl=2.4.6-r5 \
        libmemcached-libs=1.0.18-r2 \
        libmcrypt=2.5.8-r7 \
        libpng=1.6.37-r0 \
        librdkafka=0.11.4-r1 \
        libuuid=2.32-r0 \
        libxslt=1.1.33-r1 \
        make \
        mariadb-client \
        nano \
        openssh \
        openssh-client \
        patch \
        postgresql-client \
        rabbitmq-c=0.8.0-r4 \
        rsync \
        su-exec \
        sudo \
        tidyhtml-libs=5.6.0-r0 \
        # todo: move out tig and tmux to -dev version.
        tig \
        tmux \
        yaml=0.1.7-r0; \
    \
    apk add --update --no-cache -t .build-deps \
        autoconf \
        cmake \
        build-base \
        bzip2-dev \
        freetype-dev \
        gmp-dev \
        icu-dev \
        imagemagick-dev \
        imap-dev \
        jpeg-dev \
        libevent-dev \
        libjpeg-turbo-dev \
        libmemcached-dev \
        libmcrypt-dev \
        libpng-dev \
        librdkafka-dev \
        libtool \
        libxslt-dev \
        openldap-dev \
        pcre-dev \
        postgresql-dev \
        rabbitmq-c-dev \
        tidyhtml-dev \
        yaml-dev; \
    \
    apk add -U --no-cache -t .php-edge-rundeps -X http://dl-cdn.alpinelinux.org/alpine/edge/community/ \
        gnu-libiconv=1.15-r2; \
    \
    # Install redis-cli.
    apk add --update --no-cache redis; \
    mkdir -p /tmp/pkgs-bins; \
    mv /usr/bin/redis-cli /tmp/; \
    apk del --purge redis; \
    deluser redis; \
    mv /tmp/redis-cli /usr/bin; \
    \
    docker-php-source extract; \
    \
    # Fix for tidy extension.
    cd /usr/src/php; \
    sed -i 's/buffio.h/tidybuffio.h/' ext/tidy/*.c; \
    \
    docker-php-ext-install \
        bcmath \
        bz2 \
        calendar \
        exif \
        gmp \
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
        soap \
        sockets \
        tidy \
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
    newrelic_url="http://download.newrelic.com/php_agent/release/"; \
    wget -r -nd --no-parent -P /tmp/newrelic -Alinux-musl.tar.gz "${newrelic_url}" >/dev/null 2>&1; \
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
        amqp-1.9.3 \
        apcu-4.0.11 \
        event-2.5.1 \
        grpc-1.20.0 \
        igbinary-2.0.8 \
        imagick-3.4.4 \
        memcached-2.2.0 \
        mongodb-1.5.3 \
        oauth-1.2.3 \
        rdkafka-3.1.0 \
        redis-4.1.1 \
        uploadprogress-1.0.3.1 \
        uuid-1.0.4 \
        xdebug-2.5.5 \
        yaml-1.3.1; \
    \
    docker-php-ext-enable \
        amqp \
        apcu \
        event \
        igbinary \
        imagick \
        grpc \
        memcached \
        mongodb \
        oauth \
        redis \
        rdkafka \
        uploadprogress \
        uuid \
        xdebug \
        yaml; \
    \
    # Event extension should be loaded after sockets.
    # http://osmanov-dev-notes.blogspot.com/2013/07/fixing-php-start-up-error-unable-to.html
    mv /usr/local/etc/php/conf.d/docker-php-ext-event.ini /usr/local/etc/php/conf.d/z-docker-php-ext-event.ini; \
    \
    # Blackfire extension (they have free tier).
    mkdir -p /tmp/blackfire; \
    version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;"); \
    blackfire_url="https://blackfire.io/api/v1/releases/probe/php/alpine/amd64/${version}"; \
    wget -qO- "${blackfire_url}" | tar xz --no-same-owner -C /tmp/blackfire; \
    mv /tmp/blackfire/blackfire-*.so $(php -r "echo ini_get('extension_dir');")/blackfire.so; \
    \
    # Install composer
    wget -qO- https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer; \
    \
    # Install Walter (deprecated).
    walter_ver="1.4.0"; \
    walter_url="https://github.com/walter-cd/walter/releases/download/v${walter_ver}/walter_${walter_ver}_linux_amd64.tar.gz"; \
    wget -qO- "${walter_url}" | tar xz -C /tmp/; \
    mv /tmp/walter_linux_amd64/walter /usr/local/bin; \
    \
    { \
        echo 'export PS1="\u@${WODBY_APP_NAME:-php}.${WODBY_ENVIRONMENT_NAME:-container}:\w $ "'; \
        # Make sure PATH is the same for ssh sessions.
        echo "export PATH=${PATH}"; \
    } | tee /home/wodby/.shrc; \
    \
    # Make sure bash uses the same settings as ash.
    cp /home/wodby/.shrc /home/wodby/.bashrc; \
    cp /home/wodby/.shrc /home/wodby/.bash_profile; \
    \
    # Configure sudoers
    { \
        echo 'Defaults env_keep += "APP_ROOT FILES_DIR"' ; \
        \
        if [[ -n "${PHP_DEV}" ]]; then \
            echo 'wodby ALL=(root) NOPASSWD:SETENV:ALL'; \
        else \
            echo -n 'wodby ALL=(root) NOPASSWD:SETENV: ' ; \
            echo -n '/usr/local/bin/files_chmod, ' ; \
            echo -n '/usr/local/bin/files_chown, ' ; \
            echo -n '/usr/local/bin/files_sync, ' ; \
            echo -n '/usr/local/bin/gen_ssh_keys, ' ; \
            echo -n '/usr/local/bin/init_container, ' ; \
            echo -n '/usr/local/bin/migrate, ' ; \
            echo -n '/usr/local/sbin/php-fpm, ' ; \
            echo -n '/usr/sbin/sshd, ' ; \
            echo '/usr/sbin/crond' ; \
        fi; \
    } | tee /etc/sudoers.d/wodby; \
    \
    # Configure ldap
    echo "TLS_CACERTDIR /etc/ssl/certs/" >> /etc/openldap/ldap.conf; \
    \
    install -o wodby -g wodby -d \
        "${APP_ROOT}" \
        "${CONF_DIR}" \
        /home/wodby/.ssh; \
    \
    install -o www-data -g www-data -d \
        "${FILES_DIR}/public" \
        "${FILES_DIR}/private" \
        "${FILES_DIR}/sessions" \
        "${FILES_DIR}/xdebug/traces" \
        "${FILES_DIR}/xdebug/profiler" \
        /home/www-data/.ssh; \
    \
    chmod -R 775 "${FILES_DIR}"; \
    chown -R wodby:wodby \
        "${PHP_INI_DIR}/conf.d" \
        /usr/local/etc/php-fpm.d \
        /home/wodby/.[^.]*; \
    \
    # SSHD
    touch /etc/ssh/sshd_config; \
    chown wodby: /etc/ssh/sshd_config; \
    \
    # Crontab
    rm /etc/crontabs/root; \
    # deprecated: remove in favor of bind mounts.
    touch /etc/crontabs/www-data; \
    chown root:www-data /etc/crontabs/www-data; \
    chmod 660 /etc/crontabs/www-data; \
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
COPY bin /usr/local/bin/

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["sudo", "-E", "LD_PRELOAD=/usr/lib/preloadable_libiconv.so", "php-fpm"]
