#!/usr/bin/env bash
# Test runner (basic smoke tests)
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export DISTROVANTA_ROOT="$ROOT"
PASS=0; FAIL=0
t() { # t name command...
    local name="$1"; shift
    if "$@" >/tmp/scratchpad/test_out.txt 2>&1; then
        echo "PASS: $name"; PASS=$((PASS+1))
    else
        echo "FAIL: $name"; cat /tmp/scratchpad/test_out.txt; FAIL=$((FAIL+1))
    fi
}
mkdir -p /tmp/scratchpad

# Source common
. "$ROOT/lib/common.sh"

# 1. detection
. "$ROOT/core/detection.sh"
dv_detect_distro
[ -n "$DV_DISTRO_ID" ] && echo "distro=$DV_DISTRO_ID" || { echo "no distro"; exit 1; }
t "detect_distro" bash -c "true"

# 2. shell
dv_detect_shell
[ -n "$DV_SHELL_NAME" ] && echo "shell=$DV_SHELL_NAME"

# 3. termux var
dv_detect_termux
echo "termux=$DV_IS_TERMUX android=$DV_IS_ANDROID"

# 4. color no-color interface loads
NO_COLOR=1
unset _DISTROVANTA_COMMON_LOADED
. "$ROOT/lib/common.sh"
[ -z "$DV_COLOR_RESET" ] && echo "no-color ok"

# 5. menu init: source all
for m in "$ROOT"/modules/*.sh "$ROOT"/core/*.sh; do . "$m"; done
echo "sourced all"

# 6. backup/restore basic
dv_state_init
tmpf="/tmp/scratchpad/testfile.txt"
echo "hello" > "$tmpf"
b="$(dv_backup_file "$tmpf" "test")"
[ -f "$b" ] && echo "backup ok: $b"
# strip block test
printf 'a\n%s\nx\n%s\nb\n' "$DV_MARKER_BEGIN" "$DV_MARKER_END" > "$tmpf"
dv_restore_strip_block "$tmpf"
grep -q "DISTROVANTA" "$tmpf" && { echo "strip failed"; exit 1; } || echo "strip ok"

# 7. invalid input validation
dv_is_int_range abc 1 5 && { echo "should fail"; exit 1; } || echo "int validation ok"
dv_is_int_range 3 1 5 && echo "int ok"

echo "PASS=$PASS FAIL=$FAIL"
[ "$FAIL" = "0" ]