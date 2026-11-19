#!/usr/bin/env bash
# modules/prompt.sh - Visual prompt customization (Bash only).
# Never changes real username or hostname.

. "${DISTROVANTA_ROOT}/lib/common.sh"
. "${DISTROVANTA_ROOT}/core/backup.sh"
. "${DISTROVANTA_ROOT}/core/restore.sh"

# Color codes for PS1
dv_prompt_color_code() {
    case "$1" in
        black) printf '\\[\\e[30m\\]' ;;
        blue) printf '\\[\\e[34m\\]' ;;
        lightblue) printf '\\[\\e[94m\\]' ;;
        gray) printf '\\[\\e[90m\\]' ;;
        white) printf '\\[\\e[97m\\]' ;;
        green) printf '\\[\\e[32m\\]' ;;
        red) printf '\\[\\e[31m\\]' ;;
        yellow) printf '\\[\\e[33m\\]' ;;
        reset) printf '\\[\\e[0m\\]' ;;
        *) printf '' ;;
    esac
}

dv_prompt_build() {
    # Uses settings: PROMPT_VISUAL_NAME, PROMPT_ENV_NAME, PROMPT_COLOR, PROMPT_SEPARATOR, PROMPT_SHOW_DIR
    local vname ename color sep showdir
    vname="$(dv_setting_get PROMPT_VISUAL_NAME)"
    ename="$(dv_setting_get PROMPT_ENV_NAME)"
    color="$(dv_setting_get PROMPT_COLOR)"
    sep="$(dv_setting_get PROMPT_SEPARATOR)"
    showdir="$(dv_setting_get PROMPT_SHOW_DIR)"
    [ -z "$vname" ] && vname='\u'
    [ -z "$ename" ] && ename='\h'
    [ -z "$sep" ] && sep='@'
    local ccode rcode
    ccode="$(dv_prompt_color_code "${color:-lightblue}")"
    rcode="$(dv_prompt_color_code reset)"
    local dirpart=''
    if [ "$showdir" = "1" ]; then
        dirpart=':\w'
    fi
    # Build PS1 (visual only)
    printf "PS1='%s%s%s%s%s%s\\$ '%s" "$ccode" "$vname" "$sep" "$ename" "$dirpart" "$rcode" ""
}

dv_prompt_apply() {
    if ! dv_shell_supported_full; then
        dv_err "Prompt customization is fully supported only on Bash."
        dv_info "Detected shell: ${DV_SHELL_NAME}"
        return 1
    fi
    local rc="${HOME}/.bashrc"
    # Backup
    [ -f "$rc" ] && dv_backup_file "$rc" "prompt_apply" >/dev/null 2>&1 || true
    # Remove existing managed block first
    if [ -f "$rc" ]; then
        dv_restore_strip_block "$rc" >/dev/null 2>&1 || true
    fi
    local ps1
    ps1="$(dv_prompt_build)"
    {
        printf '\n%s\n' "$DV_MARKER_BEGIN"
        printf '%s\n' "$ps1"
        printf '%s\n' "$DV_MARKER_END"
    } >>"$rc"
    dv_setting_set "DISTROVANTA_ENABLED" "1"
    dv_ok "Prompt customization applied to $rc"
    dv_info "Open a new terminal or run: source $rc"
}

dv_prompt_menu() {
    while true; do
        dv_clear
        dv_banner
        printf '%s\n\n' "CUSTOMIZE TERMINAL PROMPT"
        printf 'Current visual name : %s\n' "$(dv_setting_get PROMPT_VISUAL_NAME)"
        printf 'Current env name    : %s\n' "$(dv_setting_get PROMPT_ENV_NAME)"
        printf 'Current color       : %s\n' "$(dv_setting_get PROMPT_COLOR)"
        printf 'Current separator   : %s\n' "$(dv_setting_get PROMPT_SEPARATOR)"
        printf 'Show directory      : %s\n\n' "$(dv_setting_get PROMPT_SHOW_DIR)"
        printf '[1] Set visual name (username display)\n'
        printf '[2] Set environment name (host display)\n'
        printf '[3] Choose color\n'
        printf '[4] Choose separator\n'
        printf '[5] Toggle show directory\n'
        printf '[6] Apply to .bashrc\n'
        printf '[7] Remove prompt customization\n'
        printf '[0] Back\n\n'
        local c
        dv_read c "Choice: "
        case "$c" in
            1)
                local v
                dv_read v "Visual name (leave empty for real user): "
                # validate: no spaces/special injection
                if printf '%s' "$v" | grep -qE '[^A-Za-z0-9._-]'; then
                    dv_err "Invalid characters. Use letters, digits, dot, underscore, hyphen."
                else
                    dv_setting_set "PROMPT_VISUAL_NAME" "$v"
                    dv_ok "Set."
                fi
                dv_pause ;;
            2)
                local e
                dv_read e "Environment name (leave empty for hostname): "
                if printf '%s' "$e" | grep -qE '[^A-Za-z0-9._-]'; then
                    dv_err "Invalid characters."
                else
                    dv_setting_set "PROMPT_ENV_NAME" "$e"
                    dv_ok "Set."
                fi
                dv_pause ;;
            3)
                printf 'Colors: black blue lightblue gray white green red yellow\n'
                local col
                dv_read col "Color: "
                case "$col" in
                    black|blue|lightblue|gray|white|green|red|yellow)
                        dv_setting_set "PROMPT_COLOR" "$col"; dv_ok "Set." ;;
                    *) dv_err "Unknown color." ;;
                esac
                dv_pause ;;
            4)
                local s
                dv_read s "Separator (e.g. @ or :): "
                case "$s" in
                    ''|*[!@:#\-]*) dv_err "Use a simple separator like @ : or -" ;;
                    *) dv_setting_set "PROMPT_SEPARATOR" "$s"; dv_ok "Set." ;;
                esac
                dv_pause ;;
            5)
                local cur
                cur="$(dv_setting_get PROMPT_SHOW_DIR)"
                if [ "$cur" = "1" ]; then dv_setting_set "PROMPT_SHOW_DIR" "0"; else dv_setting_set "PROMPT_SHOW_DIR" "1"; fi
                dv_ok "Toggled." ; dv_pause ;;
            6) dv_prompt_apply; dv_pause ;;
            7)
                if [ -f "${HOME}/.bashrc" ]; then
                    dv_restore_strip_block "${HOME}/.bashrc" && dv_ok "Removed."
                fi
                dv_pause ;;
            0) return 0 ;;
            *) dv_err "Invalid option." ; dv_pause ;;
        esac
    done
}