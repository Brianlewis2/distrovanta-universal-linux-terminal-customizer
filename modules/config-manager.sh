#!/usr/bin/env bash
# modules/config-manager.sh - Manage saved settings.

. "${DISTROVANTA_ROOT}/lib/common.sh"

dv_config_manager_menu() {
    while true; do
        dv_clear
        dv_banner
        printf '%s\n\n' "CONFIGURATION MANAGER"
        printf '[1] Show current settings\n'
        printf '[2] Reset settings to defaults\n'
        printf '[3] Export settings to file\n'
        printf '[4] Import settings from file\n'
        printf '[0] Back\n\n'
        local c
        dv_read c "Choice: "
        case "$c" in
            1)
                if [ -f "${DISTROVANTA_SETTINGS}" ]; then
                    cat "${DISTROVANTA_SETTINGS}"
                else
                    dv_info "No settings file."
                fi
                dv_pause ;;
            2)
                if dv_confirm "Reset all settings to defaults? [y/N]: "; then
                    rm -f "${DISTROVANTA_SETTINGS}"
                    dv_state_init
                    dv_ok "Reset."
                fi
                dv_pause ;;
            3)
                local out; dv_read out "Output path: "
                if dv_path_safe "$out"; then
                    cp -f "${DISTROVANTA_SETTINGS}" "$out" && dv_ok "Exported to $out"
                else
                    dv_err "Unsafe path."
                fi
                dv_pause ;;
            4)
                local inp; dv_read inp "Input path: "
                if [ -f "$inp" ] && dv_path_safe "$inp"; then
                    cp -f "$inp" "${DISTROVANTA_SETTINGS}" && dv_ok "Imported."
                else
                    dv_err "File not found or unsafe path."
                fi
                dv_pause ;;
            0) return 0 ;;
            *) dv_err "Invalid option."; dv_pause ;;
        esac
    done
}