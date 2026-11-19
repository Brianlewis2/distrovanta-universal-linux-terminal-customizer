#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export DISTROVANTA_ROOT="$ROOT"
export HOME="/tmp/scratchpad/t_br"
rm -rf "$HOME"; mkdir -p "$HOME"
. "$ROOT/lib/common.sh"
. "$ROOT/core/detection.sh"
. "$ROOT/core/interface.sh"
. "$ROOT/core/backup.sh"
. "$ROOT/core/restore.sh"
dv_state_init
f="$HOME/.bashrc"
printf 'user line\n' > "$f"
dv_backup_file "$f" "test" >/dev/null
# append managed block
{
  echo "$DV_MARKER_BEGIN"
  echo "echo hi"
  echo "$DV_MARKER_END"
} >> "$f"
dv_restore_strip_block "$f"
if grep -q "DISTROVANTA" "$f"; then echo "FAIL strip"; exit 1; fi
if ! grep -q "user line" "$f"; then echo "FAIL preserve"; exit 1; fi
echo "PASS backup/restore"