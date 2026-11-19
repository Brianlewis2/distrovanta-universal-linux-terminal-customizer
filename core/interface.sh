#!/usr/bin/env bash
# core/interface.sh - Banner, menus and UI helpers.

. "${DISTROVANTA_ROOT}/lib/common.sh"

# ---- Banner -----------------------------------------------------------------
dv_banner() {
    # Build lines, then center each dynamically.
    local lines=()
    lines+=("DISTROVANTA")
    lines+=("UNIVERSAL LINUX TERMINAL CUSTOMIZER")
    lines+=("")
    lines+=("Created by Brian Lewis")
    lines+=("Full Stack Developer • AI Engineer")
    lines+=("")
    lines+=("BRJ Dev Partnership")

    # Top/bottom border width based on terminal
    local width
    width="$(dv_term_width)"
    local border=""
    local i
    for ((i=0;i<width && i<60;i++)); do border="${border}─"; done
    [ "$width" -gt 60 ] && border="${border:0:60}"

    printf '\n'
    dv_center "${DV_COLOR_BLUE}${DV_COLOR_BOLD}${border}${DV_COLOR_RESET}"
    for l in "${lines[@]}"; do
        case "$l" in
            "DISTROVANTA")
                dv_center "${DV_COLOR_LIGHTBLUE}${DV_COLOR_BOLD}${l}${DV_COLOR_RESET}" ;;
            "UNIVERSAL LINUX TERMINAL CUSTOMIZER")
                dv_center "${DV_COLOR_WHITE}${DV_COLOR_BOLD}${l}${DV_COLOR_RESET}" ;;
            "Created by Brian Lewis")
                dv_center "${DV_COLOR_WHITE}${l}${DV_COLOR_RESET}" ;;
            "Full Stack Developer • AI Engineer")
                dv_center "${DV_COLOR_GRAY}${l}${DV_COLOR_RESET}" ;;
            "BRJ Dev Partnership")
                dv_center "${DV_COLOR_DIM}${DV_COLOR_GRAY}${l}${DV_COLOR_RESET}" ;;
            "")
                printf '\n' ;;
            *)
                dv_center "${DV_COLOR_WHITE}${l}${DV_COLOR_RESET}" ;;
        esac
    done
    dv_center "${DV_COLOR_BLUE}${DV_COLOR_BOLD}${border}${DV_COLOR_RESET}"
    printf '\n'
}

# ---- Menu helpers -----------------------------------------------------------
dv_menu_header() {
    dv_banner
    printf '%s\n' "MAIN MENU"
    printf '%s\n' "Select an option by number."
    printf '\n'
}

dv_menu_item() {
    # $1 number, $2 title, $3 description
    local num="$1" title="$2" desc="$3"
    printf '  %b[%s]%b %b%s%b\n' "${DV_COLOR_BLUE}" "$num" "${DV_COLOR_RESET}" "${DV_COLOR_BOLD}" "$title" "${DV_COLOR_RESET}"
    printf '      %s\n' "$desc"
}

dv_pause() {
    printf '\nPress Enter to continue...'
    # shellcheck disable=SC2034
    IFS= read -r _ || true
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
    # $1 prompt. Returns 0 for yes.
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
    # $1 varname, $2 prompt, $3 validator function name (optional)
    local varname="$1"; shift
    local prompt="$1"; shift
    local validator="${1:-}"
    local val
    while true; do
        dv_read val "$prompt"
        if [ -z "$validator" ]; then
            # shellcheck disable=SC2034
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