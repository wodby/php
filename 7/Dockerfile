ARG PHP_VER

FROM php:${PHP_VER}-fpm-alpine3.15

ARG PHP_DEV

ARG PECL_HTTP_PROXY

ARG WODBY_USER_ID=1000
ARG WODBY_GROUP_ID=1000

ENV PHP_DEV="${PHP_DEV}"

ENV APP_ROOT="/var/www/html" \
    CONF_DIR="/var/www/conf" \
    FILES_DIR="/mnt/files"

ENV PATH="${PATH}:/home/wodby/.composer/vendor/bin:${APP_ROOT}/vendor/bin:${APP_ROOT}/bin" \
    SSHD_HOST_KEYS_DIR="/etc/ssh" \
    ENV="/home/wodby/.shrc" \
    \
    GIT_USER_EMAIL="wodby@example.com" \
    GIT_USER_NAME="wodby"

ARG TARGETPLATFORM
ARG TARGETARCH

RUN set -xe; \
    \
    # Delete existing user/group if uid/gid occupied.
    existing_group=$(getent group "${WODBY_GROUP_ID}" | cut -d: -f1); \
    if [[ -n "${existing_group}" ]]; then delgroup "${existing_group}"; fi; \
    existing_user=$(getent passwd "${WODBY_USER_ID}" | cut -d: -f1); \
    if [[ -n "${existing_user}" ]]; then deluser "${existing_user}"; fi; \
    \
	apk add --update --no-cache shadow; \
	groupadd -g "${WODBY_GROUP_ID}" wodby; \
	useradd  -u "${WODBY_USER_ID}" -m -s /bin/bash -g wodby wodby; \
	adduser wodby www-data; \
	sed -i '/^wodby/s/!/*/' /etc/shadow; \
	\
    apk add --update --no-cache -t .wodby-php-run-deps \
        bash \
        brotli-libs \
        c-client \
        curl \
        fcgi \
        findutils \
        freetype \
        git \
        gmp \
        gzip \
        icu-libs \
        imagemagick\
        jpegoptim \
        less \
        libbz2 \
        libevent \
        libjpeg-turbo \
        libjpeg-turbo-utils \
        libldap \
        libltdl \
        libmemcached-libs \
        libmcrypt \
        libpng \
        librdkafka \
        libsmbclient \
        libuuid \
        libwebp \
        libxml2 \
        libxslt \
        libzip \
        make \
        mariadb-client \
        mariadb-connector-c \
        nano \
        openssh \
        openssh-client \
        patch \
	    pngquant \
        postgresql-client \
        rabbitmq-c \
        rsync \
        sqlite \
        ssmtp \
        su-exec \
        sudo \
        tar \
        tidyhtml-libs \
        # todo: move out tig and tmux to -dev version.
        tig \
        tmux \
        unzip \
        wget \
        yaml; \
    \
    if [[ -n "${PHP_DEV}" ]]; then \
        apk add --update --no-cache -t .wodby-php-dev-run-deps yarn; \
    fi; \
    \
    apk add --update --no-cache -t .wodby-php-build-deps \
        autoconf \
        automake \
        cmake \
        brotli-dev \
        build-base \
        bzip2-dev \
        freetype-dev \
        go \
        gmp-dev \
        icu-dev \
        imagemagick-dev \
        imap-dev \
        jpeg-dev \
        krb5-dev \
        libevent-dev \
        libgcrypt-dev \
        libjpeg-turbo-dev \
        libmemcached-dev \
        libmcrypt-dev \
        libpng-dev \
        librdkafka-dev \
        libtool \
        libwebp-dev \
        libxslt-dev \
        libzip-dev \
        linux-headers \
        openldap-dev \
        openssl-dev \
        pcre-dev \
        postgresql-dev \
        rabbitmq-c-dev \
        samba-dev \
        tidyhtml-dev \
        unixodbc-dev \
        yaml-dev; \
    \
    # Install redis-cli.
    apk add --update --no-cache redis; \
    mv /usr/bin/redis-cli /tmp/; \
    apk del --purge redis; \
    deluser redis; \
    mv /tmp/redis-cli /usr/bin; \
    \
    # Download helper scripts.
    dockerplatform=${TARGETPLATFORM:-linux/amd64};\
    gotpl_url="https://github.com/wodby/gotpl/releases/download/0.3.3/gotpl-${dockerplatform/\//-}.tar.gz"; \
    wget -qO- "${gotpl_url}" | tar xz --no-same-owner -C /usr/local/bin; \
    git clone https://github.com/wodby/alpine /tmp/alpine; \
    cd /tmp/alpine; \
    latest=$(git describe --abbrev=0 --tags); \
    git checkout "${latest}"; \
    mv /tmp/alpine/bin/* /usr/local/bin; \
    \
    docker-php-source extract; \
    cp /usr/src/php/php.ini-production "${PHP_INI_DIR}/php.ini"; \
    \
    docker-php-ext-install \
        bcmath \
        bz2 \
        calendar \
        exif \
        gmp \
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
    if [[ "${PHP_VERSION:0:3}" == "7.4" ]]; then \
        docker-php-ext-configure gd \
            --with-webp \
            --with-freetype \
            --with-jpeg; \
    else \
        docker-php-ext-configure gd \
            --with-gd \
            --with-webp-dir \
            --with-freetype-dir=/usr/include/ \
            --with-png-dir=/usr/include/ \
            --with-jpeg-dir=/usr/include/; \
    fi; \
    NPROC=$(getconf _NPROCESSORS_ONLN); \
    docker-php-ext-install "-j${NPROC}" gd; \
    \
    # IMAP
    PHP_OPENSSL=yes docker-php-ext-configure imap \
        --with-kerberos \
        --with-imap-ssl; \
    docker-php-ext-install "-j${NPROC}" imap; \
    \
    pecl config-set php_ini "${PHP_INI_DIR}/php.ini"; \
    if [[ -n "${PECL_HTTP_PROXY}" ]]; then \
        # Using pear as pecl throw errors: https://blog.flowl.info/2015/peclpear-behind-proxy-how-to/
        pear config-set http_proxy "${PECL_HTTP_PROXY}"; \
    fi; \
    \
    # Microsoft ODBC driver for SQL Server
    curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/msodbcsql17_17.6.1.1-1_amd64.apk && \
    apk add --allow-untrusted msodbcsql17_17.6.1.1-1_amd64.apk; \
    curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/mssql-tools_17.6.1.1-1_amd64.apk && \
    apk add --allow-untrusted mssql-tools_17.6.1.1-1_amd64.apk; \
    rm ./*.apk; \
    \
    pecl install \
        amqp-1.11.0 \
        apcu-5.1.21 \
        ast-1.0.16 \
        ds-1.3.0 \
        event-3.0.6 \
#        grpc-1.34.0 \
        igbinary-3.2.7 \
        imagick-3.7.0 \
        mcrypt-1.0.4 \
        memcached-3.2.0 \
        mongodb-1.13.0 \
        oauth-2.0.7 \
        pcov \
        pdo_sqlsrv-5.10.1 \
        rdkafka-6.0.1 \
        redis-5.3.7 \
        sqlsrv-5.10.1 \
        smbclient-1.0.6 \
        uploadprogress-2.0.2 \
        uuid-1.2.0 \
        xdebug-3.1.5 \
        xhprof-2.3.5 \
        yaml-2.2.2; \
    \
    docker-php-ext-enable \
        amqp \
        apcu \
        ast \
        ds \
        event \
        igbinary \
        imagick \
#        grpc \
        mcrypt \
        memcached \
        mongodb \
        oauth \
        pcov \
        pdo_sqlsrv \
        redis \
        rdkafka \
        smbclient \
        sqlsrv \
        uploadprogress \
        uuid \
        xdebug \
        xhprof \
        yaml; \
    \
    # Event extension should be loaded after sockets.
    # http://osmanov-dev-notes.blogspot.com/2013/07/fixing-php-start-up-error-unable-to.html
    mv /usr/local/etc/php/conf.d/docker-php-ext-event.ini /usr/local/etc/php/conf.d/z-docker-php-ext-event.ini; \
    \
    # Blackfire extension.
    mkdir -p /tmp/blackfire; \
    version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;"); \
    blackfire_url="https://blackfire.io/api/v1/releases/probe/php/alpine/${TARGETARCH}/${version}"; \
    wget -qO- "${blackfire_url}" | tar xz --no-same-owner -C /tmp/blackfire; \
    mv /tmp/blackfire/blackfire-*.so $(php -r "echo ini_get('extension_dir');")/blackfire.so; \
    if [[ -n "${PHP_DEV}" ]]; then \
        mkdir -p /tmp/blackfire; \
        curl -L "https://packages.blackfire.io/binaries/blackfire/2.10.0/blackfire-linux_${TARGETARCH}.tar.gz" | tar zxp -C /tmp/blackfire; \
        mv /tmp/blackfire/blackfire /usr/local/bin/blackfire; \
        rm -Rf /tmp/blackfire; \
        \
        apk add --update --no-cache -t .wodby-php-dev-run-deps yarn; \
    fi; \
    \
    # NewRelic extension and agent.
    git clone https://github.com/newrelic/newrelic-php-agent /tmp/newrelic; \
    cd /tmp/newrelic; \
    make all; \
    make agent-install; \
    mv bin/daemon /usr/bin/newrelic-daemon; \
    mkdir -p /var/log/newrelic/; \
    chown -R www-data:www-data /var/log/newrelic/; \
    chmod -R 775 /var/log/newrelic/; \
    \
    # Brotli extension.
    brotli_ext_ver="0.13.1"; \
    mkdir -p /usr/src/php/ext/brotli; \
    brotli_url="https://github.com/kjdev/php-ext-brotli/archive/refs/tags/${brotli_ext_ver}.tar.gz"; \
    wget -qO- "${brotli_url}" | tar xz --strip-components=1 -C /usr/src/php/ext/brotli; \
    docker-php-ext-configure brotli --with-libbrotli; \
    docker-php-ext-install brotli; \
    \
    mkdir -p /tmp/ioncube; \
    arch="x86-64"; \
    if [[ "${TARGETPLATFORM}" == "linux/arm64" ]]; then \
        arch="aarch64"; \
    fi; \
    ioncube_url="https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_${arch}.tar.gz"; \
    wget -qO- "${ioncube_url}" | tar xz --strip-components=1 --no-same-owner -C /tmp/ioncube; \
    version=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;"); \
    mv "/tmp/ioncube/ioncube_loader_lin_${version}.so" $(php -r "echo ini_get('extension_dir');")/ioncube.so; \
    \
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
        "${FILES_DIR}/sessions" \
        "${FILES_DIR}/xhprof" \
        "${FILES_DIR}/xdebug" \
        /home/www-data/.ssh; \
    \
    chmod -R 775 "${FILES_DIR}"; \
    chown -R wodby:wodby \
        "${PHP_INI_DIR}/conf.d" \
        /usr/local/etc/php-fpm.d \
        /etc/ssmtp/ssmtp.conf \
        /home/wodby/.[^.]*; \
    \
    touch /etc/ssh/sshd_config /etc/gitconfig; \
    chown wodby: /etc/ssh/sshd_config /etc/gitconfig; \
    chown wodby:wodby /usr/local/bin/ /usr/local/bin/composer; \
    \
    rm /etc/crontabs/root; \
    # deprecated: remove in favor of bind mounts.
    touch /etc/crontabs/www-data; \
    chown root:www-data /etc/crontabs/www-data; \
    chmod 660 /etc/crontabs/www-data; \
    \
    su-exec wodby composer clear-cache; \
    docker-php-source delete; \
    apk del --purge .wodby-php-build-deps; \
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
CMD ["sudo", "-E", "php-fpm"]
