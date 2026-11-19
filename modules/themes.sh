#!/usr/bin/env bash
# modules/themes.sh - Themes & colors.

. "${DISTROVANTA_ROOT}/lib/common.sh"

dv_themes_menu() {
    while true; do
        dv_clear
        dv_banner
        printf '%s\n\n' "THEMES & COLORS"
        printf 'Current prompt color : %s\n' "$(dv_setting_get PROMPT_COLOR)"
        printf 'Current panel color  : %s\n' "$(dv_setting_get PANEL_COLOR)"
        printf '\n'
        printf '[1] Apply theme: Ocean (blue)\n'
        printf '[2] Apply theme: Mono (gray/white)\n'
        printf '[3] Apply theme: Neon (lightblue/green)\n'
        printf '[4] Set prompt color\n'
        printf '[5] Set panel color\n'
        printf '[0] Back\n\n'
        local c
        dv_read c "Choice: "
        case "$c" in
            1)
                dv_setting_set "PROMPT_COLOR" "blue"
                dv_setting_set "PANEL_COLOR" "blue"
                dv_ok "Ocean theme applied (settings)."; dv_pause ;;
            2)
                dv_setting_set "PROMPT_COLOR" "gray"
                dv_setting_set "PANEL_COLOR" "white"
                dv_ok "Mono theme applied."; dv_pause ;;
            3)
                dv_setting_set "PROMPT_COLOR" "lightblue"
                dv_setting_set "PANEL_COLOR" "green"
                dv_ok "Neon theme applied."; dv_pause ;;
            4)
                printf 'Colors: black blue lightblue gray white green red yellow\n'
                local col; dv_read col "Color: "
                case "$col" in
                    black|blue|lightblue|gray|white|green|red|yellow)
                        dv_setting_set "PROMPT_COLOR" "$col"; dv_ok "Set." ;;
                    *) dv_err "Unknown color." ;;
                esac
                dv_pause ;;
            5)
                printf 'Colors: blue lightblue gray white green\n'
                local col; dv_read col "Color: "
                case "$col" in
                    blue|lightblue|gray|white|green) dv_setting_set "PANEL_COLOR" "$col"; dv_ok "Set." ;;
                    *) dv_err "Unknown color." ;;
                esac
                dv_pause ;;
            0) return 0 ;;
            *) dv_err "Invalid option."; dv_pause ;;
        esac
    done
}