#!/usr/bin/env bash
# modules/banner.sh - Custom banner creation.

. "${DISTROVANTA_ROOT}/lib/common.sh"
. "${DISTROVANTA_ROOT}/core/backup.sh"
. "${DISTROVANTA_ROOT}/core/restore.sh"

dv_banner_menu() {
    while true; do
        dv_clear
        dv_banner
        printf '%s\n\n' "CUSTOM BANNER"
        printf 'Banner text : %s\n' "$(dv_setting_get CUSTOM_BANNER_TEXT)"
        printf 'Banner color: %s\n' "$(dv_setting_get CUSTOM_BANNER_COLOR)"
        printf '\n'
        printf '[1] Set banner text (single line)\n'
        printf '[2] Set banner color\n'
        printf '[3] Preview banner\n'
        printf '[4] Apply banner to startup\n'
        printf '[5] Remove banner\n'
        printf '[0] Back\n\n'
        local c
        dv_read c "Choice: "
        case "$c" in
            1)
                local t; dv_read t "Banner text: "
                t="${t//\"/}"; t="${t//\'/}"; t="${t//\`/}"; t="${t//\$/}"; t="${t//\\/}"
                dv_setting_set "CUSTOM_BANNER_TEXT" "$t"; dv_ok "Set."; dv_pause ;;
            2)
                printf 'Colors: blue lightblue gray white green\n'
                local col; dv_read col "Color: "
                case "$col" in
                    blue|lightblue|gray|white|green) dv_setting_set "CUSTOM_BANNER_COLOR" "$col"; dv_ok "Set." ;;
                    *) dv_err "Unknown color." ;;
                esac
                dv_pause ;;
            3)
                dv_clear
                local txt col ccode
                txt="$(dv_setting_get CUSTOM_BANNER_TEXT)"
                col="$(dv_setting_get CUSTOM_BANNER_COLOR)"
                case "$col" in
                    blue) ccode='\033[34m' ;; lightblue) ccode='\033[94m' ;; gray) ccode='\033[90m' ;;
                    white) ccode='\033[97m' ;; green) ccode='\033[32m' ;; *) ccode='\033[94m' ;;
                esac
                printf '%b%s%b\n' "$ccode" "$txt" '\033[0m'
                dv_pause ;;
            4)
                if ! dv_shell_supported_full; then dv_err "Bash only."; dv_pause; continue; fi
                local rc="${HOME}/.bashrc"
                [ -f "$rc" ] && dv_backup_file "$rc" "banner_apply" >/dev/null 2>&1 || true
                dv_restore_strip_block "$rc" >/dev/null 2>&1 || true
                local txt col ccode
                txt="$(dv_setting_get CUSTOM_BANNER_TEXT)"
                col="$(dv_setting_get CUSTOM_BANNER_COLOR)"
                case "$col" in
                    blue) ccode='\e[34m' ;; lightblue) ccode='\e[94m' ;; gray) ccode='\e[90m' ;;
                    white) ccode='\e[97m' ;; green) ccode='\e[32m' ;; *) ccode='\e[94m' ;;
                esac
                {
                    printf '\n%s\n' "$DV_MARKER_BEGIN"
                    line="printf '%b%s%b\\n' '$ccode' '$txt' '\\e[0m'"
                    printf '%s\n' "$line"
                    printf '%s\n' "$DV_MARKER_END"
                } >>"$rc"
                dv_ensure_bashrc_sourced
                dv_ok "Banner applied."
                dv_info "Open a new terminal or run: source $rc"
                dv_pause ;;
            5)
                [ -f "${HOME}/.bashrc" ] && dv_restore_strip_block "${HOME}/.bashrc" && dv_ok "Removed."
                dv_pause ;;
            0) return 0 ;;
            *) dv_err "Invalid option."; dv_pause ;;
        esac
    done
}