# PHP Docker Container Images

[![Build Status](https://travis-ci.org/wodby/php.svg?branch=master)](https://travis-ci.org/wodby/php)
[![Docker Pulls](https://img.shields.io/docker/pulls/wodby/php.svg)](https://hub.docker.com/r/wodby/php)
[![Docker Stars](https://img.shields.io/docker/stars/wodby/php.svg)](https://hub.docker.com/r/wodby/php)
[![Wodby Slack](http://slack.wodby.com/badge.svg)](http://slack.wodby.com)

## Table of Contents

* [Docker Images](#docker-images)
* [Versions](#versions)
* [Environment Variables](#environment-variables)
* [PHP Extensions](#php-extensions)
* [Tools](#tools)
* [Global Composer Packages](#global-composer-packages)
* [Orchestration Actions](#orchestration-actions)
* [Usage](#usage)

## Docker Images

Images are built via [Travis CI](https://travis-ci.org/wodby/php) and published on [Docker Hub](https://hub.docker.com/r/wodby/php). 

## Versions

| PHP version (link to Dockerfile) | Alpine Linux version |
| -------------------------------- | -------------------- |
| [7.1.6](https://github.com/wodby/php/tree/master/7.1/Dockerfile)  | 3.6 |  
| [7.0.20](https://github.com/wodby/php/tree/master/7.0/Dockerfile) | 3.6 |  
| [5.6.30](https://github.com/wodby/php/tree/master/5.6/Dockerfile) | 3.6 |  
| [5.3.29](https://github.com/wodby/php/tree/master/5.3/Dockerfile) | 3.4 |  

## Environment Variables

The default configuration is not recommended to be used for production environment:

| Environment Variable                  | 7.1       | 7.0       | 5.6       | 5.3       |     |
| ------------------------------------- | --------- | --------- | --------- | --------- | --- |
| PHP_ALWAYS_POPULATE_RAW_POST_DATA     | -         | -         | 0         | 0         |     |
| PHP_APCU_ENABLE                       | 1         | 1         | -         | -         | FPM |
| PHP_APCU_SHM_SEGMENTS                 | 1         | 1         | -         | -         | FPM |
| PHP_APCU_SHM_SIZE                     | 32M       | 32M       | -         | -         | FPM |
| PHP_APCU_ENTRIES_HINT                 | 4096      | 4096      | -         | -         | FPM |
| PHP_APCU_TTL                          | 0         | 0         | -         | -         | FPM |
| PHP_APCU_GC_TTL                       | 3600      | 3600      | -         | -         | FPM |
| PHP_APCU_SLAM_DEFENSE                 | 1         | 1         | -         | -         | FPM |
| PHP_APCU_ENABLE_CLI                   | 0         | 0         | -         | -         | FPM |
| PHP_APCU_USE_REQUEST_TIME             | 1         | 1         | -         | -         | FPM |
| PHP_APCU_SERIALIZER                   | default   | default   | -         | -         | FPM |
| PHP_APCU_COREDUMP_UNMAP               | 0         | 0         | -         | -         | FPM |
| PHP_APCU_PRELOAD_PATH                 | NULL      | NULL      | -         | -         | FPM |
| PHP_ASSERT_ACTIVE                     | On        | On        | On        | On        |     |
| PHP_CLI_MEMORY_LIMIT                  | -1        | -1        | -1        | -1        |     |
| PHP_DATE_TIMEZONE                     | UTC       | UTC       | UTC       | UTC       |     |
| PHP_DISPLAY_ERRORS                    | On        | On        | On        | On        | FPM |
| PHP_DISPLAY_STARTUP_ERRORS            | On        | On        | On        | On        | FPM |
| PHP_ERROR_REPORTING                   | E_ALL     | E_ALL     | E_ALL     | E_ALL     |     |
| PHP_EXPOSE                            | Off       | Off       | Off       | Off       | FPM |
| PHP_FPM_LOG_LEVEL                     | notice    | notice    | notice    | notice    |     |
| PHP_FPM_CLEAR_ENV                     | no        | no        | no        | -         |     |
| PHP_FPM_MAX_CHILDREN                  | 48        | 48        | 48        | 48        |     |
| PHP_FPM_MAX_REQUESTS                  | 500       | 500       | 500       | 500       |     |
| PHP_FPM_START_SERVERS                 | 2         | 2         | 2         | 2         |     |
| PHP_FPM_MIN_SPARE_SERVERS             | 1         | 1         | 1         | 1         |     |
| PHP_FPM_MAX_SPARE_SERVERS             | 3         | 3         | 3         | 3         |     |
| PHP_LOG_ERRORS_MAX_LEN                | 1024      | 1024      | 1024      | 1024      |     |
| PHP_MAX_EXECUTION_TIME                | 120       | 120       | 120       | 120       | FPM |
| PHP_MAX_INPUT_TIME                    | 60        | 60        | 60        | 60        | FPM |
| PHP_MAX_INPUT_VARS                    | 2000      | 2000      | 2000      | 2000      | FPM |
| PHP_MBSTRING_HTTP_INPUT               | -         | -         |           |           | FPM |
| PHP_MBSTRING_HTTP_OUTPUT              | -         | -         |           |           | FPM |
| PHP_MBSTRING_ENCODING_TRANSLATION     | -         | -         | Off       | Off       | FPM |
| PHP_MEMORY_LIMIT                      | 512M      | 512M      | 512M      | 512M      | FPM |
| PHP_MYSQLND_COLLECT_STATISTICS        | On        | On        | On        | On        |     |
| PHP_MYSQLND_COLLECT_MEMORY_STATISTICS | Off       | Off       | Off       | Off       |     |
| PHP_MYSQLND_MEMPOOL_DEFAULT_SIZE      | 16000     | 16000     | 16000     | -         |     |
| PHP_MYSQLND_NET_CMD_BUFFER_SIZE       | 2048      | 2048      | 2048      | 2048      |     |
| PHP_MYSQLND_NET_READ_BUFFER_SIZE      | 32768     | 32768     | 32768     | 32768     |     |
| PHP_MYSQLND_NET_READ_TIMEOUT          | 31536000  | 31536000  | 31536000  | -         |     |
| PHP_MYSQL_CACHE_SIZE                  | -         | -         | 2000      | 2000      |     |
| PHP_MYSQLI_CACHE_SIZE                 | 2000      | 2000      | 2000      | 2000      |     |
| PHP_OPCACHE_ENABLE                    | 1         | 1         | 1         | 1         |     |
| PHP_OPCACHE_VALIDATE_TIMESTAMPS       | 1         | 1         | 1         | 1         |     |
| PHP_OPCACHE_REVALIDATE_FREQ           | 2         | 2         | 2         | 2         |     |
| PHP_OPCACHE_MAX_ACCELERATED_FILES     | 20000     | 20000     | 20000     | 20000     |     |
| PHP_OPCACHE_MEMORY_CONSUMPTION        | 64        | 64        | 64        | 64        |     |
| PHP_OPCACHE_INTERNED_STRINGS_BUFFER   | 16        | 16        | 16        | 16        |     |
| PHP_OPCACHE_FAST_SHUTDOWN             | 1         | 1         | 1         | 1         |     |
| PHP_OUTPUT_BUFFERING                  | 4096      | 4096      | 4096      | 4096      | FPM |
| PHP_PDO_MYSQL_CACHE_SIZE              | 2000      | 2000      | 2000      | 2000      |     |
| PHP_POST_MAX_SIZE                     | 512M      | 512M      | 512M      | 512M      | FPM |
| PHP_REALPATH_CACHE_SIZE               | 4096k     | 4096k     | -         | -         |     |
| PHP_REALPATH_CACHE_SIZE               | -         | -         | 16k       | 16k       |     |
| PHP_REALPATH_CACHE_TTL                | 120       | 120       | 120       | 120       |     |
| PHP_SENDMAIL_PATH                     | /bin/true | /bin/true | /bin/true | /bin/true |     |
| PHP_SESSION_AUTO_START                | 0         | 0         | 0         | 0         |     |
| PHP_SESSION_BUG_COMPAT_42             | -         | -         | -         | On        | FPM |
| PHP_SESSION_BUG_COMPAT_WARN           | -         | -         | -         | On        | FPM |
| PHP_TRACK_ERRORS                      | -         | -         | -         | On        |     | 
| PHP_UPLOAD_MAX_FILESIZE               | 512M      | 512M      | 512M      | 512M      | FPM |
| PHP_XDEBUG                            |           |           |           |           |     |
| PHP_XDEBUG_DEFAULT_ENABLE             | 0         | 0         | 0         | 0         |     |
| PHP_XDEBUG_MAX_NESTING_LEVEL          | 256       | 256       | 256       | 256       |     |
| PHP_XDEBUG_REMOTE_ENABLE              | 1         | 1         | 1         | 1         |     |
| PHP_XDEBUG_REMOTE_PORT                | 9000      | 9000      | 9000      | 9000      |     |
| PHP_XDEBUG_REMOTE_AUTOSTART           | 1         | 1         | 1         | 1         |     |
| PHP_XDEBUG_REMOTE_CONNECT_BACK        | 1         | 1         | 1         | 1         |     |
| PHP_XDEBUG_REMOTE_HOST                | localhost | localhost | localhost | localhost |     |
| PHP_ZEND_ASSERTIONS                   | 1         | 1         | 1         | -         |     |

Legend:

> - "FPM" – Set only in PHP-FPM environment
> - "-" - Not available for this version

## PHP Extensions

[amqp]: http://pecl.php.net/package/amqp
[apcu]: http://pecl.php.net/package/apcu
[ast]: https://github.com/nikic/php-ast
[imagick]: https://pecl.php.net/package/imagick
[memcached]: http://pecl.php.net/package/memcached
[mongodb]: http://pecl.php.net/package/mongodb
[OAuth]: http://pecl.php.net/package/oauth
[redis]: http://pecl.php.net/package/redis
[uploadprogress]: https://pecl.php.net/package/uploadprogress
[uploadprogress]: https://pecl.php.net/package/uploadprogress
[xdebug]: https://pecl.php.net/package/xdebug
[yaml]: https://pecl.php.net/package/yaml
[latest]: https://github.com/wodby/pecl-php-uploadprogress/releases/tag/latest
[7.0.5]: https://pecl.php.net/package/ZendOpcache

| Extension        | 7.1      | 7.0      | 5.6      | 5.3      |
| ---------------- | -------- | -------- | -------- | -------- |
| [amqp]           | 1.9.1    | 1.9.1    | 1.9.1    | 1.9.1    |
| apc              | -        | -        | -        |          |
| [apcu]           | 5.1.8    | 5.1.8    | 4.0.11   | 4.0.11   |
| [ast]            | 0.1.4    | 0.1.4    | -        | -        |
| bcmath           |          |          |          |          |
| bz2              |          |          |          |          |
| calendar         |          |          |          |          |
| Core             |          |          |          |          |
| ctype            |          |          |          |          |
| curl             |          |          |          |          |
| date             |          |          |          |          |
| dom              |          |          |          |          |
| exif             |          |          |          |          |
| ereg             | -        | -        |          |          |
| fileinfo         |          |          |          |          |
| filter           |          |          |          |          |
| ftp              |          |          |          |          |
| gd               |          |          |          |          |
| hash             |          |          |          |          |
| iconv            |          |          |          |          |
| [imagick]        | 3.4.3    | 3.4.3    | 3.4.3    | -        |
| imap             |          |          |          |          |
| intl             |          |          |          |          |
| json             |          |          |          |          |
| ldap             |          |          |          |          |
| libxml           |          |          |          |          |
| mbstring         |          |          |          |          |
| mcrypt           |          |          |          |          |
| [memcached]      | 3.0.3    | 3.0.3    | 2.2.0    | 2.2.0    |
| [mongo]          | -        | -        | -        | 1.6.14   |
| [mongodb]        | 1.1.10   | 1.1.10   | 1.1.10   | -        |
| mysql            | -        | -        |          |          |
| mysqli           |          |          |          |          |
| mysqlnd          |          |          |          |          |
| [OAuth]          | 2.0.2    | 2.0.2    | 1.2.3    | 1.2.3    |
| openssl          |          |          |          |          |
| pcntl            | -        | -        |          |          |
| pcre             |          |          |          |          |
| PDO              |          |          |          |          |
| pdo_mysql        |          |          |          |          |
| pdo_pgsql        |          |          |          |          |
| pdo_sqlite       |          |          |          |          |
| pgsql            |          |          |          |          |
| Phar             |          |          |          |          |
| posix            |          |          |          |          |
| readline         |          |          |          |          |
| [redis]          | 3.1.2    | 3.1.2    | 3.1.2    | -        |
| Reflection       |          |          |          |          |
| session          |          |          |          |          |
| SimpleXML        |          |          |          |          |
| soap             |          |          |          |          |
| sockets          |          |          |          |          |
| SPL              |          |          |          |          |
| SQLite           | -        | -        | -        |          |
| sqlite3          |          |          |          |          |
| standard         |          |          |          |          |
| tokenizer        |          |          |          |          |
| [uploadprogress] | [latest] | [latest] | 1.0.3.1  | 1.0.3.1  |
| [xdebug]         | 2.5.5    | 2.5.5    | 2.5.5    | 2.2.7    |
| xml              |          |          |          |          |
| xmlreader        |          |          |          |          |
| xmlrpc           |          |          |          |          |
| xmlwriter        |          |          |          |          |
| xsl              |          |          |          |          |
| [yaml]           | 2.0.0    | 2.0.0    | 1.3.0    | 1.3.0    |
| Zend OPcache     |          |          |          | [7.0.5]  |
| zip              |          |          |          |          |
| zlib             |          |          |          |          |

Legend:

> - [NUMBER] – Extension version
> - [EMPTY] – Core PHP extension
> - "-" - Not exists in this version

## Tools

| Tool | Version |
| ---- | ------- |
| [Gotpl](https://github.com/wodby/gotpl)       | 0.1.5  |
| [Composer](https://getcomposer.org)           | latest |
| [PHPUnit](https://phpunit.de)                 | 6.2    |
| [Walter](https://github.com/walter-cd/walter) | 1.3.0  |

## Global Composer Packages

| Package | Version |
| ------- | ------- |
| [hirak/prestissimo](https://packagist.org/packages/hirak/prestissimo) | ^0.3 |

## Orchestration Actions

Usage:
```
make COMMAND [params ...]
 
commands:
    git-clone url [branch]
    git-checkout target [is_hash]   
    update-keys
    walter
    
default params values:
    is_hash 0
    branch "" Branch, tag or hash commit 
```

## Usage

Used in the following projects:

- [Drupal stack](https://github.com/wodby/docker4drupal)
- [WordPress stack](https://github.com/wodby/docker4wordpress)
