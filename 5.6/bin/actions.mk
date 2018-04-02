.PHONY: migrate git-clone git-checkout files-import files-link walter check-ready check-live

check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Required parameter is missing: $1$(if $2, ($2))))

host ?= localhost
max_try ?= 1
wait_seconds ?= 1
delay_seconds ?= 0
is_hash ?= 0
branch = ""
# Some symbols in env vars break cgi-fcgi
command ?= env -i SCRIPT_NAME="/ping" SCRIPT_FILENAME="/ping" REQUEST_METHOD=GET cgi-fcgi -bind -connect "${host}":9001 | grep -q "pong"
service = PHP-FPM

default: check-ready

migrate:
	sudo migrate $(from) $(to)

git-clone:
	$(call check_defined, url)
	git_clone $(url) $(branch)

git-checkout:
	$(call check_defined, target)
	git_checkout $(target) $(is_hash)

files-import:
	$(call check_defined, source)
	files_import $(source)

files-link:
	$(call check_defined, public_dir)
	files_link $(public_dir)

walter:
	test ! -f "$(APP_ROOT)/wodby.yml" || walter -c "$(APP_ROOT)/wodby.yml"

check-ready:
	wait_for "$(command)" $(service) $(host) $(max_try) $(wait_seconds) $(delay_seconds)

check-live:
	@echo "OK"
