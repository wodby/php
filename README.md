# Generic PHP docker container

[![Build Status](https://travis-ci.org/wodby/php.svg?branch=master)](https://travis-ci.org/wodby/php)
[![Docker Pulls](https://img.shields.io/docker/pulls/wodby/php.svg)](https://hub.docker.com/r/wodby/php)
[![Docker Stars](https://img.shields.io/docker/stars/wodby/php.svg)](https://hub.docker.com/r/wodby/php)

## Supported tags and respective `Dockerfile` links:

- [`7.1`, `latest` (*7.1/Dockerfile*)](https://github.com/wodby/php/tree/master/7.1/Dockerfile)
- [`7.0`, (*7.0/Dockerfile*)](https://github.com/wodby/php/tree/master/7.0/Dockerfile)
- [`5.6` (*5.6/Dockerfile*)](https://github.com/wodby/php/tree/master/5.6/Dockerfile)
- [`5.3` (*5.3/Dockerfile*)](https://github.com/wodby/php/tree/master/5.3/Dockerfile)

## Environment Variables Available for Customization

| Environment Variable | Type | Default Value | Description |
| -------------------- | -----| ------------- | ----------- |
| PHP_CLI_MEMORY_LIMIT                  | Int    | -1              | |
| PHP_ERROR_REPORTING                   | String | E_ALL           | |
| PHP_TRACK_ERRORS                      | String | On              | | 
| PHP_ERROR_LOG                         | String | /proc/self/fd/2 | |
| PHP_DATE_TIMEZONE                     | String | UTC             | |
| PHP_SENDMAIL_PATH                     | String | sendmail -t -i  | |
| PHP_MYSQLND_COLLECT_STATISTICS        | String | On              | |
| PHP_MYSQLND_COLLECT_MEMORY_STATISTICS | String | On              | |
| PHP_FPM_ERROR_LOG                     | String | /proc/self/fd/2 | |
| PHP_FPM_LOG_LEVEL                     | String | notice          | |
| PHP_FPM_ACCESS_LOG                    | String | /proc/self/fd/2 | |
| PHP_FPM_CATCH_WORKERS_OUTPUT          | String | yes             | |
| PHP_FPM_CLEAR_ENV                     | String | no              | Not available for 5.3 |
| PHP_FPM_LIMIT_EXTENSIONS              | String | .php            | |
| PHP_FPM_MAX_CHILDREN                  | Int    | 4               | |
| PHP_FPM_MAX_REQUESTS                  | Int    | 0               | |
| PHP_FPM_PROCESS_IDLE_TIMEOUT          | Int    | 30              | |
| PHP_MEMORY_LIMIT                      | Int    | 1024            | |
| PHP_MAX_EXECUTION_TIME                | Int    | 300             | |
| PHP_MAX_INPUT_TIME                    | Int    | 60              | |
| PHP_MAX_INPUT_VARS                    | Int    | 2000            | |
| PHP_POST_MAX_SIZE                     | String | 512M            | |
| PHP_UPLOAD_MAX_FILESIZE               | String | 512M            | |
| PHP_DISPLAY_ERRORS                    | String | On              | |
| PHP_DISPLAY_STARTUP_ERRORS            | String | On              | |
| PHP_XDEBUG                            | Bool   |                 | |
| PHP_XDEBUG_DEFAULT_ENABLE             | Int    | 0               | |
| PHP_XDEBUG_REMOTE_ENABLE              | Int    | 1               | |
| PHP_XDEBUG_REMOTE_PORT                | Int    | 9000            | |
| PHP_XDEBUG_REMOTE_AUTOSTART           | Int    | 1               | |
| PHP_XDEBUG_REMOTE_CONNECT_BACK        | Int    | 1               | |
| PHP_XDEBUG_REMOTE_HOST                | Bool   | localhost       | |
| PHP_XDEBUG_MAX_NESTING_LEVEL          | Int    | 256             | |
