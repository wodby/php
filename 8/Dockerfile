ARG PHP_VER

FROM php:${PHP_VER:-8.5}-fpm-alpine

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
    GIT_USER_NAME="wodby" \
    \
    PHP_EXTENSIONS_DISABLE='xdebug,xhprof,spx'

ARG TARGETPLATFORM
ARG TARGETARCH

RUN set -xe; \
    \
    # Delete existing user/group if uid/gid occupied. \
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
        p7zip \
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
        icu-data-full \
        imagemagick \
        imagemagick-heic \
        imagemagick-jpeg \
        imagemagick-pdf \
        imagemagick-svg \
        imagemagick-tiff \
        imagemagick-webp \
        jpegoptim \
        less \
        libavif \
        libbz2 \
        libevent \
        libgd \
        libgomp \
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
        msmtp \
        nano \
        openssh \
        openssh-client \
        patch \
	    pngquant \
        postgresql-client \
        rabbitmq-c \
        rsync \
        sqlite \
        su-exec \
        sudo \
        tar \
        tidyhtml-libs \
        # todo: move out tig and tmux to -dev version. \
        tig \
        tmux \
        unzip \
        wget \
        yaml; \
    \
    if [[ -n "${PHP_DEV}" ]]; then \
        apk add --update --no-cache -t .wodby-php-dev-run-deps npm; \
        mkdir -p /usr/local/lib/node_modules /usr/local/bin; \
        chown wodby:wodby /usr/local/lib/node_modules /usr/local/bin; \
        su-exec wodby npm install -g corepack; \
        su-exec wodby corepack enable; \
        su-exec wodby corepack prepare yarn@stable --activate; \
    fi; \
    \
    apk add --update --no-cache -t .wodby-php-build-deps \
        autoconf \
        automake \
        binutils \
        cmake \
        brotli-dev \
        build-base \
        bzip2-dev \
        freetype-dev \
        gd-dev \
        gmp-dev \
        gpg \
        gpg-agent \
        icu-dev \
        imap-dev \
        imagemagick-dev \
        jpeg-dev \
        krb5-dev \
        libavif-dev \
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
        sqlite-dev \
        tidyhtml-dev \
        unixodbc-dev \
        yaml-dev \
        zlib-dev; \
    \
    # Microsoft ODBC driver for SQL Server \
