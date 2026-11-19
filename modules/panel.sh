#!/usr/bin/env bash
# modules/panel.sh - Custom startup panel.

. "${DISTROVANTA_ROOT}/lib/common.sh"
. "${DISTROVANTA_ROOT}/core/backup.sh"
. "${DISTROVANTA_ROOT}/core/restore.sh"

dv_panel_build() {
    local title subtitle welcome color
    title="$(dv_setting_get PANEL_TITLE)"
    subtitle="$(dv_setting_get PANEL_SUBTITLE)"
    welcome="$(dv_setting_get WELCOME_MESSAGE)"
    color="$(dv_setting_get PANEL_COLOR)"
    [ -z "$title" ] && title="DISTROVANTA"
    [ -z "$color" ] && color="lightblue"

    local ccode rcode
    case "$color" in
        blue) ccode='\e[34m' ;; lightblue) ccode='\e[94m' ;; gray) ccode='\e[90m' ;;
        white) ccode='\e[97m' ;; green) ccode='\e[32m' ;; *) ccode='\e[94m' ;;
    esac
    rcode='\e[0m'

    # Generate a bash snippet that prints the panel on startup.
    cat <<EOF
${DV_MARKER_BEGIN}
# DISTROVANTA panel
distrovanta_panel() {
    local w
    w="\$(tput cols 2>/dev/null || echo 80)"
    case "\$w" in ''|*[!0-9]*) w=80 ;; esac
    [ "\$w" -lt 20 ] && w=20
    printf '${ccode}%s${rcode}\n' "$title"
    [ -n "$subtitle" ] && printf '${ccode}%s${rcode}\n' "$subtitle"
    [ -n "$welcome" ] && printf '%s\n' "$welcome"
}
distrovanta_panel
${DV_MARKER_END}
EOF
}

dv_panel_apply() {
    if ! dv_shell_supported_full; then
        dv_err "Panel customization is fully supported only on Bash."
        return 1
    fi
    local rc="${HOME}/.bashrc"
    [ -f "$rc" ] && dv_backup_file "$rc" "panel_apply" >/dev/null 2>&1 || true
    if [ -f "$rc" ]; then
        dv_restore_strip_block "$rc" >/dev/null 2>&1 || true
    fi
    dv_panel_build >>"$rc"
    dv_setting_set "PANEL_ENABLED" "1"
    dv_ok "Panel applied to $rc"
}

dv_panel_menu() {
    while true; do
        dv_clear
        dv_banner
        printf '%s\n\n' "CREATE TERMINAL PANEL"
        printf 'Title     : %s\n' "$(dv_setting_get PANEL_TITLE)"
        printf 'Subtitle  : %s\n' "$(dv_setting_get PANEL_SUBTITLE)"
        printf 'Welcome   : %s\n' "$(dv_setting_get WELCOME_MESSAGE)"
        printf 'Color     : %s\n' "$(dv_setting_get PANEL_COLOR)"
        printf '\n'
        printf '[1] Set title\n'
        printf '[2] Set subtitle\n'
        printf '[3] Set welcome message\n'
        printf '[4] Set color\n'
        printf '[5] Apply panel\n'
        printf '[6] Remove panel\n'
        printf '[0] Back\n\n'
        local c
        dv_read c "Choice: "
        case "$c" in
            1)
                local t; dv_read t "Title: "
                # sanitize: remove shell metacharacters
                t="${t//\"/}"; t="${t//\'/}"; t="${t//\`/}"; t="${t//\$/}"; t="${t//\\/}"
                dv_setting_set "PANEL_TITLE" "$t"; dv_ok "Set."; dv_pause ;;
            2)
                local s; dv_read s "Subtitle: "
                s="${s//\"/}"; s="${s//\'/}"; s="${s//\`/}"; s="${s//\$/}"; s="${s//\\/}"
                dv_setting_set "PANEL_SUBTITLE" "$s"; dv_ok "Set."; dv_pause ;;
            3)
                local w; dv_read w "Welcome message: "
                w="${w//\"/}"; w="${w//\'/}"; w="${w//\`/}"; w="${w//\$/}"; w="${w//\\/}"
                dv_setting_set "WELCOME_MESSAGE" "$w"; dv_ok "Set."; dv_pause ;;
            4)
                printf 'Colors: blue lightblue gray white green\n'
                local col; dv_read col "Color: "
                case "$col" in
                    blue|lightblue|gray|white|green) dv_setting_set "PANEL_COLOR" "$col"; dv_ok "Set." ;;
                    *) dv_err "Unknown color." ;;
                esac
                dv_pause ;;
            5) dv_panel_apply; dv_pause ;;
            6)
                [ -f "${HOME}/.bashrc" ] && dv_restore_strip_block "${HOME}/.bashrc" && dv_ok "Removed."
                dv_setting_set "PANEL_ENABLED" "0"
                dv_pause ;;
            0) return 0 ;;
            *) dv_err "Invalid option."; dv_pause ;;
        esac
    done
}