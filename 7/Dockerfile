ARG FROM_TAG

FROM wodby/base-php:${FROM_TAG}

ARG PHP_DEV
ARG PHP_DEBUG

ARG WODBY_USER_ID=1000
ARG WODBY_GROUP_ID=1000

ENV PHP_DEV="${PHP_DEV}" \
    PHP_DEBUG="${PHP_DEBUG}" \
    SSHD_PERMIT_USER_ENV="yes" \
    PHP_PRESTISSIMO_VER="0.3" \
    WALTER_VER="1.3.0" \
    \
    LD_PRELOAD="/usr/lib/preloadable_libiconv.so php"

ENV APP_ROOT="/var/www/html" \
    CONF_DIR="/var/www/conf" \
    FILES_DIR="/mnt/files"

ENV PATH="${PATH}:/home/wodby/.composer/vendor/bin:${APP_ROOT}/vendor/bin" \
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
        c-client=2007f-r7 \
        fcgi \
        findutils \
        geoip=1.6.11-r0 \
        git \
        gmp=6.1.2-r1 \
        icu-libs=59.1-r1 \
        jpegoptim=1.4.4-r0 \
        less \
        libbz2=1.0.6-r6 \
        libjpeg-turbo=1.5.2-r0 \
        libjpeg-turbo-utils \
        libldap=2.4.45-r3 \
        libltdl=2.4.6-r4 \
        libmemcached-libs=1.0.18-r2 \
        libmcrypt=2.5.8-r7 \
        libpng=1.6.34-r1 \
        librdkafka=0.11.1-r1 \
        libxslt=1.1.31-r0 \
        make \
        mariadb-client=10.1.32-r0 \
        nano \
        openssh \
        openssh-client \
        patch \
        postgresql-client=10.5-r0 \
        rabbitmq-c=0.8.0-r3 \
        rsync \
        su-exec \
        sudo \
        tidyhtml-libs=5.4.0-r0 \
        tig \
        tmux \
        yaml=0.1.7-r0; \
    \
    apk add --update --no-cache -t .build-deps \
        autoconf \
        cmake \
        build-base \
        bzip2-dev \
        geoip-dev \
        gmp-dev \
        icu-dev \
        imap-dev \
        jpeg-dev \
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
    apk add -U --no-cache -t .php-edge-rundeps \
        -X http://dl-cdn.alpinelinux.org/alpine/edge/testing/ \
        -X http://dl-cdn.alpinelinux.org/alpine/edge/main/ \
        -X http://dl-cdn.alpinelinux.org/alpine/edge/community/ \
        freetype=2.9.1-r2 \
        gnu-libiconv=1.15-r1 \
        # @todo install imagemagick from stable repository once it comes with --disable-openmp option.
        imagemagick=7.0.8.11-r0; \
    \
    apk add -U --no-cache -t .edge-build-deps \
        -X http://dl-cdn.alpinelinux.org/alpine/edge/main/ \
        -X http://dl-cdn.alpinelinux.org/alpine/edge/community/ \
        # @todo install imagemagick from stable repository once it comes with --disable-openmp option.
        freetype-dev=2.9.1-r2 \
        imagemagick-dev=7.0.8.11-r0; \
    \
    # Install redis-cli.
    apk add --update --no-cache redis; \
    mv /usr/bin/redis-cli /tmp/; \
    apk del --purge redis; \
    deluser redis; \
    mv /tmp/redis-cli /usr/bin; \
    \
    docker-php-source extract; \
    \
    # Fix for tidy extension.
    if [[ "${PHP_VERSION:0:3}" == "7.0" ]]; then \
        cd /usr/src/php; \
        sed -i 's/buffio.h/tidybuffio.h/' ext/tidy/*.c; \
    fi; \
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
      docker-php-ext-install "-j${NPROC}" gd; \
    \
    pecl config-set php_ini "${PHP_INI_DIR}/php.ini"; \
    \
    # mcrypt moved to pecl in PHP 7.2
    if [[ "${PHP_VERSION:0:3}" == "7.2" ]]; then \
        pecl install mcrypt-1.0.1; \
        docker-php-ext-enable mcrypt; \
    else \
        docker-php-ext-install mcrypt; \
    fi; \
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
        apcu-5.1.12 \
        ast-0.1.6 \
        ds-1.2.6 \
        geoip-1.1.1 \
        grpc-1.15.0 \
        igbinary-2.0.7 \
        imagick-3.4.3 \
        memcached-3.0.4 \
        mongodb-1.5.2 \
        oauth-2.0.2 \
        rdkafka-3.0.5 \
        redis-4.1.1 \
        xdebug-2.6.1 \
        yaml-2.0.2; \
    \
    docker-php-ext-enable \
        amqp \
        apcu \
        ast \
        ds \
        igbinary \
        imagick \
        geoip \
        grpc \
        memcached \
        mongodb \
        oauth \
        redis \
        rdkafka \
        xdebug \
        yaml; \
    \
    # Blackfire extension (they have free tier).
    mkdir -p /tmp/blackfire; \
    version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;"); \
    blackfire_url="https://blackfire.io/api/v1/releases/probe/php/alpine/amd64/${version}"; \
    wget -qO- "${blackfire_url}" | tar xz --no-same-owner -C /tmp/blackfire; \
    mv /tmp/blackfire/blackfire-*.so $(php -r "echo ini_get('extension_dir');")/blackfire.so; \
    \
    # Uploadprogress.
    mkdir -p /usr/src/php/ext/uploadprogress; \
    up_url="https://github.com/wodby/pecl-php-uploadprogress/archive/latest.tar.gz"; \
    wget -qO- "${up_url}" | tar xz --strip-components=1 -C /usr/src/php/ext/uploadprogress; \
    docker-php-ext-install uploadprogress; \
    \
    # Tideways xhprof.
    xhprof_ext_ver="5.0-beta2"; \
    mkdir -p /usr/src/php/ext/tideways_xhprof; \
    xhprof_url="https://github.com/tideways/php-xhprof-extension/archive/v${xhprof_ext_ver}.tar.gz"; \
    wget -qO- "${xhprof_url}" | tar xz --strip-components=1 -C /usr/src/php/ext/tideways_xhprof; \
    docker-php-ext-install tideways_xhprof; \
    \
    wget -qO- https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer; \
    \
    # Plugin for parallel install.
    su-exec wodby composer global require "hirak/prestissimo:^${PHP_PRESTISSIMO_VER}"; \
    \
    # Install Walter (deprecated).
    walter_url="https://github.com/walter-cd/walter/releases/download/v${WALTER_VER}/walter_${WALTER_VER}_linux_amd64.tar.gz"; \
    wget -qO- "${walter_url}" | tar xz -C /tmp/; \
    mv /tmp/walter_linux_amd64/walter /usr/local/bin; \
    \
    { \
        echo 'export PS1="\u@${WODBY_APP_NAME:-php}.${WODBY_ENVIRONMENT_NAME:-container}:\w $ "'; \
        # Make sure PATH is the same for ssh sessions.
        echo "export PATH=${PATH}"; \
    } | tee /home/wodby/.shrc; \
    \
    cp /home/wodby/.shrc /home/wodby/.bashrc; \
    cp /home/wodby/.shrc /home/wodby/.bash_profile; \
    \
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
        "${FILES_DIR}/xdebug/traces" \
        "${FILES_DIR}/xdebug/profiler" \
        /home/www-data/.ssh; \
    \
    chmod -R 775 "${FILES_DIR}"; \
    chown -R wodby:wodby \
        "${PHP_INI_DIR}/conf.d" \
        /usr/local/etc/php-fpm.d \
        /home/wodby/.*; \
    \
    touch /etc/ssh/sshd_config; \
    chown wodby: /etc/ssh/sshd_config; \
    \
    rm /etc/crontabs/root; \
    # deprecated: remove in favor of bind mounts.
    touch /etc/crontabs/www-data; \
    chown root:www-data /etc/crontabs/www-data; \
    chmod 660 /etc/crontabs/www-data; \
    \
    su-exec wodby composer clear-cache; \
    docker-php-source delete; \
    apk del --purge .build-deps .edge-build-deps; \
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
    fi

USER wodby

WORKDIR ${APP_ROOT}
EXPOSE 9000

COPY templates /etc/gotpl/
COPY docker-entrypoint.sh /
COPY bin /usr/local/bin/

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["sudo", "-E", "LD_PRELOAD=/usr/lib/preloadable_libiconv.so", "php-fpm"]
