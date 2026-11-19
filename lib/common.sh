#!/usr/bin/env bash
# lib/common.sh - Common helpers, constants and safe utilities for DISTROVANTA.
# Project: DISTROVANTA - Universal Linux Terminal Customizer
# Creator: Brian Lewis (Full Stack Developer • AI Engineer)
# Partnership: BRJ Dev (discrete)

# Guard against double-sourcing.
if [ -n "${_DISTROVANTA_COMMON_LOADED:-}" ]; then
    return 0 2>/dev/null || exit 0
fi
_DISTROVANTA_COMMON_LOADED=1

# ---- Version / identity -----------------------------------------------------
DISTROVANTA_NAME="DISTROVANTA"
DISTROVANTA_TAGLINE="UNIVERSAL LINUX TERMINAL CUSTOMIZER"
DISTROVANTA_VERSION="0.1.0"
DISTROVANTA_AUTHOR="Brian Lewis"
DISTROVANTA_AUTHOR_TITLE="Full Stack Developer • AI Engineer"
DISTROVANTA_PARTNER="BRJ Dev Partnership"

# ---- Paths ------------------------------------------------------------------
# Resolve project root from this file location.
_DISTROVANTA_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DISTROVANTA_ROOT="$(cd "${_DISTROVANTA_LIB_DIR}/.." && pwd)"
DISTROVANTA_CORE="${DISTROVANTA_ROOT}/core"
DISTROVANTA_MODULES="${DISTROVANTA_ROOT}/modules"
DISTROVANTA_CONFIG_DIR="${DISTROVANTA_ROOT}/config"
DISTROVANTA_SETTINGS="${DISTROVANTA_CONFIG_DIR}/settings.conf"
DISTROVANTA_STATE_DIR="${HOME}/.distrovanta"
DISTROVANTA_BACKUP_DIR="${DISTROVANTA_STATE_DIR}/backups"
DISTROVANTA_LOG="${DISTROVANTA_STATE_DIR}/distrovanta.log"

# ---- Color support -----------------------------------------------------------
# Detect whether the terminal supports colors.
distrovanta_color_support() {
    if [ -n "${NO_COLOR:-}" ]; then
        return 1
    fi
    if [ ! -t 1 ]; then
        return 1
    fi
    case "${TERM:-}" in
        ""|dumb) return 1 ;;
    esac
    if command -v tput >/dev/null 2>&1; then
        local colors
        colors="$(tput colors 2>/dev/null || echo 0)"
        case "$colors" in
            ''|*[!0-9]*) colors=0 ;;
        esac
        [ "$colors" -ge 8 ] 2>/dev/null && return 0
        return 1
    fi
    # Fallback: assume color if TERM mentions color.
    case "${TERM:-}" in
        *color*|*256*|xterm*|screen*|tmux*) return 0 ;;
    esac
    return 1
}

# Color variables (empty when no color support).
if distrovanta_color_support; then
    DV_COLOR_RESET="\033[0m"
    DV_COLOR_BLACK="\033[30m"
    DV_COLOR_BLUE="\033[34m"
    DV_COLOR_LIGHTBLUE="\033[94m"
    DV_COLOR_GRAY="\033[90m"
    DV_COLOR_WHITE="\033[97m"
    DV_COLOR_BOLD="\033[1m"
    DV_COLOR_DIM="\033[2m"
else
    DV_COLOR_RESET=""
    DV_COLOR_BLACK=""
    DV_COLOR_BLUE=""
    DV_COLOR_LIGHTBLUE=""
    DV_COLOR_GRAY=""
    DV_COLOR_WHITE=""
    DV_COLOR_BOLD=""
    DV_COLOR_DIM=""
fi

# ---- Output helpers ---------------------------------------------------------
dv_print() { printf '%s\n' "$*"; }
dv_info()  { printf '%b[INFO]%b %s\n' "${DV_COLOR_LIGHTBLUE}" "${DV_COLOR_RESET}" "$*"; }
dv_ok()    { printf '%b[OK]%b   %s\n' "${DV_COLOR_LIGHTBLUE}" "${DV_COLOR_RESET}" "$*"; }
dv_warn()  { printf '%b[WARN]%b %s\n' "${DV_COLOR_GRAY}" "${DV_COLOR_RESET}" "$*"; }
dv_err()   { printf '%b[ERR]%b  %s\n' "${DV_COLOR_BLUE}" "${DV_COLOR_RESET}" "$*" >&2; }

# ---- Logging ----------------------------------------------------------------
dv_log() {
    mkdir -p "${DISTROVANTA_STATE_DIR}" 2>/dev/null
    printf '%s %s\n' "$(date '+%Y-%m-%dT%H:%M:%S')" "$*" >>"${DISTROVANTA_LOG}" 2>/dev/null
}

# ---- Safe input -------------------------------------------------------------
# Read a line into variable name passed as $1, with optional prompt $2.
dv_read() {
    local varname="$1"; shift
    local prompt="${*:-}"
    if [ -n "$prompt" ]; then
        printf '%s' "$prompt"
    fi
    # shellcheck disable=SC2034
    IFS= read -r "$varname" || true
}

