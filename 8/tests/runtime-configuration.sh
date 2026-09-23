#!/usr/bin/env bash
# Run inside a fresh PHP container, with its normal entrypoint bypassed.
set -euo pipefail
mkdir -p "$HOME/.ssh"
printf '# custom SSH config\n' > "$HOME/.ssh/config"
printf '[user]\n\tname = Developer\n' > "$HOME/.gitconfig"
ssh_before=$(sha256sum "$HOME/.ssh/config")
git_before=$(sha256sum "$HOME/.gitconfig")
export PHP_CLI_MEMORY_LIMIT=321M
# Configuration must not execute a checkout action, even when one is configured.
export WODBY2_SERVICE_INIT_ACTION=nonexistent-workspace-test-action
/docker-entrypoint.sh --configure-runtime
test "$(php -r 'echo ini_get("memory_limit");')" = 321M
test "$(sha256sum "$HOME/.ssh/config")" = "$ssh_before"
test "$(sha256sum "$HOME/.gitconfig")" = "$git_before"
/docker-entrypoint.sh --configure-runtime
test "$(sha256sum "$HOME/.ssh/config")" = "$ssh_before"

# Live code must be revalidated even when production disabled timestamp checks.
export WODBY_WORKSPACE=1 PHP_OPCACHE_VALIDATE_TIMESTAMPS=0 PHP_OPCACHE_REVALIDATE_FREQ=60
/docker-entrypoint.sh --configure-runtime
test "$(php -r 'echo ini_get("opcache.validate_timestamps");')" = 1
test "$(php -r 'echo ini_get("opcache.revalidate_freq");')" = 0
unset WODBY_WORKSPACE
/docker-entrypoint.sh --configure-runtime
test "$(php -r 'echo ini_get("opcache.validate_timestamps");')" = 0
test "$(php -r 'echo ini_get("opcache.revalidate_freq");')" = 60
