#!/usr/bin/env bash
# modules/prompt.sh - Visual prompt customization with preview.

. "${DISTROVANTA_ROOT}/lib/common.sh"
. "${DISTROVANTA_ROOT}/core/backup.sh"
. "${DISTROVANTA_ROOT}/core/restore.sh"

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

dv_prompt_build_from() {
    # args: vname ename color sep showdir
    local vname="$1" ename="$2" color="$3" sep="$4" showdir="$5"
    [ -z "$vname" ] && vname='\u'
    [ -z "$ename" ] && ename='\h'
    [ -z "$sep" ] && sep='@'
    local ccode rcode
    ccode="$(dv_prompt_color_code "${color:-lightblue}")"
    rcode="$(dv_prompt_color_code reset)"
    local dirpart=''
    [ "$showdir" = "1" ] && dirpart=':\w'
    printf "PS1='%s%s%s%s%s%s\\$ '" "$ccode" "$vname" "$sep" "$ename" "$dirpart" "$rcode"
}

dv_prompt_preview() {
    # $1 vname $2 ename $3 color $4 sep $5 showdir
    local ps1
    ps1="$(dv_prompt_build_from "$1" "$2" "$3" "$4" "$5")"
    printf '\nPreview: %s\n\n' "$ps1"
    # Render a sample
    local vname="$1" ename="$2" color="$3" sep="$4" showdir="$5"
    [ -z "$vname" ] && vname='user'
    [ -z "$ename" ] && ename='host'
    [ -z "$sep" ] && sep='@'
    local ccode
    case "$color" in
        black) ccode=$'\033[30m' ;; blue) ccode=$'\033[34m' ;; lightblue) ccode=$'\033[94m' ;;
        gray) ccode=$'\033[90m' ;; white) ccode=$'\033[97m' ;; green) ccode=$'\033[32m' ;;
        red) ccode=$'\033[31m' ;; yellow) ccode=$'\033[33m' ;; *) ccode=$'\033[94m' ;;
    esac
    local rcode=$'\033[0m'
    printf '%b%s%s%s%s%b$ \n\n' "$ccode" "$vname" "$sep" "$ename" "$([ "$showdir" = "1" ] && printf ':%s' "$PWD")" "$rcode"
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
        printf '[1] Create/Update prompt\n'
        printf '[2] Remove prompt customization\n'
        printf '[0] Back\n\n'
        local c
        dv_read c "Choice: "
        case "$c" in
            1)
                local vname ename color sep showdir cur
                dv_read vname "Visual name (leave empty for real user): "
                if printf '%s' "$vname" | grep -qE '[^A-Za-z0-9._-]'; then
                    dv_err "Invalid characters. Use letters, digits, dot, underscore, hyphen."
                    dv_pause; continue
                fi
                dv_read ename "Environment name (leave empty for hostname): "
                if printf '%s' "$ename" | grep -qE '[^A-Za-z0-9._-]'; then
                    dv_err "Invalid characters."
                    dv_pause; continue
                fi
                printf 'Colors: black blue lightblue gray white green red yellow\n'
                dv_read color "Color: "
                case "$color" in
                    black|blue|lightblue|gray|white|green|red|yellow) ;;
                    *) color="$(dv_setting_get PROMPT_COLOR)"; [ -z "$color" ] && color=lightblue ;;
                esac
                dv_read sep "Separator (e.g. @ or :): "
                case "$sep" in
                    ''|*[!@:#-]*) : ;;
                esac
                [ -z "$sep" ] && sep="@"
                cur="$(dv_setting_get PROMPT_SHOW_DIR)"
                dv_read showdir "Show directory? [1=yes,0=no] (current $cur): "
                case "$showdir" in 0|1) ;; *) showdir="$cur"; [ -z "$showdir" ] && showdir=1 ;; esac

                dv_prompt_preview "$vname" "$ename" "$color" "$sep" "$showdir"
                printf 'Apply this prompt?\n\n'
                printf '[01] CONFIRM\n[02] CANCEL\n\n'
                local ans
                dv_read ans "Choice: "
                case "$ans" in
                    01|1)
                        dv_setting_set "PROMPT_VISUAL_NAME" "$vname"
                        dv_setting_set "PROMPT_ENV_NAME" "$ename"
                        dv_setting_set "PROMPT_COLOR" "$color"
                        dv_setting_set "PROMPT_SEPARATOR" "$sep"
                        dv_setting_set "PROMPT_SHOW_DIR" "$showdir"
                        if ! dv_shell_supported_full; then dv_err "Bash only."; dv_pause; continue; fi
                        local rc="${HOME}/.bashrc"
                        [ -f "$rc" ] && dv_backup_file "$rc" "prompt_apply" >/dev/null 2>&1 || true
                        dv_restore_strip_block "$rc" >/dev/null 2>&1 || true
                        local ps1
                        ps1="$(dv_prompt_build_from "$vname" "$ename" "$color" "$sep" "$showdir")"
                        {
                            printf '\n%s\n' "$DV_MARKER_BEGIN"
                            printf '%s\n' "$ps1"
                            printf '%s\n' "$DV_MARKER_END"
                        } >>"$rc"
                        dv_setting_set "DISTROVANTA_ENABLED" "1"
                        dv_ensure_bashrc_sourced
                        dv_ok "Prompt customization applied to $rc"
                        dv_info "Open a new terminal or run: source $rc"
                        ;;
                    *) dv_info "Cancelled. No changes applied." ;;
                esac
                dv_pause ;;
            2)
                if [ -f "${HOME}/.bashrc" ]; then
                    dv_restore_strip_block "${HOME}/.bashrc" && dv_ok "Removed."
                fi
                dv_pause ;;
            0) return 0 ;;
            *) dv_err "Invalid option."; dv_pause ;;
        esac
    done
}