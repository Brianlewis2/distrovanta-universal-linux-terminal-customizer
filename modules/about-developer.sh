#!/usr/bin/env bash
# modules/about-developer.sh - About the developer.

. "${DISTROVANTA_ROOT}/lib/common.sh"

dv_about_developer() {
    dv_clear
    dv_banner
    printf '%s\n\n' "ABOUT THE DEVELOPER"
    printf 'Brian Lewis\n'
    printf 'Full Stack Developer • AI Engineer\n\n'
    printf 'Independent creator of DISTROVANTA.\n'
    printf 'BRJ Dev appears as a discrete partner.\n\n'
    printf 'BRJ Dev is a private software development company founded by Brian Lewis,\n'
    printf 'dedicated to building applications, platforms, technological solutions\n'
    printf 'and digital projects.\n\n'
    printf 'DISTROVANTA remains identified as an independent project by Brian Lewis.\n\n'
    dv_pause
}

dv_about_distrovanta() {
    dv_clear
    dv_banner
    printf '%s\n\n' "ABOUT DISTROVANTA"
    printf 'Name   : DISTROVANTA\n'
    printf 'Tagline: Universal Linux Terminal Customizer\n'
    printf 'Version: %s\n' "$DISTROVANTA_VERSION"
    printf 'Creator: Brian Lewis\n'
    printf 'Partner: BRJ Dev (discrete)\n\n'
    printf 'Purpose: Terminal personalization across Linux distributions and Termux.\n'
    printf 'Not a security, intrusion or vulnerability tool.\n\n'
    dv_pause
}