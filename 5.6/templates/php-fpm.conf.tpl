[global]
error_log = {{ getenv "PHP_FPM_ERROR_LOG" "/proc/self/fd/2" }}
log_level = {{ getenv "PHP_FPM_LOG_LEVEL" "notice" }}
daemonize = no

[app]
user = www-data
group = www-data
listen = [::]:9000
access.log = {{ getenv "PHP_FPM_ACCESS_LOG" "/proc/self/fd/2" }}
catch_workers_output = {{ getenv "PHP_FPM_CATCH_WORKERS_OUTPUT" "yes" }}
clear_env = {{ getenv "PHP_FPM_CLEAR_ENV" "yes" }}
security.limit_extensions = {{ getenv "PHP_FPM_LIMIT_EXTENSIONS" ".php" }}

pm = ondemand
pm.max_children = {{ getenv "PHP_FPM_MAX_CHILDREN" "4" }}
pm.max_requests = {{ getenv "PHP_FPM_MAX_REQUESTS" "0" }}
pm.process_idle_timeout = {{ getenv "PHP_FPM_PROCESS_IDLE_TIMEOUT" "30" }}

php_value[memory_limit] = {{ getenv "PHP_MEMORY_LIMIT" "1024M" }}
php_value[max_execution_time] = {{ getenv "PHP_MAX_EXECUTION_TIME" "300" }}
php_value[max_input_time] = {{ getenv "PHP_MAX_INPUT_TIME" "60" }}
php_value[max_input_vars] = {{ getenv "PHP_MAX_INPUT_VARS" "2000" }}
php_value[post_max_size] = {{ getenv "PHP_POST_MAX_SIZE" "512M" }}
php_value[upload_max_filesize] = {{ getenv "PHP_UPLOAD_MAX_FILESIZE" "512M" }}
php_value[display_errors] = {{ getenv "PHP_DISPLAY_ERRORS" "On" }}
php_value[display_startup_errors] = {{ getenv "PHP_DISPLAY_STARTUP_ERRORS" "On" }}
