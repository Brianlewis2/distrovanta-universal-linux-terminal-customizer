#!/usr/bin/env bash
# distrovanta.sh - DISTROVANTA entry point.
# Universal Linux Terminal Customizer
# Copyright (C) 2026 Brian Lewis (BRJ Dev)
# Licensed under the GNU General Public License v3.0 (GPL-3.0).
# Created by Brian Lewis • BRJ Dev (discrete partner)

set -u

# Resolve root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DISTROVANTA_ROOT="$SCRIPT_DIR"

# Source common + core
. "${DISTROVANTA_ROOT}/lib/common.sh"
. "${DISTROVANTA_ROOT}/core/detection.sh"
. "${DISTROVANTA_ROOT}/core/interface.sh"
. "${DISTROVANTA_ROOT}/core/backup.sh"
. "${DISTROVANTA_ROOT}/core/restore.sh"

# Source modules
for m in "${DISTROVANTA_ROOT}"/modules/*.sh; do
    [ -f "$m" ] && . "$m"
done

dv_state_init
dv_detect_distro
dv_detect_termux
dv_detect_shell

# Help
if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    cat <<EOF
DISTROVANTA v${DISTROVANTA_VERSION} - Universal Linux Terminal Customizer
Usage: ./distrovanta.sh [--no-color] [--version]
EOF
    exit 0
fi
if [ "${1:-}" = "--version" ]; then
    printf 'DISTROVANTA %s\n' "$DISTROVANTA_VERSION"
    exit 0
fi
if [ "${1:-}" = "--no-color" ]; then
    NO_COLOR=1
    # reload color vars by re-sourcing common with NO_COLOR set
    unset _DISTROVANTA_COMMON_LOADED
    . "${DISTROVANTA_ROOT}/lib/common.sh"
fi

# Warn unsupported shell
if ! dv_shell_supported_full; then
    dv_warn "Full features require Bash. Detected: ${DV_SHELL_NAME}"
    dv_info "Detection and menus will still run; modifications limited."
fi

dv_check_deps

main_loop() {
    while true; do
        dv_clear
        dv_menu_header
        dv_menu_item "01" "CREATE TERMINAL PANEL" "Create a custom startup panel."
        dv_menu_item "02" "CUSTOMIZE TERMINAL PROMPT" "Customize visual user/environment identification."
        dv_menu_item "03" "THEMES & COLORS" "Configure colors and themes."
        dv_menu_item "04" "CUSTOM BANNER" "Create and configure banners."
        dv_menu_item "05" "WELCOME MESSAGE" "Configure welcome messages."
        dv_menu_item "06" "SYSTEM INFORMATION" "Configure info shown in terminal."
        dv_menu_item "07" "CONFIGURATION MANAGER" "Manage saved configurations."
        dv_menu_item "08" "BACKUP MANAGER" "Create and manage backups."
        dv_menu_item "09" "RESTORE DEFAULT SETTINGS" "Restore previous configurations."
        dv_menu_item "10" "ABOUT THE DEVELOPER" "Information about the creator."
        dv_menu_item "11" "SOCIAL MEDIA" "Social networks and projects."
        dv_menu_item "12" "ABOUT DISTROVANTA" "Information about the tool."
        dv_menu_item "00" "EXIT" "Exit the tool."
        printf '\n'
        local choice
        dv_read choice "Select option: "
        case "$choice" in
            01|1) dv_panel_menu ;;
            02|2) dv_prompt_menu ;;
            03|3) dv_themes_menu ;;
            04|4) dv_banner_menu ;;
            05|5) dv_welcome_menu ;;
            06|6) dv_system_info_menu ;;
            07|7) dv_config_manager_menu ;;
            08|8) dv_backup_manager_menu ;;
            09|9) dv_restore_menu ;;
            10) dv_about_developer ;;
            11) dv_social_menu ;;
            12) dv_about_distrovanta ;;
            00|0) dv_info "Goodbye."; exit 0 ;;
            *) dv_err "Invalid option."; dv_pause ;;
        esac
    done
}

main_loop