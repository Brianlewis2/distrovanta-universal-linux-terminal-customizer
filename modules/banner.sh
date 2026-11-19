#!/usr/bin/env bash
# modules/banner.sh - Custom banner creation with preview.

. "${DISTROVANTA_ROOT}/lib/common.sh"
. "${DISTROVANTA_ROOT}/core/backup.sh"
. "${DISTROVANTA_ROOT}/core/restore.sh"

dv_banner_preview() {
    # $1 text, $2 color
    local text="$1" col="$2" ccode
    case "$col" in
        blue) ccode=$'\033[34m' ;; lightblue) ccode=$'\033[94m' ;; gray) ccode=$'\033[90m' ;;
        white) ccode=$'\033[97m' ;; green) ccode=$'\033[32m' ;; *) ccode=$'\033[94m' ;;
    esac
    local rcode=$'\033[0m'
    local w; w="$(dv_term_width)"
    local line=""
    local i
    for ((i=0;i<w && i<60;i++)); do line="${line}="; done
    printf '\n%b%s%b\n' "$ccode" "$line" "$rcode"
    printf '%b%s%b\n' "$ccode" "$text" "$rcode"
    printf '%b%s%b\n\n' "$ccode" "$line" "$rcode"
}

dv_banner_menu() {
    while true; do
        dv_clear
        dv_banner
        printf '%s\n\n' "CUSTOM BANNER"
        printf 'Current text : %s\n' "$(dv_setting_get CUSTOM_BANNER_TEXT)"
        printf 'Current color: %s\n\n' "$(dv_setting_get CUSTOM_BANNER_COLOR)"
        printf '[1] Create/Update banner\n'
        printf '[2] Remove banner\n'
        printf '[0] Back\n\n'
        local c
        dv_read c "Choice: "
        case "$c" in
            1)
                local text color
                dv_read text "Enter your banner text: "
                text="${text//\"/}"; text="${text//\'/}"; text="${text//\`/}"; text="${text//\$/}"; text="${text//\\/}"
                printf 'Colors: blue lightblue gray white green\n'
                dv_read color "Color: "
                case "$color" in
                    blue|lightblue|gray|white|green) ;;
                    *) color="$(dv_setting_get CUSTOM_BANNER_COLOR)"; [ -z "$color" ] && color=blue ;;
                esac
                # Preview
                dv_banner_preview "$text" "$color"
                printf 'Apply this banner?\n\n'
                printf '[01] CONFIRM\n[02] CANCEL\n\n'
                local ans
                dv_read ans "Choice: "
                case "$ans" in
                    01|1)
                        dv_setting_set "CUSTOM_BANNER_TEXT" "$text"
                        dv_setting_set "CUSTOM_BANNER_COLOR" "$color"
                        # Apply
                        if ! dv_shell_supported_full; then dv_err "Bash only."; dv_pause; continue; fi
                        local rc="${HOME}/.bashrc"
                        [ -f "$rc" ] && dv_backup_file "$rc" "banner_apply" >/dev/null 2>&1 || true
                        dv_restore_strip_block "$rc" >/dev/null 2>&1 || true
                        local ccode
                        case "$color" in
                            blue) ccode='\e[34m' ;; lightblue) ccode='\e[94m' ;; gray) ccode='\e[90m' ;;
                            white) ccode='\e[97m' ;; green) ccode='\e[32m' ;; *) ccode='\e[94m' ;;
                        esac
                        {
                            printf '\n%s\n' "$DV_MARKER_BEGIN"
                            line="printf '%b%s%b\\n' '$ccode' '$text' '\\e[0m'"
                            printf '%s\n' "$line"
                            printf '%s\n' "$DV_MARKER_END"
                        } >>"$rc"
                        dv_ensure_bashrc_sourced
                        dv_ok "Banner applied."
                        dv_info "Open a new terminal or run: source $rc"
                        ;;
                    *) dv_info "Cancelled. No changes applied." ;;
                esac
                dv_pause ;;
            2)
                if [ -f "${HOME}/.bashrc" ]; then
                    dv_restore_strip_block "${HOME}/.bashrc" && dv_ok "Removed."
                fi
                dv_setting_set "CUSTOM_BANNER_TEXT" ""
                dv_setting_set "CUSTOM_BANNER_COLOR" ""
                dv_pause ;;
            0) return 0 ;;
            *) dv_err "Invalid option."; dv_pause ;;
        esac
    done
}