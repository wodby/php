.PHONY: git-clone git-checkout walter check-ready check-live

check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Required parameter is missing: $1$(if $2, ($2))))

is_hash ?= 0

default: check-ready

git-clone:
	$(call check_defined, url, branch)
	git-clone.sh $(url) $(branch)

git-checkout:
	$(call check_defined, target)
	git-checkout.sh $(target) $(is_hash)

walter:
	walter -c "$(APP_ROOT)/wodby.yml"

check-ready:
	exit 0

check-live:
	@echo "OK"
