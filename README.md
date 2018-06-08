# PHP Docker Container Images

[![Build Status](https://travis-ci.org/wodby/php.svg?branch=master)](https://travis-ci.org/wodby/php)
[![Docker Pulls](https://img.shields.io/docker/pulls/wodby/php.svg)](https://hub.docker.com/r/wodby/php)
[![Docker Stars](https://img.shields.io/docker/stars/wodby/php.svg)](https://hub.docker.com/r/wodby/php)
[![Docker Layers](https://images.microbadger.com/badges/image/wodby/php.svg)](https://microbadger.com/images/wodby/php)

## Table of Contents

* [Docker Images](#docker-images)
* [Environment Variables](#environment-variables)
    * [PHP and PHP-FPM configuration](#php-and-php-fpm-configuration)
    * [Additional configuration](#additional-configuration)
* [Build arguments](#build-arguments)    
* [PHP Extensions](#php-extensions)
* [Tools](#tools)
* [Global Composer Packages](#global-composer-packages)
* [`-dev` images](#-dev-images)
* [`-dev-macos` images](#-dev-macos-images)
* [`-debug` images](#-debug-images)
* [Users and permissions](#users-and-permissions)
* [Complete PHP stack](#complete-php-stack)
* [Images based on `wodby/php`](#images-based-on-wodbyphp)
* [Orchestration Actions](#orchestration-actions)

## Docker Images

!!! For better reliability we release images with stability tags (`wodby/php:7.1-X.X.X`) which correspond to [git tags](https://github.com/wodby/php/releases). We **STRONGLY RECOMMEND** using images only with stability tags. 

About images:

* All images are based on Alpine Linux
* Base image: [wodby/base-php](https://github.com/wodby/base-php) ([wodby/alpine](https://github.com/wodby/alpine) for 5.3)
* [Travis CI builds](https://travis-ci.org/wodby/php) 
* [Docker Hub](https://hub.docker.com/r/wodby/php) 
* [`-dev`](#-dev-images) and [`-debug`](#-debug-images) images have a few differences

Supported tags and respective `Dockerfile` links:

* `7`, `7.2`, `latest` [_(Dockerfile)_](https://github.com/wodby/php/tree/master/7/Dockerfile)
* `7.1` [_(Dockerfile)_](https://github.com/wodby/php/tree/master/7/Dockerfile)
* `7.0` [_(Dockerfile)_](https://github.com/wodby/php/tree/master/7/Dockerfile)
* `5`, `5.6` [_(Dockerfile)_](https://github.com/wodby/php/tree/master/5.6/Dockerfile)
* `5.3` [_(Dockerfile)_](https://github.com/wodby/php/tree/master/5.3/Dockerfile)
* `7-dev`, `7.2-dev` [_(Dockerfile)_](https://github.com/wodby/php/tree/master/7/Dockerfile)
* `7.1-dev` [_(Dockerfile)_](https://github.com/wodby/php/tree/master/7/Dockerfile)
* `7.0-dev` [_(Dockerfile)_](https://github.com/wodby/php/tree/master/7/Dockerfile)
* `5-dev`, `5.6-dev` [_(Dockerfile)_](https://github.com/wodby/php/tree/master/5.6/Dockerfile)
* `5.3-dev` [_(Dockerfile)_](https://github.com/wodby/php/tree/master/5.3/Dockerfile)
* `7-dev-macos`, `7.2-dev-macos` [_(Dockerfile)_](https://github.com/wodby/php/tree/master/7/Dockerfile)
* `7.1-dev-macos` [_(Dockerfile)_](https://github.com/wodby/php/tree/master/7/Dockerfile)
* `7.0-dev-macos` [_(Dockerfile)_](https://github.com/wodby/php/tree/master/7/Dockerfile)
* `5-dev-macos`, `5.6-dev-macos` [_(Dockerfile)_](https://github.com/wodby/php/tree/master/5.6/Dockerfile)
* `5.3-dev-macos` [_(Dockerfile)_](https://github.com/wodby/php/tree/master/5.3/Dockerfile)
* `7-debug`, `7.2-debug` [_(Dockerfile)_](https://github.com/wodby/php/tree/master/7/Dockerfile)
* `7.1-debug` [_(Dockerfile)_](https://github.com/wodby/php/tree/master/7/Dockerfile)
* `7.0-debug` [_(Dockerfile)_](https://github.com/wodby/php/tree/master/7/Dockerfile)
* `5-debug`, `5.6-debug` [_(Dockerfile)_](https://github.com/wodby/php/tree/master/5.6/Dockerfile)

> The 5.3 version is no longer supported by PHP team, we highly encourage updating to 5.6 

## Environment Variables

#### PHP and PHP-FPM configuration

[7.x xdebug]: https://github.com/wodby/php/tree/master/7/templates/docker-php-ext-xdebug.ini.tpl
[5.6 xdebug]: https://github.com/wodby/php/tree/master/5.6/templates/docker-php-ext-xdebug.ini.tpl

[7.2 sessions]: https://github.com/wodby/php/tree/master/7/templates/docker-php-7.2.ini.tpl
[7.1 sessions]: https://github.com/wodby/php/tree/master/7/templates/docker-php-7.1.ini.tpl
[7.0 sessions]: https://github.com/wodby/php/tree/master/7/templates/docker-php-7.0.ini.tpl
[5.6 sessions]: https://github.com/wodby/php/tree/master/5.6/templates/docker-php.ini.tpl

[`PHP_ALLOW_URL_FOPEN`]: http://php.net/manual/en/filesystem.configuration.php#ini.allow-url-fopen
[`PHP_ALWAYS_POPULATE_RAW_POST_DATA`]: http://php.net/always-populate-raw-post-data
[`PHP_APCU_ENABLE_CLI`]: http://php.net/manual/en/apcu.configuration.php#ini.apcu.enable-cli
[`PHP_APCU_ENABLED`]: http://php.net/manual/en/apcu.configuration.php#ini.apcu.enabled
[`PHP_APCU_ENTRIES_HINT`]: http://php.net/manual/en/apcu.configuration.php#ini.apcu.entries-hint
[`PHP_APCU_COREDUMP_UNMAP`]: http://php.net/manual/en/apcu.configuration.php#ini.apcu.coredump-unmap
[`PHP_APCU_GC_TTL`]: http://php.net/manual/en/apcu.configuration.php#ini.apcu.gc-ttl
[`PHP_APCU_PRELOAD_PATH`]: http://php.net/manual/en/apcu.configuration.php#ini.apcu.preload-path
[`PHP_APCU_SERIALIZER`]: http://php.net/manual/en/apcu.configuration.php#ini.apcu.serializer
[`PHP_APCU_SHM_SEGMENTS`]: http://php.net/manual/en/apcu.configuration.php#ini.apcu.shm-segments
[`PHP_APCU_SHM_SIZE`]: http://php.net/manual/en/apcu.configuration.php#ini.apcu.shm-size
[`PHP_APCU_SLAM_DEFENSE`]: http://php.net/manual/en/apcu.configuration.php#ini.apcu.slam-defense
[`PHP_APCU_TTL`]: http://php.net/manual/en/apcu.configuration.php#ini.apcu.ttl
[`PHP_APCU_USE_REQUEST_TIME`]: http://php.net/manual/en/apcu.configuration.php#ini.apcu.use-request-time
[`PHP_ASSERT_ACTIVE`]: http://php.net/assert.active
[`PHP_AUTO_PREPEND_FILE`]: http://php.net/auto-prepend-file
[`PHP_AUTO_APPEND_FILE`]: http://php.net/auto-append-file
[`PHP_DATE_TIMEZONE`]: http://php.net/date.timezone
[`PHP_DEFAULT_SOCKET_TIMEOUT`]: http://php.net/manual/en/filesystem.configuration.php#ini.default-socket-timeout
[`PHP_DISPLAY_ERRORS`]: http://php.net/display-errors
[`PHP_DISPLAY_STARTUP_ERRORS`]: http://php.net/display-startup-errors
[`PHP_ERROR_REPORTING`]: http://php.net/error-reporting
[`PHP_EXPOSE`]: http://php.net/expose-php
[`PHP_GEOIP_CUSTOM_DIR`]: http://php.net/manual/en/geoip.configuration.php#ini.geoip.custom-directory
[`PHP_LOG_ERRORS`]: http://php.net/log-errors
[`PHP_LOG_ERRORS_MAX_LEN`]: http://php.net/log-errors-max-len
[`PHP_MAX_EXECUTION_TIME`]: http://php.net/max-execution-time  
[`PHP_MAX_FILE_UPLOADS`]: http://php.net/manual/en/ini.core.php#ini.max-file-uploads
[`PHP_MAX_INPUT_TIME`]: http://php.net/max-input-time
[`PHP_MAX_INPUT_VARS`]: http://php.net/max-input-vars
[`PHP_MBSTRING_HTTP_INPUT`]: http://php.net/mbstring.http-input
[`PHP_MBSTRING_HTTP_OUTPUT`]: http://php.net/mbstring.http-output
[`PHP_MBSTRING_ENCODING_TRANSLATION`]: http://php.net/mbstring.encoding-translation
[`PHP_MEMORY_LIMIT`]: http://php.net/memory-limit
[`PHP_MYSQLI_CACHE_SIZE`]: http://php.net/mysqli.cache_size
[`PHP_NEWRELIC_APPNAME`]: https://docs.newrelic.com/docs/agents/php-agent/configuration/php-agent-configuration#inivar-appname
[`PHP_NEWRELIC_CAPTURE_PARAMS`]: https://docs.newrelic.com/docs/agents/php-agent/configuration/php-agent-configuration#inivar-enabled
[`PHP_NEWRELIC_ENABLED`]: https://docs.newrelic.com/docs/agents/php-agent/configuration/php-agent-configuration#inivar-enabled
[`PHP_NEWRELIC_FRAMEWORK`]: https://docs.newrelic.com/docs/agents/php-agent/configuration/php-agent-configuration#inivar-framework
[`PHP_NEWRELIC_HIGH_SECURITY`]: https://docs.newrelic.com/docs/agents/php-agent/configuration/php-agent-configuration#inivar-high-security
[`PHP_NEWRELIC_IGNORED_PARAMS`]: https://docs.newrelic.com/docs/agents/php-agent/configuration/php-agent-configuration#inivar-ignored_params
[`PHP_NEWRELIC_LABELS`]: https://docs.newrelic.com/docs/agents/php-agent/configuration/php-agent-configuration#inivar-labels
[`PHP_NEWRELIC_LICENSE`]: https://docs.newrelic.com/docs/agents/php-agent/configuration/php-agent-configuration#inivar-license
[`PHP_NEWRELIC_LOGLEVEL`]: https://docs.newrelic.com/docs/agents/php-agent/configuration/php-agent-configuration#inivar-loglevel
[`PHP_NEWRELIC_TRANSACTION_TRACER_DETAIL`]: https://docs.newrelic.com/docs/agents/php-agent/configuration/php-agent-configuration#inivar-tt-detail
[`PHP_OPCACHE_ENABLE`]: http://php.net/manual/en/opcache.configuration.php#ini.opcache.enable
[`PHP_OPCACHE_ENABLE_CLI`]: http://php.net/manual/en/opcache.configuration.php#ini.opcache.enable-cli
[`PHP_OPCACHE_FAST_SHUTDOWN`]: http://php.net/manual/en/opcache.configuration.php#ini.opcache.fast-shutdown
[`PHP_OPCACHE_INTERNED_STRINGS_BUFFER`]: http://php.net/manual/en/opcache.configuration.php#ini.opcache.interned-strings-buffer
[`PHP_OPCACHE_MAX_ACCELERATED_FILES`]: http://php.net/manual/en/opcache.configuration.php#ini.opcache.max-accelerated-files
[`PHP_OPCACHE_MEMORY_CONSUMPTION`]: http://php.net/manual/en/opcache.configuration.php#ini.opcache.memory-consumption
[`PHP_OPCACHE_REVALIDATE_FREQ`]: http://php.net/manual/en/opcache.configuration.php#ini.opcache.revalidate-freq
[`PHP_OPCACHE_VALIDATE_TIMESTAMPS`]: http://php.net/manual/en/opcache.configuration.php#ini.opcache.validate-timestamps
[`PHP_OUTPUT_BUFFERING`]: http://php.net/output-buffering
[`PHP_PDO_MYSQL_CACHE_SIZE`]: http://php.net/pdo_mysql.cache_size
[`PHP_ZEND_ASSERTIONS`]: http://php.net/zend.assertions
[`PHP_XDEBUG_DEFAULT_ENABLE`]: https://xdebug.org/docs/all_settings
[`PHP_UPLOAD_MAX_FILESIZE`]: http://php.net/upload-max-filesize
[`PHP_TRACK_ERRORS`]: http://php.net/track-errors
[`PHP_SESSION_SAVE_HANDLER`]: http://php.net/session.save-handler
[`PHP_SENDMAIL_PATH`]: http://php.net/sendmail-path
[`PHP_REALPATH_CACHE_SIZE`]: http://php.net/realpath-cache-size
[`PHP_REALPATH_CACHE_TTL`]: http://php.net/realpath-cache-ttl
[`PHP_POST_MAX_SIZE`]: http://php.net/post-max-size
[`PHP_FPM_CLEAR_ENV`]: http://php.net/manual/en/install.fpm.configuration.php#clear-env
[`PHP_FPM_LOG_LEVEL`]: http://php.net/manual/en/install.fpm.configuration.php#log-level
[`PHP_FPM_PM`]: http://php.net/manual/en/install.fpm.configuration.php#pm
[`PHP_FPM_PM_MAX_CHILDREN`]: http://php.net/manual/en/install.fpm.configuration.php#pm.max-chidlren
[`PHP_FPM_PM_MAX_REQUESTS`]: http://php.net/manual/en/install.fpm.configuration.php#pm.max-requests
[`PHP_FPM_PM_MAX_SPARE_SERVERS`]: http://php.net/manual/en/install.fpm.configuration.php#pm.max-spare-servers
[`PHP_FPM_PM_MIN_SPARE_SERVERS`]: http://php.net/manual/en/install.fpm.configuration.php#pm.min-spare-servers
[`PHP_FPM_PM_STATUS_PATH`]: http://php.net/manual/en/install.fpm.configuration.php#pm.status-path
[`PHP_FPM_REQUEST_SLOWLOG_TIMEOUT`]: http://php.net/manual/en/install.fpm.configuration.php#request-slowlog-timeout
[`PHP_FPM_PM_START_SERVERS`]: http://php.net/manual/en/install.fpm.configuration.php#pm.start-servers
[`PHP_FPM_USER`]: http://php.net/manual/en/install.fpm.configuration.php#user
[`PHP_FPM_GROUP`]: http://php.net/manual/en/install.fpm.configuration.php#group

The default configuration is not recommended to be used for production environment:

| Variable                                   | 7.2           | 7.1           | 7.0           | 5.6           |
| -------------------------------------      | ------------- | ------------- | ------------- | ------------- |
| [`PHP_ALLOW_URL_FOPEN`]                    | `On`          | `On`          | `On`          | `On`          |
| [`PHP_ALWAYS_POPULATE_RAW_POST_DATA`]      | -             | -             | -             | `0`           |
| [`PHP_APCU_ENABLE_CLI`]                    | `0`           | `0`           | `0`           | `0`           |
| [`PHP_APCU_ENABLED`]                       | `1`           | `1`           | `1`           | `1`           |
| [`PHP_APCU_ENTRIES_HINT`]                  | `4096`        | `4096`        | `4096`        | `4096`        |
| [`PHP_APCU_COREDUMP_UNMAP`]                | `0`           | `0`           | `0`           | `0`           |
| [`PHP_APCU_GC_TTL`]                        | `3600`        | `3600`        | `3600`        | `3600`        |
| [`PHP_APCU_PRELOAD_PATH`]                  | `NULL`        | `NULL`        | `NULL`        | `NULL`        |
| [`PHP_APCU_SERIALIZER`]                    |               |               |               |               |
| [`PHP_APCU_SHM_SEGMENTS`]                  | `1`           | `1`           | `1`           | `1`           |
| [`PHP_APCU_SHM_SIZE`]                      | `32M`         | `32M`         | `32M`         | `32M`         |
| [`PHP_APCU_SLAM_DEFENSE`]                  | `1`           | `1`           | `1`           | `1`           |
| [`PHP_APCU_TTL`]                           | `0`           | `0`           | `0`           | `0`           |
| [`PHP_APCU_USE_REQUEST_TIME`]              | `1`           | `1`           | `1`           | `1`           |
| [`PHP_ASSERT_ACTIVE`]                      | `On`          | `On`          | `On`          | `On`          |
| [`PHP_AUTO_PREPEND_FILE`]                  |               |               |               |               |
| [`PHP_AUTO_APPEND_FILE`]                   |               |               |               |               |
| `PHP_BLACKFIRE`                            |               |               |               |               |
| `PHP_BLACKFIRE_AGENT_HOST`                 | `blackfire`   | `blackfire`   | `blackfire`   | `blackfire`   |
| `PHP_BLACKFIRE_AGENT_PORT`                 | `8707`        | `8707`        | `8707`        | `8707`        |
| `PHP_CLI_MEMORY_LIMIT`                     | `-1`          | `-1`          | `-1`          | `-1`          |
| [`PHP_DATE_TIMEZONE`]                      | `UTC`         | `UTC`         | `UTC`         | `UTC`         |
| [`PHP_DEFAULT_SOCKET_TIMEOUT`]             | `60`          | `60`          | `60`          | `60`          |
| [`PHP_DISPLAY_ERRORS`]                     | `On`          | `On`          | `On`          | `On`          |
| [`PHP_DISPLAY_STARTUP_ERRORS`]             | `On`          | `On`          | `On`          | `On`          |
| [`PHP_ERROR_REPORTING`]                    | `E_ALL`       | `E_ALL`       | `E_ALL`       | `E_ALL`       |
| [`PHP_EXPOSE`]                             | `Off`         | `Off`         | `Off`         | `Off`         |
| [`PHP_FPM_CLEAR_ENV`]*                     | `yes`         | `yes`         | `yes`         | `yes`         |
| `PHP_FPM_ENV_VARS`                         |               |               |               |               |
| [`PHP_FPM_LOG_LEVEL`]*                     | `notice`      | `notice`      | `notice`      | `notice`      |
| [`PHP_FPM_PM`]                             | `dynamic`     | `dynamic`     | `dynamic`     | `dynamic`     |
| [`PHP_FPM_PM_MAX_CHILDREN`]                | `8`           | `8`           | `8`           | `8`           |
| [`PHP_FPM_PM_MAX_REQUESTS`]                | `500`         | `500`         | `500`         | `500`         |
| [`PHP_FPM_PM_MAX_SPARE_SERVERS`]           | `3`           | `3`           | `3`           | `3`           |
| [`PHP_FPM_PM_MIN_SPARE_SERVERS`]           | `1`           | `1`           | `1`           | `1`           |
| [`PHP_FPM_PM_STATUS_PATH`]                 |               |               |               |               |
| [`PHP_FPM_REQUEST_SLOWLOG_TIMEOUT`]        |               |               |               |               |
| [`PHP_FPM_PM_START_SERVERS`]               | `2`           | `2`           | `2`           | `2`           |
| [`PHP_FPM_USER`]                           | `www-data`    | `www-data`    | `www-data`    | `www-data`    |
| [`PHP_FPM_GROUP`]                          | `www-data`    | `www-data`    | `www-data`    | `www-data`    |
| [`PHP_GEOIP_CUSTOM_DIR`]                   |               |               |               |               |
| `PHP_IGBINARY_COMPACT_STRINGS`             | `On`          | `On`          | `On`          | `On`          |
| [`PHP_LOG_ERRORS`]                         | `On`          | `On`          | `On`          | `On`          |
| [`PHP_LOG_ERRORS_MAX_LEN`]                 | `0`           | `0`           | `0`           | `0`           |
| [`PHP_MAX_EXECUTION_TIME`]                 | `120`         | `120`         | `120`         | `120`         |
| [`PHP_MAX_FILE_UPLOADS`]                   | `20`          | `20`          | `20`          | `20`          |
| [`PHP_MAX_INPUT_TIME`]                     | `60`          | `60`          | `60`          | `60`          |
| [`PHP_MAX_INPUT_VARS`]                     | `2000`        | `2000`        | `2000`        | `2000`        |
| [`PHP_MBSTRING_HTTP_INPUT`]                | -             | -             | -             |               |
| [`PHP_MBSTRING_HTTP_OUTPUT`]               | -             | -             | -             |               |
| [`PHP_MBSTRING_ENCODING_TRANSLATION`]      | -             | -             | -             | `Off`         |
| [`PHP_MEMORY_LIMIT`]                       | `512M`        | `512M`        | `512M`        | `512M`        |
| `PHP_MYSQL_CACHE_SIZE`                     | -             | -             | -             | `2000`        |
| [`PHP_MYSQLI_CACHE_SIZE`]                  | `2000`        | `2000`        | `2000`        | `2000`        |
| [`PHP_NEWRELIC_APPNAME`]                   | `My PHP app`  | `My PHP app`  | `My PHP app`  | `My PHP app`  |
| [`PHP_NEWRELIC_CAPTURE_PARAMS`]            | `false`       | `false`       | `false`       | `false`       |
| [`PHP_NEWRELIC_ENABLED`]                   | `false`       | `false`       | `false`       | `false`       |
| [`PHP_NEWRELIC_FRAMEWORK`]                 |               |               |               |               |
| [`PHP_NEWRELIC_HIGH_SECURITY`]             | `false`       | `false`       | `false`       | `false`       |
| [`PHP_NEWRELIC_IGNORED_PARAMS`]            |               |               |               |               |
| [`PHP_NEWRELIC_LABELS`]                    |               |               |               |               |
| [`PHP_NEWRELIC_LICENSE`]                   |               |               |               |               |
| [`PHP_NEWRELIC_LOGLEVEL`]                  | `info`        | `info`        | `info`        | `info`        |
| [`PHP_NEWRELIC_TRANSACTION_TRACER_DETAIL`] | `1`           | `1`           | `1`           | `1`           |
| [`PHP_OPCACHE_ENABLE`]                     | `1`           | `1`           | `1`           | `1`           |
| [`PHP_OPCACHE_ENABLE_CLI`]                 | `0`           | `0`           | `0`           | `0`           |
| [`PHP_OPCACHE_VALIDATE_TIMESTAMPS`]        | `1`           | `1`           | `1`           | `1`           |
| [`PHP_OPCACHE_REVALIDATE_FREQ`]            | `2`           | `2`           | `2`           | `2`           |
| [`PHP_OPCACHE_MAX_ACCELERATED_FILES`]      | `4000`        | `4000`        | `4000`        | `4000`        |
| [`PHP_OPCACHE_MEMORY_CONSUMPTION`]         | `128`         | `128`         | `128`         | `128`         |
| [`PHP_OPCACHE_INTERNED_STRINGS_BUFFER`]    | `8`           | `8`           | `8`           | `8`           |
| [`PHP_OPCACHE_FAST_SHUTDOWN`]              | -             | `1`           | `1`           | `1`           |
| [`PHP_OUTPUT_BUFFERING`]                   | `4096`        | `4096`        | `4096`        | `4096`        |
| [`PHP_PDO_MYSQL_CACHE_SIZE`]               | `2000`        | `2000`        | `2000`        | `2000`        |
| [`PHP_POST_MAX_SIZE`]                      | `32M`         | `32M`         | `32M`         | `32M`         |
| [`PHP_REALPATH_CACHE_SIZE`]                | `4096k`       | `4096k`       | `4096k`       | `16k`         |
| [`PHP_REALPATH_CACHE_TTL`]                 | `120`         | `120`         | `120`         | `120`         |
| [`PHP_SENDMAIL_PATH`]                      | `/bin/true`   | `/bin/true`   | `/bin/true`   | `/bin/true`   |
| [`PHP_SESSION_SAVE_HANDLER`]               | `files`       | `files`       | `files`       | `files`       |
| _see all session options_                  | [7.2 session] | [7.1 session] | [7.0 session] | [5.6 session] |
| `PHP_XHPROF`                               |               |               |               | -             |
| [`PHP_TRACK_ERRORS`]                       | -             | `On`          | `On`          | `On`          |
| [`PHP_UPLOAD_MAX_FILESIZE`]                | `32M`         | `32M`         | `32M`         | `32M`         |
| `PHP_XDEBUG`                               | -             |               |               |               |
| [`PHP_XDEBUG_DEFAULT_ENABLE`]              | -             | `0`           | `0`           | `0`           |
| _see all xdebug ext options_               | [7.x xdebug]  | [7.x xdebug]  | [7.x xdebug]  | [5.6 xdebug]  |
| [`PHP_ZEND_ASSERTIONS`]                    | `1`           | `1`           | `1`           | `1`           |

> "-" - Not available for this version

> Default value of environment variables marked with `*` is different for [`-dev`](#-dev-images) and [`-debug`](#-debug-images) images

#### Additional configuration

| Variable                          | Default value       |
| --------------------------------- | ------------------- |
| `GIT_USER_EMAIL`                  | `wodby@example.com` |
| `GIT_USER_NAME`                   | `wodby`             |
| `SSH_PRIVATE_KEY`                 |                     |
| `SSH_DISABLE_STRICT_KEY_CHECKING` |                     |
| `SSHD_GATEWAY_PORTS`              | `no`                |
| `SSHD_HOST_KEYS_DIR`              | `/etc/ssh`          |
| `SSHD_LOG_LEVEL`                  | `INFO`              |
| `SSHD_PASSWORD_AUTHENTICATION`    | `no`                |
| `SSHD_PERMIT_USER_ENV`            | `no`                |
| `SSHD_USE_DNS`                    | `yes`               |

## Build arguments

| Argument         | Default value |
| ---------------- | ------------- |
| `PHP_DEV`        |               |
| `PHP_DEBUG`      |               |
| `WODBY_GROUP_ID` | `1000`        |
| `WODBY_USER_ID`  | `1000`        |

Change `WODBY_USER_ID` and `WODBY_GROUP_ID` mainly for local dev version of images, if it matches with existing system user/group ids the latter will be deleted. 

## PHP Extensions

[amqp]: http://pecl.php.net/package/amqp
[apcu]: http://pecl.php.net/package/apcu
[ast]: https://github.com/nikic/php-ast
[ds]: https://pecl.php.net/package/ds
[geoip]: https://pecl.php.net/package/geoip
[grpc]: https://pecl.php.net/package/grpc
[igbinary]: https://pecl.php.net/package/igbinary
[imagick]: https://pecl.php.net/package/imagick
[memcached]: http://pecl.php.net/package/memcached
[mongo]: http://pecl.php.net/package/mongo
[mongodb]: http://pecl.php.net/package/mongodb
[newrelic]: http://download.newrelic.com/php_agent/release
[OAuth]: http://pecl.php.net/package/oauth
[redis]: http://pecl.php.net/package/redis
[uploadprogress]: https://pecl.php.net/package/uploadprogress
[uploadprogress]: https://pecl.php.net/package/uploadprogress
[xdebug]: https://pecl.php.net/package/xdebug
[yaml]: https://pecl.php.net/package/yaml
[latest]: https://github.com/wodby/pecl-php-uploadprogress/releases/tag/latest
[7.0.5]: https://pecl.php.net/package/ZendOpcache
[1.0.1]: https://pecl.php.net/package/mcrypt
[blackfire]: https://blackfire.io/dashboard/mine/profiles
[tideways]: https://github.com/tideways/php-xhprof-extension

| Extension        | 7.2      | 7.1      | 7.0      | 5.6      |
| ---------------- | -------- | -------- | -------- | -------- |
| [amqp]           | 1.9.3    | 1.9.3    | 1.9.3    | 1.9.3    |
| apc              | -        | -        | -        | -        |
| [apcu]           | 5.1.11   | 5.1.11   | 5.1.11   | 4.0.11   |
| [ast]            | 0.1.6    | 0.1.6    | 0.1.6    | -        |
| [blackfire]      | latest   | latest   | latest   | latest   |
| bcmath           |          |          |          |          |
| bz2              |          |          |          |          |
| calendar         |          |          |          |          |
| Core             |          |          |          |          |
| ctype            |          |          |          |          |
| curl             |          |          |          |          |
| date             |          |          |          |          |
| dom              |          |          |          |          |
| [ds]             | 1.2.4    | 1.2.4    | 1.2.4    | -        |
| exif             |          |          |          |          |
| ereg             | -        | -        | -        |          |
| fileinfo         |          |          |          |          |
| filter           |          |          |          |          |
| ftp              |          |          |          |          |
| gd               |          |          |          |          |
| [geoip]          | 1.1.1    | 1.1.1    | 1.1.1    | 1.1.1    |
| [grpc]           | 1.12.0   | 1.12.0   | 1.12.0   | -        |
| hash             |          |          |          |          |
| iconv            |          |          |          |          |
| [igbinary]       | 2.0.6    | 2.0.6    | 2.0.6    | 2.0.6    |
| [imagick]        | 3.4.3    | 3.4.3    | 3.4.3    | 3.4.3    |
| imap             |          |          |          |          |
| intl             |          |          |          |          |
| json             |          |          |          |          |
| ldap             |          |          |          |          |
| libxml           |          |          |          |          |
| mbstring         |          |          |          |          |
| mcrypt           | [1.0.1]  |          |          |          |
| [memcached]      | 3.0.4    | 3.0.4    | 3.0.4    | 2.2.0    |
| [mongodb]        | 1.4.4    | 1.4.4    | 1.4.4    | 1.4.4    |
| mysql            | -        | -        | -        |          |
| mysqli           |          |          |          |          |
| mysqlnd          |          |          |          |          |
| [newrelic]       | latest   | latest   | latest   | latest   |
| [OAuth]          | 2.0.2    | 2.0.2    | 2.0.2    | 1.2.3    |
| openssl          |          |          |          |          |
| pcntl            |          |          |          |          |
| pcre             |          |          |          |          |
| PDO              |          |          |          |          |
| pdo_mysql        |          |          |          |          |
| pdo_pgsql        |          |          |          |          |
| pdo_sqlite       |          |          |          |          |
| pgsql            |          |          |          |          |
| Phar             |          |          |          |          |
| posix            |          |          |          |          |
| readline         |          |          |          |          |
| [redis]          | 3.1.6    | 3.1.6    | 3.1.6    | 3.1.6    |
| Reflection       |          |          |          |          |
| session          |          |          |          |          |
| SimpleXML        |          |          |          |          |
| soap             |          |          |          |          |
| sockets          |          |          |          |          |
| sodium           |          | -        | -        | -        |
| SPL              |          |          |          |          |
| sqlite3          |          |          |          |          |
| standard         |          |          |          |          |
| [tideways]       | 4.1.6    | 4.1.6    | 4.1.6    |          |
| tokenizer        |          |          |          |          |
| [uploadprogress] | [latest] | [latest] | [latest] | 1.0.3.1  |
| [xdebug]         | 2.6.0    | 2.6.0    | 2.6.0    | 2.5.5    |
| xml              |          |          |          |          |
| xmlreader        |          |          |          |          |
| xmlrpc           |          |          |          |          |
| xmlwriter        |          |          |          |          |
| xsl              |          |          |          |          |
| [yaml]           | 2.0.2    | 2.0.2    | 2.0.2    | 1.3.1    |
| Zend OPcache     |          |          |          |          |
| zip              |          |          |          |          |
| zlib             |          |          |          |          |

Legend:

> - [EMPTY] – Core PHP extension
> - "-" - Not exists in this version
> Some extensions may not be available in [`-dev`](#-dev-images) and [`-debug`](#-debug-images) images  

Extensions xdebug, blackfire and xhprof disabled by default.

## Tools

| Tool                                          | 7.2     | 7.1     | 7.0     | 5.6     |
| --------------------------------------------- | ------- | ------- | ------- | ------- |
| [Composer](https://getcomposer.org)           | latest  | latest  | latest  | latest  |
| [Walter](https://github.com/walter-cd/walter) | 1.3.0   | 1.3.0   | 1.3.0   | 1.3.0   |

## Global Composer Packages

| Package                                                               | Version |
| --------------------------------------------------------------------- | ------- |
| [hirak/prestissimo](https://packagist.org/packages/hirak/prestissimo) | ^0.3    |

## `-dev` Images

Images with `-dev` tag have a few differences:

* `sudo` allowed for all commands for `wodby` user
* PHP source code available under `/usr/src/php.tar.xz`
* `PHP_FPM_CLEAR_ENV` is set to `no` by default

## `-dev-macos` Images

Same as `-dev` but the default user/group `wodby` has uid/gid `501`/`20`  to match the macOS default user/group ids.

## `-debug` Images

Include all changes from `-dev` images and additionally:

* PHP compiled with `--enabled-debug` flag
* PHP binaries are not stripped from debug symbols
* Some extensions do not work with `--enabled-debug` such as newrelic and blackfire
* `PHP_FPM_LOG_LEVEL` is set to `debug` by default

## Users and permissions

Default container user is `wodby:wodby` (UID/GID `1000`). PHP-FPM runs from `www-data:www-data` user (UID/GID `82`) by default. User `wodby` is a part of `www-data` group.

Codebase volume `$APP_ROOT` (`/var/www/html`) owned by `wodby:wodby`. Files volume `$FILES_DIR` (`/mnt/files`) owned by `www-data:www-data` with `775` mode.

See https://github.com/wodby/php/issues/22 for more details.

#### Helper scripts 

* `files_chmod` – in case you need write access for `wodby` user to a file/dir generated by `www-data` on this volume run `sudo files_chmod [FILEPATH]` script (FILEPATH must be under `/mnt/files`), it will recursively change the mode to `ug=rwX,o=rX`

* `files_chown` – in case you manually uploaded files under `wodby` user to files volume and want to change the ownership of those files to `www-data` run `sudo files_chown [FILEPATH]` script (FILEPATH must be under `/mnt/files`), it will recursively change ownership to `www-data:www-data`

## Complete PHP stack

See [wodby/docker4php](https://github.com/wodby/docker4php) for the complete PHP stack.

## Images based on `wodby/php`

* [wodby/drupal-php](https://github.com/wodby/drupal-php)
* [wodby/wordpress-php](https://github.com/wodby/wordpress-php)

## Orchestration Actions

Usage:
```
make COMMAND [params ...]

commands:
    migrate
    check-ready [host max_try wait_seconds delay_seconds]
    git-clone url [branch]
    git-checkout target [is_hash]   
    files-import source
    files-link public_dir 
    update-keys
    walter

default params values:
    is_hash 0
    branch "" Branch, tag or hash commit
```
