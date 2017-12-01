[global]
log_level = {{ getenv "PHP_FPM_LOG_LEVEL" "notice" }}

[www]
clear_env = {{ getenv "PHP_FPM_CLEAR_ENV" "yes" }}
pm = {{ getenv "PHP_FPM_PM" "dynamic" }}
pm.max_children = {{ getenv "PHP_FPM_PM_MAX_CHILDREN" "8" }}
pm.start_servers = {{ getenv "PHP_FPM_PM_START_SERVERS" "2" }}
pm.min_spare_servers = {{ getenv "PHP_FPM_PM_MIN_SPARE_SERVERS" "1" }}
pm.max_spare_servers = {{ getenv "PHP_FPM_PM_MAX_SPARE_SERVERS" "3" }}
pm.max_requests = {{ getenv "PHP_FPM_PM_MAX_REQUESTS" "500" }}
{{ if getenv "PHP_FPM_PM_STATUS_PATH" }}
pm.status_path = {{ getenv "PHP_FPM_PM_STATUS_PATH" }}
{{ end }}
{{ if getenv "PHP_FPM_REQUEST_SLOWLOG_TIMEOUT" }}
slowlog = /proc/self/fd/2
request_slowlog_timeout = {{ getenv "PHP_FPM_REQUEST_SLOWLOG_TIMEOUT" }}
{{ end }}

php_value[display_errors] = {{ getenv "PHP_DISPLAY_ERRORS" "On" }}
php_value[display_startup_errors] = {{ getenv "PHP_DISPLAY_STARTUP_ERRORS" "On" }}
php_value[expose_php] = {{ getenv "PHP_EXPOSE" "Off" }}
php_value[max_execution_time] = {{ getenv "PHP_MAX_EXECUTION_TIME" "120" }}
php_value[max_input_time] = {{ getenv "PHP_MAX_INPUT_TIME" "60" }}
php_value[max_input_vars] = {{ getenv "PHP_MAX_INPUT_VARS" "2000" }}
php_value[memory_limit] = {{ getenv "PHP_MEMORY_LIMIT" "512M" }}
php_value[post_max_size] = {{ getenv "PHP_POST_MAX_SIZE" "32M" }}
php_value[upload_max_filesize] = {{ getenv "PHP_UPLOAD_MAX_FILESIZE" "32M" }}
php_value[max_file_uploads] = {{ getenv "PHP_MAX_FILE_UPLOADS" "20" }}
php_value[output_buffering] = {{ getenv "PHP_OUTPUT_BUFFERING" "4096" }}
php_value[session.auto_start] = {{ getenv "PHP_SESSION_AUTO_START" "0" }}

{{ if (getenv "PHP_FPM_USER") }}user = {{ getenv "PHP_FPM_USER" }}{{ end }}
{{ if (getenv "PHP_FPM_GROUP") }}group = {{ getenv "PHP_FPM_GROUP" }}{{ end }}

{{ if getenv "PHP_FPM_ENV_VARS" }}{{ range jsonArray (getenv "PHP_FPM_ENV_VARS") }}{{ if getenv . }}
env[{{.}}] = {{ getenv . }}{{ end }}{{ end }}{{ end }}

; Pool for health-check pings to avoid spam in access log.
[ping]
pm = static
pm.max_children = 1
listen = [::]:9001
ping.path = "/ping"

{{ if (getenv "PHP_FPM_USER") }}user = {{ getenv "PHP_FPM_USER" }}{{ end }}
{{ if (getenv "PHP_FPM_GROUP") }}group = {{ getenv "PHP_FPM_GROUP" }}{{ end }}