#    curl -O "https://download.microsoft.com/download/fae28b9a-d880-42fd-9b98-d779f0fdd77f/msodbcsql18_18.5.1.1-1_${TARGETARCH}.apk"; \
#    curl -O "https://download.microsoft.com/download/fae28b9a-d880-42fd-9b98-d779f0fdd77f/msodbcsql18_18.5.1.1-1_${TARGETARCH}.sig"; \
#    curl -O "https://download.microsoft.com/download/7/6/d/76de322a-d860-4894-9945-f0cc5d6a45f8/mssql-tools18_18.4.1.1-1_${TARGETARCH}.apk"; \
#    curl -O "https://download.microsoft.com/download/7/6/d/76de322a-d860-4894-9945-f0cc5d6a45f8/mssql-tools18_18.4.1.1-1_${TARGETARCH}.sig"; \
#    curl https://packages.microsoft.com/keys/microsoft.asc  | gpg --import -; \
#    gpg --verify "msodbcsql18_18.5.1.1-1_${TARGETARCH}.sig" "msodbcsql18_18.5.1.1-1_${TARGETARCH}.apk"; \
#    gpg --verify "mssql-tools18_18.4.1.1-1_${TARGETARCH}.sig" "mssql-tools18_18.4.1.1-1_${TARGETARCH}.apk"; \
#    apk add --allow-untrusted --no-interactive "msodbcsql18_18.5.1.1-1_${TARGETARCH}.apk"; \
#    apk add --allow-untrusted --no-interactive "mssql-tools18_18.4.1.1-1_${TARGETARCH}.apk"; \
#    ln -sfnv /opt/mssql-tools*/bin/* /usr/bin; \
#    rm ./*.apk; \
    \
    # Install redis-cli. \
    apk add --update --no-cache redis; \
    mv /usr/bin/redis-cli /tmp/; \
    apk del --purge redis; \
    deluser redis; \
    mv /tmp/redis-cli /usr/bin; \
    \
    # Download helper scripts. \
    gotpl_url="https://github.com/wodby/gotpl/releases/latest/download/gotpl-${TARGETPLATFORM/\//-}.tar.gz"; \
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
    NPROC=$(getconf _NPROCESSORS_ONLN); \
    if [[ "${PHP_VERSION:0:3}" == "8.2" || "${PHP_VERSION:0:3}" == "8.3" ]]; then \
      docker-php-ext-configure ftp --with-openssl-dir=/usr; \
    else \
        if [[ "${PHP_VERSION:0:3}" != "8.1" ]]; then \
          docker-php-ext-configure ftp --with-ftp-ssl=/usr; \
        fi; \
    fi; \
    docker-php-ext-install "-j${NPROC}" \
        bcmath \
        bz2 \
        calendar \
        exif \
        $(test "${PHP_VERSION:0:3}" != "8.1" && echo 'ftp') \
        gmp \
        intl \
        ldap \
        mysqli \
        $(test "${PHP_VERSION:0:3}" != "8.5" && echo 'opcache') \
        pcntl \
        pdo_mysql \
        pdo_pgsql \
        pgsql \
        soap \
        sockets \
        tidy \
        xsl \
        zip; \
    \
    # GD \
    docker-php-ext-configure gd \
                --with-external-gd \
                --with-webp \
                --with-freetype \
                --with-avif \
                --with-jpeg; \
    docker-php-ext-install "-j${NPROC}" gd; \
    \
    pecl config-set php_ini "${PHP_INI_DIR}/php.ini"; \
    if [[ -n "${PECL_HTTP_PROXY}" ]]; then \
        # Using pear as pecl throw errors: https://blog.flowl.info/2015/peclpear-behind-proxy-how-to/ \
        pear config-set http_proxy "${PECL_HTTP_PROXY}"; \
    fi; \
    \
    if [[ "${PHP_VERSION:0:3}" == "8.1" || "${PHP_VERSION:0:3}" == "8.2"  || "${PHP_VERSION:0:3}" == "8.3" ]]; then \
        PHP_OPENSSL=yes docker-php-ext-configure imap \
            --with-kerberos \
            --with-imap-ssl; \
        docker-php-ext-install "-j${NPROC}" imap; \
    fi; \
    MAKEFLAGS="-j ${NPROC}" pecl install \
        apcu-5.1.27 \
        $(test "${PHP_VERSION:0:3}" != "8.5" && echo 'amqp-2.1.2') \
        ast-1.1.3 \
        ds-1.5.0 \
        event-3.1.4 \
        $(test "${PHP_VERSION:0:3}" != "8.5" && echo 'grpc-1.76.0') \
        $(test "${PHP_VERSION:0:3}" != "8.5" && echo 'igbinary-3.2.16') \
        imagick-3.8.1 \
        $(test "${PHP_VERSION:0:3}" == "8.4" -o "${PHP_VERSION:0:3}" == "8.5" && echo 'imap-1.0.3') \
        memcached-3.4.0 \
        mongodb-2.1.4 \
        oauth-2.0.10 \
        opentelemetry-1.2.1 \
        $(test "${PHP_VERSION:0:3}" != "8.4" -a "${PHP_VERSION:0:3}" != "8.5" && echo 'pdo_sqlsrv-5.12.0') \
        pcov-1.0.12 \
        protobuf-4.30.2 \
        rdkafka-6.0.5 \
        redis-6.3.0 \
#        sqlsrv-5.12.0 \
        smbclient-1.1.1 \
        uploadprogress-2.0.2 \
        uuid-1.3.0 \
        $(test "${PHP_VERSION:0:3}" != "8.5" && echo 'xdebug-3.4.7') \
        xhprof-2.3.10 \
        yaml-2.2.5; \
    \
    docker-php-ext-enable \
        apcu \
        $(test "${PHP_VERSION:0:3}" != "8.5" && echo 'amqp') \
        ast \
        ds \
        event \
        $(test "${PHP_VERSION:0:3}" != "8.5" && echo 'grpc') \
        $(test "${PHP_VERSION:0:3}" != "8.5" && echo 'igbinary') \
        imagick \
        imap \
        memcached \
        mongodb \
        oauth \
        opentelemetry \
        $(test "${PHP_VERSION:0:3}" != "8.4" -a "${PHP_VERSION:0:3}" != "8.5" && echo 'pdo_sqlsrv') \
        pcov \
        protobuf \
        rdkafka \
        redis \
        smbclient \
