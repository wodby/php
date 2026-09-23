#!/usr/bin/env bash
# Run inside a fresh PHP container, with its normal entrypoint bypassed.
set -euo pipefail
mkdir -p "$HOME/.ssh"
printf '# custom SSH config\n' > "$HOME/.ssh/config"
printf '[user]\n\tname = Developer\n' > "$HOME/.gitconfig"
ssh_before=$(sha256sum "$HOME/.ssh/config")
git_before=$(sha256sum "$HOME/.gitconfig")
export PHP_CLI_MEMORY_LIMIT=321M
/docker-entrypoint.sh --configure-runtime
test "$(php -r 'echo ini_get("memory_limit");')" = 321M
test "$(sha256sum "$HOME/.ssh/config")" = "$ssh_before"
test "$(sha256sum "$HOME/.gitconfig")" = "$git_before"
/docker-entrypoint.sh --configure-runtime
test "$(sha256sum "$HOME/.ssh/config")" = "$ssh_before"
