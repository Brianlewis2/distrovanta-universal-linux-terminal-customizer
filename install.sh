#!/usr/bin/env bash
# install.sh - Simple installer for DISTROVANTA.
set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DISTROVANTA_ROOT="$SCRIPT_DIR"

. "${DISTROVANTA_ROOT}/lib/common.sh"
. "${DISTROVANTA_ROOT}/core/detection.sh"

dv_detect_distro
dv_detect_termux
dv_detect_shell

echo "DISTROVANTA installer"
echo "Distro: $DV_DISTRO_ID $DV_DISTRO_VERSION"
echo "Shell : $DV_SHELL_NAME"

# Check deps
missing=0
for c in bash printf awk sed grep uname; do
    if ! command -v "$c" >/dev/null 2>&1; then
        echo "Missing required: $c"
        missing=1
    fi
done
if [ "$missing" = "1" ]; then
    echo "Please install missing dependencies and retry."
    exit 1
fi

# Permissions
chmod +x "${DISTROVANTA_ROOT}/distrovanta.sh" 2>/dev/null
chmod +x "${DISTROVANTA_ROOT}/install.sh" 2>/dev/null

# Optional symlink
if [ -w /usr/local/bin ] 2>/dev/null; then
    ln -sf "${DISTROVANTA_ROOT}/distrovanta.sh" /usr/local/bin/distrovanta 2>/dev/null && echo "Symlink created: /usr/local/bin/distrovanta"
else
    echo "No write access to /usr/local/bin; run via ${DISTROVANTA_ROOT}/distrovanta.sh"
fi

echo "Installation complete. State dir: ${DISTROVANTA_STATE_DIR}"
echo "Run: ${DISTROVANTA_ROOT}/distrovanta.sh"