#        sqlsrv \
        uploadprogress \
        uuid \
        $(test "${PHP_VERSION:0:3}" != "8.5" && echo 'xdebug') \
        xhprof \
        yaml; \
    \
    # Event extension should be loaded after sockets. \
    # http://osmanov-dev-notes.blogspot.com/2013/07/fixing-php-start-up-error-unable-to.html \
    mv /usr/local/etc/php/conf.d/docker-php-ext-event.ini /usr/local/etc/php/conf.d/z-docker-php-ext-event.ini; \
    \
    # NewRelic extension and agent. \
    newrelic_url="http://download.newrelic.com/php_agent/release/"; \
    wget -r -nd --no-parent -P /tmp/newrelic -Alinux-musl.tar.gz "${newrelic_url}" >/dev/null 2>&1; \
    tar -xzf /tmp/newrelic/newrelic-php*.tar.gz --strip=1 -C /tmp/newrelic; \
    export NR_INSTALL_SILENT=true; \
    export NR_INSTALL_USE_CP_NOT_LN=true; \
    bash /tmp/newrelic/newrelic-install install; \
    rm -f /usr/local/etc/php/conf.d/newrelic.ini; \
    mkdir -p /var/log/newrelic/; \
    chown -R www-data:www-data /var/log/newrelic/; \
    chmod -R 775 /var/log/newrelic/; \
    \
    # Brotli extension. \
    brotli_ext_ver="0.18.2"; \
    mkdir -p /usr/src/php/ext/brotli; \
    brotli_url="https://github.com/kjdev/php-ext-brotli/archive/refs/tags/${brotli_ext_ver}.tar.gz"; \
    wget -qO- "${brotli_url}" | tar xz --strip-components=1 -C /usr/src/php/ext/brotli; \
    docker-php-ext-configure brotli --with-libbrotli; \
    docker-php-ext-install "-j${NPROC}" brotli; \
    \
    # SPX extension. \
    spx_ext_ver="0.4.22"; \
    mkdir -p /usr/src/php/ext/spx; \
    spx_url="https://github.com/NoiseByNorthwest/php-spx/archive/refs/tags/v${spx_ext_ver}.tar.gz"; \
    wget -qO- "${spx_url}" | tar xz --strip-components=1 -C /usr/src/php/ext/spx; \
    docker-php-ext-configure spx; \
    docker-php-ext-install "-j${NPROC}" spx; \
    \
    wget -qO- https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer; \
    \
    # Install Walter (deprecated). \
    walter_ver="1.4.0"; \
    walter_url="https://github.com/walter-cd/walter/releases/download/v${walter_ver}/walter_${walter_ver}_linux_amd64.tar.gz"; \
    wget -qO- "${walter_url}" | tar xz -C /tmp/; \
    mv /tmp/walter_linux_amd64/walter /usr/local/bin; \
    \
    { \
        echo 'export PS1="\u@${WODBY_APP_NAME:-php}.${WODBY_ENVIRONMENT_NAME:-container}:\w $ "'; \
        # Make sure PATH is the same for ssh sessions. \
        echo "export PATH=${PATH}"; \
    } | tee /home/wodby/.shrc; \
    \
    cp /home/wodby/.shrc /home/wodby/.bashrc; \
    cp /home/wodby/.shrc /home/wodby/.bash_profile; \
    \
    { \
        echo "Defaults secure_path=\"$PATH\""; \
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
        "${FILES_DIR}/spx" \
        /home/www-data/.ssh; \
    \
    touch /etc/msmtprc; \
    chmod -R 775 "${FILES_DIR}"; \
    chown -R wodby:wodby \
        "${PHP_INI_DIR}/conf.d" \
        /usr/local/etc/php-fpm.d \
        /etc/msmtprc \
        /etc/my.cnf.d \
        /home/wodby/.[^.]*; \
    \
    touch /etc/ssh/sshd_config /etc/gitconfig; \
    chown wodby: /etc/ssh/sshd_config /etc/gitconfig; \
    chown wodby:wodby /usr/local/bin/ /usr/local/bin/composer; \
    \
    rm /etc/crontabs/root; \
    # deprecated: remove in favor of bind mounts. \
    touch /etc/crontabs/www-data; \
    chown root:www-data /etc/crontabs/www-data; \
    chmod 660 /etc/crontabs/www-data; \
    \
    if [[ -z "${PHP_DEV}" ]]; then \
        strip --strip-debug /usr/local/lib/php/extensions/no-debug-non-zts-*/*.so; \
        docker-php-source delete; \
        rm -rf /usr/src/; \
    fi; \
    \
    su-exec wodby composer clear-cache; \
    apk del --purge .wodby-php-build-deps; \
    pecl clear-cache; \
    \
    rm -rf \
        /usr/include/php \
        /usr/lib/php/build \
        /tmp/* \
        /root/.composer \
        /var/cache/apk/*


USER wodby

WORKDIR ${APP_ROOT}
EXPOSE 9000

COPY templates /etc/gotpl/
COPY docker-entrypoint.sh /
COPY bin /usr/local/bin/

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["sudo", "-E", "php-fpm"]
