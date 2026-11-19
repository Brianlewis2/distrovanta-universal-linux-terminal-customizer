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

    local print_line
    print_line() {
        # $1 text, $2 color/style prefix, $3 suffix(reset)
        local text="$1" pre="$2" suf="$3"
        local plain
        plain="$(printf '%s' "$text" | sed 's/\x1b\[[0-9;]*m//g')"
        local len=${#plain}
        local left=$(( (cw - len) / 2 ))
        [ "$left" -lt 0 ] && left=0
        printf '%*s%*s%b%s%b\n' "$margin" '' "$left" '' "$pre" "$text" "$suf"
    }

    printf '%*s%b%s%b\n' "$margin" '' "${DV_COLOR_BLUE}" "${DV_COLOR_BOLD}${border}" "${DV_COLOR_RESET}"
    print_line "DISTROVANTA" "${DV_COLOR_LIGHTBLUE}${DV_COLOR_BOLD}" "${DV_COLOR_RESET}"
    print_line "UNIVERSAL LINUX TERMINAL CUSTOMIZER" "${DV_COLOR_WHITE}${DV_COLOR_BOLD}" "${DV_COLOR_RESET}"
    printf '%*s\n' "$margin" ''
    print_line "Created by Brian Lewis" "${DV_COLOR_WHITE}" "${DV_COLOR_RESET}"
    print_line "Full Stack Developer • AI Engineer" "${DV_COLOR_GRAY}" "${DV_COLOR_RESET}"
    printf '%*s\n' "$margin" ''
    print_line "BRJ Dev Partnership" "${DV_COLOR_DIM}${DV_COLOR_GRAY}" "${DV_COLOR_RESET}"
    printf '%*s%b%s%b\n' "$margin" '' "${DV_COLOR_BLUE}" "${DV_COLOR_BOLD}${border}" "${DV_COLOR_RESET}"
    printf '\n'
}

# ---- Menu helpers -----------------------------------------------------------
dv_menu_header() {
    dv_banner
    printf '  %bMAIN MENU%b\n' "${DV_COLOR_BOLD}" "${DV_COLOR_RESET}"
    printf '  %s\n\n' "Select an option by number."
}

dv_menu_item() {
    # $1 number, $2 title, $3 description
    local num="$1" title="$2" desc="$3"
    printf '  %b[%s]%b %b%s%b\n' "${DV_COLOR_BLUE}" "$num" "${DV_COLOR_RESET}" "${DV_COLOR_BOLD}" "$title" "${DV_COLOR_RESET}"
    printf '       %b%s%b\n' "${DV_COLOR_GRAY}" "$desc" "${DV_COLOR_RESET}"
}

dv_pause() {
    printf '\n%bPress Enter to continue...%b' "${DV_COLOR_GRAY}" "${DV_COLOR_RESET}"
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

# ---- Yes/No confirm ---------------------------------------------------------
dv_confirm() {
    local prompt="${1:-Continue? [y/N]: }"
    local ans
    dv_read ans "$prompt"
    case "$ans" in
        y|Y|yes|YES|Yes) return 0 ;;
        *) return 1 ;;
    esac
}

# ---- Input validation helpers ----------------------------------------------
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