#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export DISTROVANTA_ROOT="$ROOT"
export HOME="/tmp/scratchpad/t_prompt"
rm -rf "$HOME"; mkdir -p "$HOME"
. "$ROOT/lib/common.sh"
. "$ROOT/core/detection.sh"
. "$ROOT/core/interface.sh"
. "$ROOT/core/backup.sh"
. "$ROOT/core/restore.sh"
for m in "$ROOT"/modules/*.sh; do . "$m"; done
dv_state_init
dv_setting_set PROMPT_VISUAL_NAME "sombra"
dv_setting_set PROMPT_ENV_NAME "terror"
dv_setting_set PROMPT_COLOR "blue"
dv_setting_set PROMPT_SEPARATOR "@"
dv_setting_set PROMPT_SHOW_DIR "1"
out="$(dv_prompt_build)"
echo "$out"
echo "$out" | grep -q "sombra@terror" && echo "PASS prompt build" || { echo "FAIL"; exit 1; }