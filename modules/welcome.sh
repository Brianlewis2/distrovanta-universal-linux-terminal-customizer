#!/usr/bin/env bash
# modules/welcome.sh - Welcome message configuration.

. "${DISTROVANTA_ROOT}/lib/common.sh"

dv_welcome_menu() {
    while true; do
        dv_clear
        dv_banner
        printf '%s\n\n' "WELCOME MESSAGE"
        printf 'Current: %s\n\n' "$(dv_setting_get WELCOME_MESSAGE)"
        printf '[1] Set welcome message\n'
        printf '[2] Clear welcome message\n'
        printf '[0] Back\n\n'
        local c
        dv_read c "Choice: "
        case "$c" in
            1)
                local w; dv_read w "Message: "
                w="${w//\"/}"; w="${w//\'/}"; w="${w//\`/}"; w="${w//\$/}"; w="${w//\\/}"
                dv_setting_set "WELCOME_MESSAGE" "$w"; dv_ok "Set."; dv_pause ;;
            2)
                dv_setting_set "WELCOME_MESSAGE" ""; dv_ok "Cleared."; dv_pause ;;
            0) return 0 ;;
            *) dv_err "Invalid option."; dv_pause ;;
        esac
    done
}