; This file user only to override default php.ini values
; BASIC SETTINGS: $PHP_INI_DIR/php.ini
; PHP-FPM SETTINGS: /usr/local/etc/php-fpm.d/zz-www.conf

[PHP]
realpath_cache_size = {{ getenv "PHP_REALPATH_CACHE_SIZE" "4096k" }}
realpath_cache_ttl = {{ getenv "PHP_REALPATH_CACHE_TTL" "120" }}
memory_limit = {{ getenv "PHP_CLI_MEMORY_LIMIT" "-1" }}
error_reporting = {{ getenv "PHP_ERROR_REPORTING" "E_ALL" }}
log_errors_max_len = {{ getenv "PHP_LOG_ERRORS_MAX_LEN" "1024" }}
error_log = /proc/self/fd/2

[Date]
date.timezone = {{ getenv "PHP_DATE_TIMEZONE" "UTC"}}

[Pdo_mysql]
pdo_mysql.cache_size = {{ getenv "PHP_PDO_MYSQL_CACHE_SIZE" "2000" }}

[mail function]
sendmail_path = {{ getenv "PHP_SENDMAIL_PATH" "/bin/true" }}

[MySQLi]
mysqli.cache_size = {{ getenv "PHP_MYSQLI_CACHE_SIZE" "2000" }}

[Assertion]
zend.assertions = {{ getenv "PHP_ZEND_ASSERTIONS" "1" }}
assert.active = {{ getenv "PHP_ASSERT_ACTIVE" "On" }}