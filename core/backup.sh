#!/usr/bin/env bash
# core/backup.sh - Safe backup system.

. "${DISTROVANTA_ROOT}/lib/common.sh"

DV_BACKUP_MANIFEST="${DISTROVANTA_BACKUP_DIR}/manifest.log"

dv_backup_init() {
    dv_state_init
    mkdir -p "${DISTROVANTA_BACKUP_DIR}"
    touch "${DV_BACKUP_MANIFEST}"
}

# Create a timestamped backup of a file. Records in manifest.
# Usage: dv_backup_file <file> [label]
dv_backup_file() {
    local file="$1" label="${2:-generic}"
    [ -f "$file" ] || { dv_warn "File not found, skip backup: $file"; return 1; }
    dv_backup_init
    local ts
    ts="$(date '+%Y%m%d_%H%M%S')"
    local base
    base="$(basename "$file")"
    local dest="${DISTROVANTA_BACKUP_DIR}/${ts}_${base}"
    # avoid collisions
    local n=0
    while [ -e "$dest" ]; do
        n=$((n+1))
        dest="${DISTROVANTA_BACKUP_DIR}/${ts}_${n}_${base}"
    done
    if cp -p "$file" "$dest" 2>/dev/null; then
        printf '%s|%s|%s|%s\n' "$ts" "$label" "$file" "$dest" >>"${DV_BACKUP_MANIFEST}"
        dv_log "backup created: $file -> $dest"
        printf '%s' "$dest"
        return 0
    fi
    dv_err "Failed to back up: $file"
    return 1
}

# List backups
dv_backup_list() {
    dv_backup_init
    if [ ! -s "${DV_BACKUP_MANIFEST}" ]; then
        dv_info "No backups recorded."
        return 0
    fi
    printf '%-20s %-24s %s\n' "TIMESTAMP" "LABEL" "ORIGINAL"
    printf '%s\n' "------------------------------------------------------------------------"
    while IFS='|' read -r ts label file dest; do
        [ -z "$ts" ] && continue
        printf '%-20s %-24s %s\n' "$ts" "$label" "$file"
    done <"${DV_BACKUP_MANIFEST}"
}

# Find latest backup for a given original file path.
dv_backup_latest_for() {
    local target="$1"
    [ -f "${DV_BACKUP_MANIFEST}" ] || return 1
    local best=""
    while IFS='|' read -r ts label file dest; do
        [ -z "$ts" ] && continue
        if [ "$file" = "$target" ]; then
            best="$dest"
        fi
    done <"${DV_BACKUP_MANIFEST}"
    [ -n "$best" ] && [ -f "$best" ] && { printf '%s' "$best"; return 0; }
    return 1
}

# Remove a backup entry (file + manifest line) by destination path.
dv_backup_remove() {
    local dest="$1"
    [ -f "$dest" ] && rm -f "$dest"
    if [ -f "${DV_BACKUP_MANIFEST}" ]; then
        local tmp
        tmp="$(mktemp 2>/dev/null || echo "${DV_BACKUP_MANIFEST}.tmp")"
        grep -vF "|$dest" "${DV_BACKUP_MANIFEST}" >"$tmp" 2>/dev/null || true
        mv -f "$tmp" "${DV_BACKUP_MANIFEST}"
    fi
}