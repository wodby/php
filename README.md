# Generic PHP docker container image

[![Build Status](https://travis-ci.org/wodby/php.svg?branch=master)](https://travis-ci.org/wodby/php)
[![Docker Pulls](https://img.shields.io/docker/pulls/wodby/php.svg)](https://hub.docker.com/r/wodby/php)
[![Docker Stars](https://img.shields.io/docker/stars/wodby/php.svg)](https://hub.docker.com/r/wodby/php)

[![Wodby Slack](https://www.google.com/s2/favicons?domain=www.slack.com) Join us on Slack](https://slack.wodby.com/)

## Supported tags and respective `Dockerfile` links:

- [`7.1-2.1.0`, `7.1`, `latest` (*7.1/Dockerfile*)](https://github.com/wodby/php/tree/master/7.1/Dockerfile)
- [`7.0-2.1.0`, `7.0`, (*7.0/Dockerfile*)](https://github.com/wodby/php/tree/master/7.0/Dockerfile)
- [`5.6-2.1.0`, `5.6` (*5.6/Dockerfile*)](https://github.com/wodby/php/tree/master/5.6/Dockerfile)
- [`5.3-2.1.0`, `5.3` (*5.3/Dockerfile*)](https://github.com/wodby/php/tree/master/5.3/Dockerfile)

## Environment Variables Available for Customization

| Environment Variable | Default Value | Description |
| -------------------- | ------------- | ----------- |
| PHP_CLI_MEMORY_LIMIT                  | -1        | |
| PHP_DATE_TIMEZONE                     | UTC       | |
| PHP_DISPLAY_ERRORS                    | On        | |
| PHP_DISPLAY_STARTUP_ERRORS            | On        | |
| PHP_ERROR_REPORTING                   | E_ALL     | |
| PHP_FPM_LOG_LEVEL                     | notice    | |
| PHP_FPM_CLEAR_ENV                     | no        | 5.3 N/A |
| PHP_FPM_MAX_CHILDREN                  | 48        | |
| PHP_FPM_MAX_REQUESTS                  | 500       | |
| PHP_FPM_START_SERVERS                 | 2         | |
| PHP_FPM_MIN_SPARE_SERVERS             | 1         | |
| PHP_FPM_MAX_SPARE_SERVERS             | 3         | |
| PHP_HTML_ERRORS                       | On        | 5.3 only |
| PHP_LOG_ERRORS_MAX_LEN                | 1024      | |
| PHP_MAX_EXECUTION_TIME                | 120       | |
| PHP_MAX_INPUT_TIME                    | 60        | |
| PHP_MAX_INPUT_VARS                    | 2000      | |
| PHP_MEMORY_LIMIT                      | 1024      | |
| PHP_MYSQLND_COLLECT_STATISTICS        | On        | |
| PHP_MYSQLND_COLLECT_MEMORY_STATISTICS | On        | |
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
| PHP_OUTPUT_BUFFERING                  | 16384     | |
| PHP_PDO_MYSQL_CACHE_SIZE              | 2000      | |
| PHP_POST_MAX_SIZE                     | 512M      | |
| PHP_REALPATH_CACHE_SIZE               | 4096k     | >=7.0 |
| PHP_REALPATH_CACHE_SIZE               | 16k       | <=5.6 |
| PHP_REALPATH_CACHE_TTL                | 120       | |
| PHP_SENDMAIL_PATH                     | /bin/true | |
| PHP_SESSION_BUG_COMPAT_42             | On        | 5.3 only |
| PHP_SESSION_BUG_COMPAT_WARN           | On        | 5.3 only |
| PHP_SESSION_CACHE_EXPIRE              | 180       | |
| PHP_SESSION_CACHE_LIMITER             | nocache   | |
| PHP_SESSION_COOKIE_LIFETIME           | 0         | |
| PHP_SESSION_GC_MAXLIFETIME            | 1440      | |
| PHP_SESSION_GC_DIVISOR                | 1000      | |
| PHP_SESSION_SAVE_HANDLER              | files     | |
| PHP_TRACK_ERRORS                      | On        | | 
| PHP_UPLOAD_MAX_FILESIZE               | 512M      | |
| PHP_URL_REWRITER_TAGS                 | a=href,area=href,frame=src,input=src,form=fakeentry | |
| PHP_URL_REWRITER_TAGS                 | form=     | 7.1 |
| PHP_XDEBUG                            |           | Set any value to enable |
| PHP_XDEBUG_DEFAULT_ENABLE             | 0         | |
| PHP_XDEBUG_MAX_NESTING_LEVEL          | 256       | |
| PHP_XDEBUG_REMOTE_ENABLE              | 1         | |
| PHP_XDEBUG_REMOTE_PORT                | 9000      | |
| PHP_XDEBUG_REMOTE_AUTOSTART           | 1         | |
| PHP_XDEBUG_REMOTE_CONNECT_BACK        | 1         | |
| PHP_XDEBUG_REMOTE_HOST                | Bool      | localhost | |
| PHP_ZEND_ASSERTIONS                   | 1         | 7.x only |

## Actions

Usage:
```
make COMMAND [params ...]
 
commands:
    git-clone url=<GIT URL> branch=<GIT BRANCH>   
    git-checkout target=<BRANCH, TAG OR COMMIT HASH> is_hash=<0|1>   
    update-keys
    walter
    
default params values:
    is_hash 0
```

## Using in Production

Deploy PHP container to your own server via [![Wodby](https://www.google.com/s2/favicons?domain=wodby.com) Wodby](https://wodby.com).