# Generic alpine-based PHP (PHP-FPM) docker container images

[![Build Status](https://travis-ci.org/wodby/php.svg?branch=master)](https://travis-ci.org/wodby/php)
[![Docker Pulls](https://img.shields.io/docker/pulls/wodby/php.svg)](https://hub.docker.com/r/wodby/php)
[![Docker Stars](https://img.shields.io/docker/stars/wodby/php.svg)](https://hub.docker.com/r/wodby/php)
[![Wodby Slack](http://slack.wodby.com/badge.svg)](http://slack.wodby.com)

## Supported tags and respective `Dockerfile` links:

- [`7.1-2.4.0`, `7.1`, `latest` (*7.1/Dockerfile*)](https://github.com/wodby/php/tree/master/7.1/Dockerfile)
- [`7.0-2.4.0`, `7.0`, (*7.0/Dockerfile*)](https://github.com/wodby/php/tree/master/7.0/Dockerfile)
- [`5.6-2.4.0`, `5.6` (*5.6/Dockerfile*)](https://github.com/wodby/php/tree/master/5.6/Dockerfile)
- [`5.3-2.4.0`, `5.3` (*5.3/Dockerfile*)](https://github.com/wodby/php/tree/master/5.3/Dockerfile)

## PHP versions

- `7.1.6`  
- `7.0.20` 
- `5.6.30` 
- `5.3.29` 

## Environment variables available for customization

The default configuration is not recommended to be used for production environment:

| Environment Variable | Default Value | Description |
| -------------------- | ------------- | ----------- |
| PHP_ALWAYS_POPULATE_RAW_POST_DATA     | 0         | <=5.6 |
| PHP_ASSERT_ACTIVE                     | On        | |
| PHP_CLI_MEMORY_LIMIT                  | -1        | |
| PHP_DATE_TIMEZONE                     | UTC       | |
| PHP_DISPLAY_ERRORS                    | On        | FPM |
| PHP_DISPLAY_STARTUP_ERRORS            | On        | FPM |
| PHP_ERROR_REPORTING                   | E_ALL     | |
| PHP_EXPOSE                            | Off       | FPM |
| PHP_FPM_LOG_LEVEL                     | notice    | |
| PHP_FPM_CLEAR_ENV                     | no        | >=5.6 |
| PHP_FPM_MAX_CHILDREN                  | 48        | |
| PHP_FPM_MAX_REQUESTS                  | 500       | |
| PHP_FPM_START_SERVERS                 | 2         | |
| PHP_FPM_MIN_SPARE_SERVERS             | 1         | |
| PHP_FPM_MAX_SPARE_SERVERS             | 3         | |
| PHP_LOG_ERRORS_MAX_LEN                | 1024      | |
| PHP_MAX_EXECUTION_TIME                | 120       | FPM |
| PHP_MAX_INPUT_TIME                    | 60        | FPM |
| PHP_MAX_INPUT_VARS                    | 2000      | FPM |
| PHP_MBSTRING_HTTP_INPUT               |           | <=5.6 |
| PHP_MBSTRING_HTTP_OUTPUT              |           | <=5.6 |
| PHP_MBSTRING_ENCODING_TRANSLATION     | Off       | <=5.6 |
| PHP_MEMORY_LIMIT                      | 512M      | FPM |
| PHP_MYSQLND_COLLECT_STATISTICS        | On        | |
| PHP_MYSQLND_COLLECT_MEMORY_STATISTICS | Off       | |
| PHP_MYSQLND_MEMPOOL_DEFAULT_SIZE      | 16000     | >=5.6 |
| PHP_MYSQLND_NET_CMD_BUFFER_SIZE       | 2048      | |
| PHP_MYSQLND_NET_READ_BUFFER_SIZE      | 32768     | |
| PHP_MYSQLND_NET_READ_TIMEOUT          | 31536000  | >=5.6 |
| PHP_MYSQL_CACHE_SIZE                  | 2000      | <=5.6 |
| PHP_MYSQLI_CACHE_SIZE                 | 2000      | |
| PHP_OPCACHE_ENABLE                    | 1         | |
| PHP_OPCACHE_VALIDATE_TIMESTAMPS       | 1         | |
| PHP_OPCACHE_REVALIDATE_FREQ           | 2         | |
| PHP_OPCACHE_MAX_ACCELERATED_FILES     | 20000     | |
| PHP_OPCACHE_MEMORY_CONSUMPTION        | 64        | |
| PHP_OPCACHE_INTERNED_STRINGS_BUFFER   | 16        | |
| PHP_OPCACHE_FAST_SHUTDOWN             | 1         | |
| PHP_OUTPUT_BUFFERING                  | 4096      | FPM |
| PHP_PDO_MYSQL_CACHE_SIZE              | 2000      | |
| PHP_POST_MAX_SIZE                     | 512M      | FPM |
| PHP_REALPATH_CACHE_SIZE               | 4096k     | >=7.0 |
| PHP_REALPATH_CACHE_SIZE               | 16k       | <=5.6 |
| PHP_REALPATH_CACHE_TTL                | 120       | |
| PHP_SENDMAIL_PATH                     | /bin/true | |
| PHP_SESSION_AUTO_START                | 0         | |
| PHP_SESSION_BUG_COMPAT_42             | On        | FPM 5.3 |
| PHP_SESSION_BUG_COMPAT_WARN           | On        | FPM 5.3 |
| PHP_TRACK_ERRORS                      | On        | | 
| PHP_UPLOAD_MAX_FILESIZE               | 512M      | FPM |
| PHP_XDEBUG                            |           | |
| PHP_XDEBUG_DEFAULT_ENABLE             | 0         | |
| PHP_XDEBUG_MAX_NESTING_LEVEL          | 256       | |
| PHP_XDEBUG_REMOTE_ENABLE              | 1         | |
| PHP_XDEBUG_REMOTE_PORT                | 9000      | |
| PHP_XDEBUG_REMOTE_AUTOSTART           | 1         | |
| PHP_XDEBUG_REMOTE_CONNECT_BACK        | 1         | |
| PHP_XDEBUG_REMOTE_HOST                | Bool      | localhost | |
| PHP_ZEND_ASSERTIONS                   | 1         | >=5.6 |

## Alpine Linux version

| PHP 7.1 | PHP 7.0 | PHP 5.6 | PHP 5.3 |
| ------- | ------- | ------- | ------- |
| 3.6     | 3.6     | 3.6     | 3.4     |

## PHP extensions

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

| Extension        | PHP 7.1  | PHP 7.0  | PHP 5.6  | PHP 5.3  |
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
> - "-" - Extension does not exist in this version

## Tools

| Tool | Version |
| ---- | ------- |
| [Gotpl](https://github.com/wodby/gotpl)       | 0.1.5  |
| [Composer](https://getcomposer.org)           | latest |
| [PHPUnit](https://phpunit.de)                 | 6.2    |
| [Walter](https://github.com/walter-cd/walter) | 1.3.0  |

## Global composer packages

| Package | Version |
| ------- | ------- |
| [hirak/prestissimo](https://packagist.org/packages/hirak/prestissimo) | ^0.3 |

## Actions

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
