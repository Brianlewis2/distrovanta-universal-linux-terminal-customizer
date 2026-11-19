#!/usr/bin/env bash
# modules/panel.sh - Custom startup panel with preview.

. "${DISTROVANTA_ROOT}/lib/common.sh"
. "${DISTROVANTA_ROOT}/core/backup.sh"
. "${DISTROVANTA_ROOT}/core/restore.sh"

dv_panel_preview() {
    # $1 title $2 subtitle $3 welcome $4 color
    local title="${1:-DISTROVANTA}" subtitle="$2" welcome="$3" color="${4:-lightblue}" ccode
    case "$color" in
        blue) ccode=$'\033[34m' ;; lightblue) ccode=$'\033[94m' ;; gray) ccode=$'\033[90m' ;;
        white) ccode=$'\033[97m' ;; green) ccode=$'\033[32m' ;; *) ccode=$'\033[94m' ;;
    esac
    local rcode=$'\033[0m'
    printf '\n%b%s%b\n' "$ccode" "$title" "$rcode"
    [ -n "$subtitle" ] && printf '%b%s%b\n' "$ccode" "$subtitle" "$rcode"
    [ -n "$welcome" ] && printf '%s\n' "$welcome"
    printf '\n'
}

dv_panel_build() {
    local title subtitle welcome color
    title="$(dv_setting_get PANEL_TITLE)"
    subtitle="$(dv_setting_get PANEL_SUBTITLE)"
    welcome="$(dv_setting_get WELCOME_MESSAGE)"
    color="$(dv_setting_get PANEL_COLOR)"
    [ -z "$title" ] && title="DISTROVANTA"
    [ -z "$color" ] && color="lightblue"
    local ccode rcode='\e[0m'
    case "$color" in
        blue) ccode='\e[34m' ;; lightblue) ccode='\e[94m' ;; gray) ccode='\e[90m' ;;
        white) ccode='\e[97m' ;; green) ccode='\e[32m' ;; *) ccode='\e[94m' ;;
    esac
    cat <<EOF
${DV_MARKER_BEGIN}
# DISTROVANTA panel
distrovanta_panel() {
    printf '${ccode}%s${rcode}\\n' "$title"
    [ -n "$subtitle" ] && printf '${ccode}%s${rcode}\\n' "$subtitle"
    [ -n "$welcome" ] && printf '%s\\n' "$welcome"
}
distrovanta_panel
${DV_MARKER_END}
EOF
}

dv_panel_menu() {
    while true; do
        dv_clear
        dv_banner
        printf '%s\n\n' "CREATE TERMINAL PANEL"
        printf 'Title     : %s\n' "$(dv_setting_get PANEL_TITLE)"
        printf 'Subtitle  : %s\n' "$(dv_setting_get PANEL_SUBTITLE)"
        printf 'Welcome   : %s\n' "$(dv_setting_get WELCOME_MESSAGE)"
        printf 'Color     : %s\n\n' "$(dv_setting_get PANEL_COLOR)"
        printf '[1] Create/Update panel\n'
        printf '[2] Remove panel\n'
        printf '[0] Back\n\n'
        local c
        dv_read c "Choice: "
        case "$c" in
            1)
                local title subtitle welcome color
                dv_read title "Title: "
                title="${title//\"/}"; title="${title//\'/}"; title="${title//\`/}"; title="${title//\$/}"; title="${title//\\/}"
                [ -z "$title" ] && title="$(dv_setting_get PANEL_TITLE)"; [ -z "$title" ] && title="DISTROVANTA"
                dv_read subtitle "Subtitle (optional): "
                subtitle="${subtitle//\"/}"; subtitle="${subtitle//\'/}"; subtitle="${subtitle//\`/}"; subtitle="${subtitle//\$/}"; subtitle="${subtitle//\\/}"
                dv_read welcome "Welcome message (optional): "
                welcome="${welcome//\"/}"; welcome="${welcome//\'/}"; welcome="${welcome//\`/}"; welcome="${welcome//\$/}"; welcome="${welcome//\\/}"
                printf 'Colors: blue lightblue gray white green\n'
                dv_read color "Color: "
                case "$color" in
                    blue|lightblue|gray|white|green) ;;
                    *) color="$(dv_setting_get PANEL_COLOR)"; [ -z "$color" ] && color=blue ;;
                esac
                dv_panel_preview "$title" "$subtitle" "$welcome" "$color"
                printf 'Apply this panel?\n\n'
                printf '[01] CONFIRM\n[02] CANCEL\n\n'
                local ans
                dv_read ans "Choice: "
                case "$ans" in
                    01|1)
                        dv_setting_set "PANEL_TITLE" "$title"
                        dv_setting_set "PANEL_SUBTITLE" "$subtitle"
                        dv_setting_set "WELCOME_MESSAGE" "$welcome"
                        dv_setting_set "PANEL_COLOR" "$color"
                        if ! dv_shell_supported_full; then dv_err "Bash only."; dv_pause; continue; fi
                        local rc="${HOME}/.bashrc"
                        [ -f "$rc" ] && dv_backup_file "$rc" "panel_apply" >/dev/null 2>&1 || true
                        dv_restore_strip_block "$rc" >/dev/null 2>&1 || true
                        dv_panel_build >>"$rc"
                        dv_setting_set "PANEL_ENABLED" "1"
                        dv_ensure_bashrc_sourced
                        dv_ok "Panel applied to $rc"
                        dv_info "Open a new terminal or run: source $rc"
                        ;;
                    *) dv_info "Cancelled. No changes applied." ;;
                esac
                dv_pause ;;
            2)
                if [ -f "${HOME}/.bashrc" ]; then
                    dv_restore_strip_block "${HOME}/.bashrc" && dv_ok "Removed."
                fi
                dv_setting_set "PANEL_ENABLED" "0"
                dv_pause ;;
            0) return 0 ;;
            *) dv_err "Invalid option."; dv_pause ;;
        esac
    done
}