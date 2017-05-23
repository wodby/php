[global]
log_level = {{ getenv "PHP_FPM_LOG_LEVEL" "notice" }}

[www]
pm = dynamic
pm.max_children = {{ getenv "PHP_FPM_MAX_CHILDREN" "48" }}
pm.start_servers = {{ getenv "PHP_FPM_START_SERVERS" "2" }}
pm.min_spare_servers = {{ getenv "PHP_FPM_MIN_SPARE_SERVERS" "1" }}
pm.max_spare_servers = {{ getenv "PHP_FPM_MAX_SPARE_SERVERS" "3" }}
pm.max_requests = {{ getenv "PHP_FPM_MAX_REQUESTS" "500" }}

php_value[display_errors] = {{ getenv "PHP_DISPLAY_ERRORS" "On" }}
php_value[display_startup_errors] = {{ getenv "PHP_DISPLAY_STARTUP_ERRORS" "On" }}
php_value[max_execution_time] = {{ getenv "PHP_MAX_EXECUTION_TIME" "120" }}
php_value[max_input_time] = {{ getenv "PHP_MAX_INPUT_TIME" "60" }}
php_value[max_input_vars] = {{ getenv "PHP_MAX_INPUT_VARS" "2000" }}
php_value[memory_limit] = {{ getenv "PHP_MEMORY_LIMIT" "512M" }}
php_value[post_max_size] = {{ getenv "PHP_POST_MAX_SIZE" "512M" }}
php_value[upload_max_filesize] = {{ getenv "PHP_UPLOAD_MAX_FILESIZE" "512M" }}
php_value[output_buffering] = {{ getenv "PHP_OUTPUT_BUFFERING" "4096" }}
php_value[always_populate_raw_post_data] = {{ getenv "PHP_ALWAYS_POPULATE_RAW_POST_DATA" "0" }}
php_value[session.auto_start] = {{ getenv "PHP_SESSION_AUTO_START" "0" }}

include = etc/php-fpm.d/env