#!/usr/bin/env bash
# core/restore.sh - Restore previous configurations safely.

. "${DISTROVANTA_ROOT}/lib/common.sh"
# shellcheck source=backup.sh
. "${DISTROVANTA_ROOT}/core/backup.sh"

DV_MARKER_BEGIN="# >>> DISTROVANTA BEGIN >>>"
DV_MARKER_END="# <<< DISTROVANTA END <<<"

# Remove a managed block (between markers) from a file, preserving rest.
dv_restore_strip_block() {
    local file="$1"
    [ -f "$file" ] || return 1
    dv_backup_file "$file" "restore_strip" >/dev/null 2>&1 || true
    local tmp
    tmp="$(mktemp 2>/dev/null || echo "${file}.tmp")"
    awk -v b="$DV_MARKER_BEGIN" -v e="$DV_MARKER_END" '
        $0==b {inb=1; next}
        $0==e {inb=0; next}
        inb==0 {print}
    ' "$file" >"$tmp"
    if [ -s "$tmp" ] || [ ! -s "$file" ]; then
        mv -f "$tmp" "$file"
        dv_log "stripped distrovanta block from $file"
        return 0
    fi
    rm -f "$tmp"
    return 1
}

# Restore a file from its latest backup (full restore).
dv_restore_from_backup() {
    local file="$1"
    local src
    src="$(dv_backup_latest_for "$file")" || true
    if [ -z "$src" ]; then
        dv_err "No backup found for: $file"
        return 1
    fi
    if dv_confirm "Restore $file from $src ? [y/N]: "; then
        cp -p "$src" "$file" && dv_ok "Restored: $file" && dv_log "restored $file from $src"
    else
        dv_info "Cancelled."
    fi
}

# Restore all rc files touched (strip blocks) - safer than full overwrite.
dv_restore_all() {
    dv_info "Restoring distrovanta-managed blocks..."
    local rc
    for rc in "${HOME}/.bashrc" "${HOME}/.zshrc"; do
        if [ -f "$rc" ]; then
            dv_restore_strip_block "$rc" && dv_ok "Cleaned: $rc"
        fi
    done
    dv_setting_set "DISTROVANTA_ENABLED" "0"
    dv_setting_set "PANEL_ENABLED" "0"
    dv_ok "Restore complete."
}