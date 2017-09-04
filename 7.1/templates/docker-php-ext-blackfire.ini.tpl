{{ if getenv "PHP_BLACKFIRE" }}
extension=blackfire.so
blackfire.agent_socket=tcp://{{ getenv "PHP_BLACKFIRE_AGENT_HOST" "blackfire" }}:{{ getenv "PHP_BLACKFIRE_AGENT_PORT" "8707" }}
{{ end }}