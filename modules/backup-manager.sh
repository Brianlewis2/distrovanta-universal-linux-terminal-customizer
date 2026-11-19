#!/usr/bin/env bash
# modules/backup-manager.sh - Backup management.

. "${DISTROVANTA_ROOT}/lib/common.sh"
. "${DISTROVANTA_ROOT}/core/backup.sh"

dv_backup_manager_menu() {
    while true; do
        dv_clear
        dv_banner
        printf '%s\n\n' "BACKUP MANAGER"
        printf '[1] List backups\n'
        printf '[2] Create manual backup of ~/.bashrc\n'
        printf '[3] Create manual backup of a file\n'
        printf '[4] Remove a backup by destination path\n'
        printf '[0] Back\n\n'
        local c
        dv_read c "Choice: "
        case "$c" in
            1) dv_backup_list; dv_pause ;;
            2)
                if [ -f "${HOME}/.bashrc" ]; then
                    local d; d="$(dv_backup_file "${HOME}/.bashrc" "manual")"
                    dv_ok "Backup: $d"
                else
                    dv_warn "No .bashrc found."
                fi
                dv_pause ;;
            3)
                local f; dv_read f "File path: "
                if [ -f "$f" ]; then
                    local d; d="$(dv_backup_file "$f" "manual")"
                    dv_ok "Backup: $d"
                else
                    dv_err "File not found."
                fi
                dv_pause ;;
            4)
                local d; dv_read d "Destination path: "
                dv_backup_remove "$d"; dv_ok "Removed (if existed)."; dv_pause ;;
            0) return 0 ;;
            *) dv_err "Invalid option."; dv_pause ;;
        esac
    done
}