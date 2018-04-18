[apcu]
extension=apcu.so
apc.enabled	= {{ getenv "PHP_APCU_ENABLED" "1" }}
apc.shm_segments = {{ getenv "PHP_APCU_SHM_SEGMENTS" "1" }}
apc.shm_size = {{ getenv "PHP_APCU_SHM_SIZE" "32M" }}
apc.entries_hint = {{ getenv "PHP_APCU_ENTRIES_HINT" "4096" }}
apc.ttl = {{ getenv "PHP_APCU_TTL" "0" }}
apc.gc_ttl = {{ getenv "PHP_APCU_GC_TTL" "3600" }}
apc.slam_defense = {{ getenv "PHP_APCU_SLAM_DEFENSE" "1" }}
apc.enable_cli = {{ getenv "PHP_APCU_ENABLE_CLI" "0" }}
apc.use_request_time = {{ getenv "PHP_APCU_USE_REQUEST_TIME" "1" }}
apc.coredump_unmap = {{ getenv "PHP_APCU_COREDUMP_UNMAP" "0" }}
apc.preload_path = {{ getenv "PHP_APCU_PRELOAD_PATH" "NULL" }}

{{ if getenv "PHP_APCU_SERIALIZER" }}
; Default value of serializer is "php" when it's not set
; Despite the segfault bug was resolved, avoid using "default" for safety
; https://github.com/krakjoe/apcu/issues/260
; https://github.com/krakjoe/apcu/issues/248
apc.serializer = {{ getenv "PHP_APCU_SERIALIZER" }}
{{ end }}
