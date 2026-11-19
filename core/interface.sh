#!/usr/bin/env bash
# core/interface.sh - Banner, menus and UI helpers.

. "${DISTROVANTA_ROOT}/lib/common.sh"

# ---- Banner -----------------------------------------------------------------
dv_banner() {
    local w margin
    w="$(dv_term_width)"
    margin=$(( (w - 12) / 2 ))
    [ "$margin" -lt 0 ] && margin=0
    printf "%*s%s\n" "$margin" "" "DISTROVANTA"
    printf '\n'
}

# ---- Menu helpers -----------------------------------------------------------
dv_menu_header() {
    dv_banner
    printf '  MAIN MENU\n'
    printf '  %s\n\n' "Select an option by number."
}

dv_menu_item() {
    local num="$1" title="$2" desc="$3"
    printf '  [%s] %s\n' "$num" "$title"
    printf '       %s\n' "$desc"
}

dv_pause() {
    printf '\nPress Enter to continue...'
    IFS= read -r _ || true
    printf '\n'
}

dv_clear() {
    if command -v clear >/dev/null 2>&1; then
        clear
    else
        printf '\033[2J\033[H'
    fi
}

dv_confirm() {
    local prompt="${1:-Continue? [y/N]: }"
    local ans
    dv_read ans "$prompt"
    case "$ans" in
        y|Y|yes|YES|Yes) return 0 ;;
        *) return 1 ;;
    esac
}

dv_read_validated() {
    local varname="$1"; shift
    local prompt="$1"; shift
    local validator="${1:-}"
    local val
    while true; do
        dv_read val "$prompt"
        if [ -z "$validator" ]; then
            printf -v "$varname" '%s' "$val"
            return 0
        fi
        if "$validator" "$val"; then
            printf -v "$varname" '%s' "$val"
            return 0
        fi
        dv_err "Invalid input. Try again."
    done
}