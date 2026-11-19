#!/usr/bin/env bash
# modules/restore-menu.sh - Restore options.

. "${DISTROVANTA_ROOT}/lib/common.sh"
. "${DISTROVANTA_ROOT}/core/restore.sh"
. "${DISTROVANTA_ROOT}/core/backup.sh"

dv_restore_menu() {
    while true; do
        dv_clear
        dv_banner
        printf '%s\n\n' "RESTORE DEFAULT SETTINGS"
        printf '[1] Remove DISTROVANTA blocks from .bashrc (safe)\n'
        printf '[2] Restore .bashrc from latest backup (full)\n'
        printf '[3] Restore a specific file from backup\n'
        printf '[4] Restore all managed files\n'
        printf '[0] Back\n\n'
        local c
        dv_read c "Choice: "
        case "$c" in
            1)
                if [ -f "${HOME}/.bashrc" ]; then
                    dv_restore_strip_block "${HOME}/.bashrc" && dv_ok "Cleaned."
                else
                    dv_warn "No .bashrc."
                fi
                dv_pause ;;
            2) dv_restore_from_backup "${HOME}/.bashrc"; dv_pause ;;
            3)
                local f; dv_read f "Original file path: "
                dv_restore_from_backup "$f"; dv_pause ;;
            4) dv_restore_all; dv_pause ;;
            0) return 0 ;;
            *) dv_err "Invalid option."; dv_pause ;;
        esac
    done
}