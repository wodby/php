<?php
/**
 * @file
 * Wodby environment configuration for generic PHP project.
 */

{{ if getenv "WODBY_HOSTS" }}{{ range jsonArray (getenv "WODBY_HOSTS") }}
$wodby['hosts'][] = '{{ . }}';
{{ end }}{{ end }}

$wodby['files_dir'] = '{{ getenv "FILES_DIR" }}';

$wodby['db']['host'] = '{{ getenv "DB_HOST" }}';
$wodby['db']['name'] = '{{ getenv "DB_NAME" }}';
$wodby['db']['username'] = '{{ getenv "DB_USER" }}';
$wodby['db']['password'] = '{{ getenv "DB_PASSWORD" }}';
$wodby['db']['driver'] = '{{ getenv "DB_DRIVER" }}';

$wodby['redis']['host'] = '{{ getenv "REDIS_HOST" }}';
$wodby['redis']['port'] = '{{ getenv "REDIS_PORT" "6379" }}';
$wodby['redis']['password'] = '{{ getenv "REDIS_PASSWORD" }}';

$wodby['varnish']['host'] = '{{ getenv "VARNISH_HOST" }}';
$wodby['varnish']['terminal_port'] = '{{ getenv "VARNISH_TERMINAL_PORT" "6082" }}';
$wodby['varnish']['secret'] = '{{ getenv "VARNISH_SECRET" }}';
$wodby['varnish']['version'] = '{{ getenv "VARNISH_VERSION" }}';

$wodby['memcached']['host'] = '{{ getenv "MEMCACHED_HOST" }}';
$wodby['memcached']['port'] = '{{ getenv "MEMCACHED_PORT" "11211" }}';
