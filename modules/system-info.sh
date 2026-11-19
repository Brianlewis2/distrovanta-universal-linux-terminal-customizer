#!/usr/bin/env bash
# modules/system-info.sh - Configure system info displayed on startup.

. "${DISTROVANTA_ROOT}/lib/common.sh"
. "${DISTROVANTA_ROOT}/core/detection.sh"
. "${DISTROVANTA_ROOT}/core/backup.sh"
. "${DISTROVANTA_ROOT}/core/restore.sh"

dv_sysinfo_snippet() {
    cat <<'EOF'
# DISTROVANTA system info
if command -v uname >/dev/null 2>&1; then
    printf 'System: %s %s\n' "$(uname -s)" "$(uname -r)"
fi
EOF
}

dv_system_info_menu() {
    while true; do
        dv_clear
        dv_banner
        printf '%s\n\n' "SYSTEM INFORMATION"
        printf 'Enabled: %s\n\n' "$(dv_setting_get SYSTEM_INFO_ENABLED)"
        printf '[1] Show environment summary\n'
        printf '[2] Toggle system info on startup\n'
        printf '[3] Apply system info to startup\n'
        printf '[4] Remove system info from startup\n'
        printf '[0] Back\n\n'
        local c
        dv_read c "Choice: "
        case "$c" in
            1) dv_env_summary; dv_pause ;;
            2)
                local cur; cur="$(dv_setting_get SYSTEM_INFO_ENABLED)"
                if [ "$cur" = "1" ]; then dv_setting_set "SYSTEM_INFO_ENABLED" "0"; else dv_setting_set "SYSTEM_INFO_ENABLED" "1"; fi
                dv_ok "Toggled."; dv_pause ;;
            3)
                if ! dv_shell_supported_full; then dv_err "Bash only."; dv_pause; continue; fi
                local rc="${HOME}/.bashrc"
                [ -f "$rc" ] && dv_backup_file "$rc" "sysinfo_apply" >/dev/null 2>&1 || true
                dv_restore_strip_block "$rc" >/dev/null 2>&1 || true
                {
                    printf '\n%s\n' "$DV_MARKER_BEGIN"
                    dv_sysinfo_snippet
                    printf '%s\n' "$DV_MARKER_END"
                } >>"$rc"
                dv_setting_set "SYSTEM_INFO_ENABLED" "1"
                dv_ensure_bashrc_sourced
                dv_ok "Applied."
                dv_info "Open a new terminal or run: source $rc"
                dv_pause ;;
            4)
                [ -f "${HOME}/.bashrc" ] && dv_restore_strip_block "${HOME}/.bashrc" && dv_ok "Removed."
                dv_pause ;;
            0) return 0 ;;
            *) dv_err "Invalid option."; dv_pause ;;
        esac
    done
}