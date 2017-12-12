[newrelic]
extension = newrelic.so
newrelic.enabled = {{ getenv "PHP_NEWRELIC_ENABLED" "false" }}
newrelic.license = "{{ getenv "PHP_NEWRELIC_LICENSE" }}"
newrelic.appname = "{{ getenv "PHP_NEWRELIC_APPNAME" "My PHP app" }}"