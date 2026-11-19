#!/usr/bin/env bash
# core/interface.sh - Banner, menus and UI helpers.

. "${DISTROVANTA_ROOT}/lib/common.sh"

# ---- Banner -----------------------------------------------------------------
dv_banner() {
    local w cw margin
    w="$(dv_term_width)"
    cw=60
    [ "$w" -lt "$cw" ] && cw="$w"
    [ "$cw" -lt 20 ] && cw=20
    margin=$(( (w - cw) / 2 ))
    [ "$margin" -lt 0 ] && margin=0

    local border=""
    local i
    for ((i=0;i<cw;i++)); do border="${border}─"; done

    # helper to center text within cw with left margin
    _dv_banner_line() {
        local text="$1" color="$2" bold="${3:-0}"
        local len=${#text}
        local left=$(( (cw - len) / 2 ))
        [ "$left" -lt 0 ] && left=0
        local b=""
        [ "$bold" = "1" ] && b="\033[1m"
        printf "%*s\033[%sm%b%s\033[0m\n" "$margin" "" "$color" "$b" "$text"
    }

    printf "%*s\033[34m\033[1m%s\033[0m\n" "$margin" "" "$border"
    _dv_banner_line "D I S T R O V A N T A" "94" 1
    _dv_banner_line "UNIVERSAL LINUX TERMINAL CUSTOMIZER" "97" 1
    printf "%*s\n" "$margin" ""
    _dv_banner_line "Created by Brian Lewis" "97" 0
    _dv_banner_line "Full Stack Developer • AI Engineer" "90" 0
    printf "%*s\n" "$margin" ""
    _dv_banner_line "BRJ Dev Partnership" "90" 0
    printf "%*s\033[34m\033[1m%s\033[0m\n" "$margin" "" "$border"
    printf '\n'
}

# ---- Menu helpers -----------------------------------------------------------
dv_menu_header() {
    dv_banner
    printf '  \033[1mMAIN MENU\033[0m\n'
    printf '  %s\n\n' "Select an option by number."
}

dv_menu_item() {
    local num="$1" title="$2" desc="$3"
    printf '  \033[34m[%s]\033[0m \033[1m%s\033[0m\n' "$num" "$title"
    printf '       \033[90m%s\033[0m\n' "$desc"
}

dv_pause() {
    printf '\n\033[90mPress Enter to continue...\033[0m'
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