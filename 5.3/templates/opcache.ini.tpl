zend_extension = /usr/local/lib/php/extensions/no-debug-non-zts-20090626/opcache.so
opcache.enable = {{ getenv "PHP_OPCACHE_ENABLE" "1" }}
opcache.validate_timestamps = 1
opcache.revalidate_freq = 2
opcache.max_accelerated_files = 20000
opcache.memory_consumption = 64
opcache.interned_strings_buffer = 16
opcache.fast_shutdown = 1
