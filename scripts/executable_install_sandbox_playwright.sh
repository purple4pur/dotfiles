#!/usr/bin/env bash
# Run on the host: ./install_sandbox_playwright.sh CONTAINER_ID
# Install e2e chromium inside the container: switch apt sources to Tencent Cloud
# mirror (keeps .bak) + download browser via npmmirror
set -euo pipefail

CONTAINER_ID="${1:?Usage: ./install_sandbox_playwright.sh CONTAINER_ID}"
exec_in() { docker exec -u 0:0 "$CONTAINER_ID" "$@"; }

# Switch apt sources to Tencent Cloud mirror (deb822); grep asserts the switch
exec_in bash -c 'f=/etc/apt/sources.list.d/debian.sources; [ -e "$f.bak" ] || cp -a "$f" "$f.bak"; sed -i "s|deb.debian.org|mirrors.cloud.tencent.com|g" "$f" && grep -q mirrors.cloud.tencent.com "$f"'

# --with-deps runs its own apt-get update; no standalone update needed

# Shared browsers path: root default /root/.cache is unreadable by the
# non-root session user; e2e must export PLAYWRIGHT_BROWSERS_PATH=/opt/ms-playwright
exec_in env PLAYWRIGHT_BROWSERS_PATH=/opt/ms-playwright \
    PLAYWRIGHT_DOWNLOAD_HOST=https://npmmirror.com/mirrors/playwright/ \
    npm_config_registry=https://registry.npmmirror.com \
    npx -y playwright install --with-deps chromium --only-shell
exec_in chmod -R a+rX /opt/ms-playwright
