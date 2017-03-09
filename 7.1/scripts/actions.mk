.PHONY: clone pull update-keys check-ready check-live

check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Required parameter is missing: $1$(if $2, ($2))))

default: pull

clone:
	$(call check_defined, git_url, git_branch)
	su-exec www-data git-clone.sh $(git_url) $(git_branch)

pull:
	su-exec www-data git-pull.sh

update-keys:
	update-keys.sh

check-ready:
	exit 0

check-live:
	@echo "OK"