# Validate an integer within [min,max]. Returns 0 if valid.
dv_is_int_range() {
    local val="$1" min="$2" max="$3"
    case "$val" in
        ''|*[!0-9]*) return 1 ;;
    esac
    [ "$val" -ge "$min" ] 2>/dev/null && [ "$val" -le "$max" ] 2>/dev/null
}

# ---- Terminal width ----------------------------------------------------------
dv_term_width() {
    local w=""
    if command -v tput >/dev/null 2>&1; then
        w="$(tput cols 2>/dev/null || true)"
    fi
    case "$w" in
        ''|*[!0-9]*) w="${COLUMNS:-80}" ;;
    esac
    case "$w" in
        ''|*[!0-9]*) w=80 ;;
    esac
    [ "$w" -lt 20 ] && w=20
    printf '%s' "$w"
}

# Center a string within terminal width. Strips ANSI for length calc (basic).
dv_center() {
    local text="$1"
    local width
    width="$(dv_term_width)"
    # strip ANSI escape sequences for length
    local plain
    plain="$(printf '%s' "$text" | sed 's/\x1b\[[0-9;]*m//g')"
    local len=${#plain}
    local pad=$(( (width - len) / 2 ))
    [ "$pad" -lt 0 ] && pad=0
    printf '%*s%s\n' "$pad" '' "$text"
}

# ---- Path safety ------------------------------------------------------------
# Ensure a path is within allowed config areas. Returns 0 if safe.
dv_path_safe() {
    local p="$1"
    case "$p" in
        "") return 1 ;;
        *..*) return 1 ;;
        *";"*) return 1 ;;
        *"|"*) return 1 ;;
        *"\`"*) return 1 ;;
        *'$'*) return 1 ;;
    esac
    return 0
}

# ---- Ensure .bashrc is sourced by login shells ------------------------------
dv_ensure_bashrc_sourced() {
    local f=""
    if [ -f "${HOME}/.bash_profile" ]; then f="${HOME}/.bash_profile"
    elif [ -f "${HOME}/.bash_login" ]; then f="${HOME}/.bash_login"
    elif [ -f "${HOME}/.profile" ]; then f="${HOME}/.profile"
    else f="${HOME}/.bash_profile"
    fi
    if ! grep -qE 'bashrc' "$f" 2>/dev/null; then
        {
            printf '\n# Source .bashrc for DISTROVANTA settings\n'
            printf '[ -f ~/.bashrc ] && . ~/.bashrc\n'
        } >>"$f"
    fi
}

# ---- State init --------------------------------------------------------------
dv_state_init() {
    mkdir -p "${DISTROVANTA_STATE_DIR}" "${DISTROVANTA_BACKUP_DIR}" 2>/dev/null
    [ -f "${DISTROVANTA_SETTINGS}" ] || : # settings lives in project config
    if [ ! -f "${DISTROVANTA_SETTINGS}" ]; then
        mkdir -p "${DISTROVANTA_CONFIG_DIR}" 2>/dev/null
        cat > "${DISTROVANTA_SETTINGS}" <<'EOF'
# DISTROVANTA settings
# Format: key=value
DISTROVANTA_ENABLED=0
PROMPT_VISUAL_NAME=
PROMPT_ENV_NAME=
PROMPT_COLOR=
PROMPT_SEPARATOR=
PROMPT_SHOW_DIR=1
PANEL_ENABLED=0
PANEL_TITLE=
PANEL_SUBTITLE=
WELCOME_MESSAGE=
SYSTEM_INFO_ENABLED=0
EOF
    fi
}

# ---- settings helpers -------------------------------------------------------
dv_setting_get() {
    local key="$1"
    [ -f "${DISTROVANTA_SETTINGS}" ] || { printf ''; return; }
    local line
    line="$(grep -E "^${key}=" "${DISTROVANTA_SETTINGS}" 2>/dev/null | tail -n1)"
    printf '%s' "${line#${key}=}"
}

dv_setting_set() {
    local key="$1" val="$2"
    dv_state_init
    if grep -qE "^${key}=" "${DISTROVANTA_SETTINGS}" 2>/dev/null; then
        # Use a temp file for safe replacement.
        local tmp
        tmp="$(mktemp 2>/dev/null || echo "${DISTROVANTA_SETTINGS}.tmp")"
        awk -v k="$key" -v v="$val" 'BEGIN{FS=OFS="="} $1==k{$0=k"="v} {print}' "${DISTROVANTA_SETTINGS}" >"$tmp" 2>/dev/null
        if [ -s "$tmp" ]; then
            mv -f "$tmp" "${DISTROVANTA_SETTINGS}"
        else
            rm -f "$tmp"
        fi
    else
        printf '%s=%s\n' "$key" "$val" >>"${DISTROVANTA_SETTINGS}"
    fi
    dv_log "setting_set key=$key"
}