#!/usr/bin/env bash
# A fake action catches checkout mutation without requiring a Drupal installation.
set -euo pipefail
fixture=$(mktemp -d)
trap 'rm -rf "$fixture"' EXIT
printf '#!/bin/sh\nprintf "init\\n" >> "$INIT_LOG"\n' > "$fixture/make"
chmod +x "$fixture/make"
export PATH="$fixture:$PATH" INIT_LOG="$fixture/calls"
export WODBY2_SERVICE_INIT_ACTION=init-fixture
export DEBUG=''
WODBY_RUNTIME_CONFIGURATION_ONLY=1 bash /docker-entrypoint-init.d/90_wodby_init.sh
test ! -e "$INIT_LOG"
WODBY_WORKSPACE=1 bash /docker-entrypoint-init.d/90_wodby_init.sh
test ! -e "$INIT_LOG"
bash /docker-entrypoint-init.d/90_wodby_init.sh
test "$(cat "$INIT_LOG")" = init
