{{ if getenv "PHP_XDEBUG" }}
zend_extension = xdebug.so
xdebug.default_enable = {{ getenv "PHP_XDEBUG_DEFAULT_ENABLE" "0" }}
xdebug.remote_enable = {{ getenv "PHP_XDEBUG_REMOTE_ENABLE" "1" }}
xdebug.remote_handler = dbgp
xdebug.remote_port = {{ getenv "PHP_XDEBUG_REMOTE_PORT" "9000" }}
xdebug.remote_autostart = {{ getenv "PHP_XDEBUG_REMOTE_AUTOSTART" "1" }}
xdebug.remote_connect_back = {{ getenv "PHP_XDEBUG_REMOTE_CONNECT_BACK" "1" }}
xdebug.remote_host = {{ getenv "PHP_XDEBUG_REMOTE_HOST" "localhost" }}
xdebug.max_nesting_level = {{ getenv "PHP_XDEBUG_MAX_NESTING_LEVEL" "256" }}
{{ end }}
