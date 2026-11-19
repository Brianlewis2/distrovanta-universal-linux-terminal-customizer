#!/usr/bin/env bash
# core/detection.sh - Environment, distribution and shell detection.
# Sourced by distrovanta.sh

# shellcheck source=../lib/common.sh
. "${DISTROVANTA_ROOT}/lib/common.sh"

# ---- OS / architecture ------------------------------------------------------
dv_detect_os() {
    printf '%s' "$(uname -s 2>/dev/null || echo Unknown)"
}

dv_detect_arch() {
    printf '%s' "$(uname -m 2>/dev/null || echo Unknown)"
}

dv_detect_kernel() {
    printf '%s' "$(uname -r 2>/dev/null || echo Unknown)"
}

# ---- Distribution -----------------------------------------------------------
# Returns a normalized distribution id (lowercase) and version via globals.
DV_DISTRO_ID=""
DV_DISTRO_VERSION=""
DV_DISTRO_LIKE=""

dv_detect_distro() {
    DV_DISTRO_ID=""
    DV_DISTRO_VERSION=""
    DV_DISTRO_LIKE=""
    if [ -r /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        DV_DISTRO_ID="${ID:-}"
        DV_DISTRO_VERSION="${VERSION_ID:-}"
        DV_DISTRO_LIKE="${ID_LIKE:-}"
    elif [ -r /etc/lsb-release ]; then
        # shellcheck disable=SC1091
        . /etc/lsb-release
        DV_DISTRO_ID="${DISTRIB_ID:-}"
        DV_DISTRO_VERSION="${DISTRIB_RELEASE:-}"
    fi
    # Normalize
    DV_DISTRO_ID="$(printf '%s' "$DV_DISTRO_ID" | tr '[:upper:]' '[:lower:]')"
    [ -z "$DV_DISTRO_ID" ] && DV_DISTRO_ID="unknown"
}

# ---- Termux / Android -------------------------------------------------------
DV_IS_TERMUX=0
DV_IS_ANDROID=0
dv_detect_termux() {
    DV_IS_TERMUX=0
    DV_IS_ANDROID=0
    if [ -n "${TERMUX_VERSION:-}" ]; then
        DV_IS_TERMUX=1
    fi
    if [ -d /data/data/com.termux ] 2>/dev/null; then
        DV_IS_TERMUX=1
    fi
    if [ -n "${ANDROID_ROOT:-}" ] || [ -d /system/bin ] 2>/dev/null; then
        DV_IS_ANDROID=1
    fi
    # termux implies android
    [ "$DV_IS_TERMUX" = "1" ] && DV_IS_ANDROID=1
}

# ---- Shell detection --------------------------------------------------------
DV_CURRENT_SHELL=""
DV_SHELL_NAME=""
DV_SHELL_PATH=""
dv_detect_shell() {
    if [ -n "${BASH_VERSION:-}" ]; then
        DV_SHELL_NAME="bash"
        DV_CURRENT_SHELL="$(command -v bash 2>/dev/null || echo bash)"
    elif [ -n "${ZSH_VERSION:-}" ]; then
        DV_SHELL_NAME="zsh"
        DV_CURRENT_SHELL="$(command -v zsh 2>/dev/null || echo zsh)"
    elif [ -n "${FISH_VERSION:-}" ]; then
        DV_SHELL_NAME="fish"
        DV_CURRENT_SHELL="$(command -v fish 2>/dev/null || echo fish)"
    else
        DV_CURRENT_SHELL="${SHELL:-}"
        if [ -n "$DV_CURRENT_SHELL" ]; then
            DV_SHELL_NAME="$(basename "$DV_CURRENT_SHELL")"
        else
            DV_SHELL_NAME="$(ps -p $$ -o comm= 2>/dev/null || echo sh)"
            DV_SHELL_NAME="$(basename "$DV_SHELL_NAME")"
        fi
    fi
    DV_SHELL_PATH="$DV_CURRENT_SHELL"
}

# Supported shells for full features
dv_shell_supported_full() {
    case "${DV_SHELL_NAME}" in
        bash) return 0 ;;
        *) return 1 ;;
    esac
}

dv_shell_detected_other() {
    case "${DV_SHELL_NAME}" in
        zsh|fish) return 0 ;;
        *) return 1 ;;
    esac
}

# ---- Dependency check -------------------------------------------------------
# Check a command exists. Echoes 0/1.
dv_have() {
    command -v "$1" >/dev/null 2>&1 && echo 1 || echo 0
}

dv_check_deps() {
    # Core required
    for c in printf awk sed grep uname id; do
        if [ "$(dv_have "$c")" != "1" ]; then
            dv_warn "Missing dependency: $c"
        fi
    done
    # Optional
    for c in tput mktemp cp mv; do
        if [ "$(dv_have "$c")" != "1" ]; then
            dv_warn "Optional tool not found: $c (some features may be limited)"
        fi
    done
}

# ---- Environment summary -----------------------------------------------------
dv_env_summary() {
    dv_detect_distro
    dv_detect_termux
    dv_detect_shell
    dv_detect_os
    printf 'OS:        %s\n' "$(dv_detect_os)"
    printf 'Distro:    %s %s\n' "$DV_DISTRO_ID" "$DV_DISTRO_VERSION"
    printf 'Like:      %s\n' "${DV_DISTRO_LIKE:-none}"
    printf 'Arch:      %s\n' "$(dv_detect_arch)"
    printf 'Kernel:    %s\n' "$(dv_detect_kernel)"
    printf 'Shell:     %s (%s)\n' "$DV_SHELL_NAME" "$DV_SHELL_PATH"
    printf 'Termux:    %s\n' "$([ "$DV_IS_TERMUX" = "1" ] && echo yes || echo no)"
    printf 'Android:   %s\n' "$([ "$DV_IS_ANDROID" = "1" ] && echo yes || echo no)"
    printf 'Color:     %s\n' "$([ -n "$DV_COLOR_RESET" ] && echo yes || echo no)"
    printf 'Term width:%s\n' "$(dv_term_width)"
}

# ---- Compat status for a given distro --------------------------------------
# Returns: supported|partial|untested
dv_compat_status() {
    local id="$1"
    case "$id" in
        debian|ubuntu|linuxmint|kali|parrot) echo "supported (bash)" ;;
        fedora) echo "supported (bash)" ;;
        arch|manjaro) echo "supported (bash)" ;;
        alpine) echo "partial (busybox)" ;;
        *) echo "untested" ;;
    esac
}