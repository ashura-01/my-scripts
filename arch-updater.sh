#!/usr/bin/env bash
#
# Arch Linux Smart Update
# Safe, verified, full-system update routine with live system snapshot.
#
# Usage: sudo ./arch-update.sh
#

set -uo pipefail

# ────────────────────────────────────────────────────────────────
# Colors & symbols
# ────────────────────────────────────────────────────────────────
C_RESET='\033[0m'
C_CYAN='\033[1;36m'
C_BLUE='\033[1;34m'
C_GREEN='\033[1;32m'
C_YELLOW='\033[1;33m'
C_RED='\033[1;31m'
C_WHITE='\033[1;37m'
C_DIM='\033[2m'

CHECK="${C_GREEN}✓${C_RESET}"
CROSS="${C_RED}✗${C_RESET}"
ARROW="${C_CYAN}▸${C_RESET}"
DOT="${C_BLUE}●${C_RESET}"

BOX_H="━"
BOX_TL="┏"
BOX_TR="┓"
BOX_BL="┗"
BOX_BR="┛"
BOX_V="┃"

# ────────────────────────────────────────────────────────────────
# Helpers
# ────────────────────────────────────────────────────────────────
hr() {
    printf "${C_DIM}"
    printf '%.0s'"${BOX_H}" $(seq 1 60) 2>/dev/null || printf '%*s' 60 '' | tr ' ' "${BOX_H}"
    printf "${C_RESET}\n"
}

section() {
    printf "\n${C_BLUE}${BOX_TL}%s${C_RESET} ${C_WHITE}%s${C_RESET}\n" "${BOX_H}${BOX_H}" "$1"
}

ok()    { printf "  ${CHECK} %s\n" "$1"; }
warn()  { printf "  ${C_YELLOW}!${C_RESET} %s\n" "$1"; }
err()   { printf "  ${CROSS} %s\n" "$1"; }
step()  { printf "\n${ARROW} ${C_WHITE}%s${C_RESET}\n" "$1"; }

die() {
    err "$1"
    printf "\n${C_RED}${BOX_BL}${BOX_H}${BOX_H} Aborted. No further changes were made.${C_RESET}\n\n"
    exit 1
}

# ────────────────────────────────────────────────────────────────
# System info gathering (read-only, safe to run without root)
# ────────────────────────────────────────────────────────────────
gather_info() {
    local os_name kernel host uptime_s pkgs_native pkgs_foreign shell_name cpu_model mem_line disk_line

    if [ -r /etc/os-release ]; then
        os_name=$(. /etc/os-release; echo "${PRETTY_NAME:-Arch Linux}")
    else
        os_name="Arch Linux"
    fi

    kernel=$(uname -r)
    host=$(hostname 2>/dev/null || echo "unknown")
    uptime_s=$(uptime -p 2>/dev/null | sed 's/^up //' || echo "unknown")

    if command -v pacman &>/dev/null; then
        pkgs_native=$(pacman -Qq 2>/dev/null | wc -l)
        pkgs_foreign=$(pacman -Qmq 2>/dev/null | wc -l)
    else
        pkgs_native="?"; pkgs_foreign="?"
    fi

    shell_name=$(basename "${SHELL:-unknown}")

    if [ -r /proc/cpuinfo ]; then
        cpu_model=$(awk -F: '/model name/ {print $2; exit}' /proc/cpuinfo | sed 's/^[ \t]*//')
    else
        cpu_model="unknown"
    fi
    [ -z "$cpu_model" ] && cpu_model="unknown"

    if command -v free &>/dev/null; then
        mem_line=$(free -h 2>/dev/null | awk '/^Mem:/ {print $3" / "$2}')
    else
        mem_line="unknown"
    fi

    if command -v df &>/dev/null; then
        disk_line=$(df -h / 2>/dev/null | awk 'NR==2 {print $3" / "$2" ("$5" used)"}')
    else
        disk_line="unknown"
    fi

    INFO=(
        "${C_WHITE}${SUDO_USER:-$USER}${C_RESET}${C_DIM}@${C_RESET}${C_WHITE}${host}${C_RESET}"
        "${C_DIM}────────────────${C_RESET}"
        "${C_CYAN}OS${C_RESET}       ${os_name}"
        "${C_CYAN}Kernel${C_RESET}   ${kernel}"
        "${C_CYAN}Uptime${C_RESET}   ${uptime_s}"
        "${C_CYAN}Packages${C_RESET} ${pkgs_native} ${C_DIM}(pacman)${C_RESET} + ${pkgs_foreign} ${C_DIM}(AUR)${C_RESET}"
        "${C_CYAN}Shell${C_RESET}    ${shell_name}"
        "${C_CYAN}CPU${C_RESET}      ${cpu_model}"
        "${C_CYAN}Memory${C_RESET}   ${mem_line}"
        "${C_CYAN}Disk /${C_RESET}   ${disk_line}"
    )
}

print_banner() {
    local logo=(
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣠⣤⣦⣶⣶⣦⣴⣤⣠⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
        "⠀⠀⠀⠀⠀⢀⣤⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⢿⢶⣄⠀⠀⠀⠀⠀⠀"
        "⠀⠀⠀⠀⠐⠋⠁⠉⠀⠀⠀⠀⠉⠉⠻⣿⣿⣿⣿⣧⡀⠀⠀⠙⠀⠀⠀⠀⠀"
        "⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⠤⠀⠀⠀⠀⠘⣿⣿⣿⣿⣿⣷⠀⠀⠀⠀⠀⠀⠀"
        "⠀⠀⠀⠀⠀⢀⣤⣾⣿⠟⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣷⠀⠀⠀⠀⠀⠀"
        "⠀⠀⠀⠀⣰⣾⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⠃⠀⠀⠀⠀⠀"
        "⣷⠀⠀⣼⣿⣿⣿⣿⣿⣿⣄⠀⠀⠀⢀⣠⡿⠏⠉⠉⠹⣿⣿⡆⠀⠀⠀⣼⡇"
        "⣿⡃⢰⣿⣿⣿⣿⣿⣿⠟⠟⠛⠻⣿⣿⡋⠀⠀⠀⠀⠀⠀⠿⠀⠀⠀⢰⣿⡇"
        "⣿⣿⣸⣿⣿⣿⣿⠋⠀⠀⠀⠀⠀⠈⢹⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⡃"
        "⢻⣿⣿⣿⣿⣿⠃⠀⠀⠀⠀⠀⠀⠀⢸⣧⡄⠀⠀⠀⠀⠀⠀⢀⣤⣿⣿⡿⠃"
        "⠈⢻⣿⣿⣿⣏⠀⠀⠀⠀⠀⠀⠀⣀⣾⣿⣿⣿⣶⣤⣤⣶⣾⣿⣿⣿⣿⠋⠀"
        "⠀⠀⠿⣿⣿⣿⡂⠀⠀⠀⠲⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠇⠀⠀"
        "⠀⠀⠀⠙⢿⣿⣷⣂⠀⠀⠀⠈⠙⠿⢿⢿⣿⣿⣿⠿⠟⣻⣿⣿⠿⠁⠀⠀⠀"
        "⠀⠀⠀⠀⠀⠘⠛⢿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⡿⠋⠁⠀⠀⠀⠀⠀"
        "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠂⠀⠀⠀⠀⠀⠀⠀⠈⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀"
    )

    gather_info

    local total=${#logo[@]}
    local info_count=${#INFO[@]}
    [ "$info_count" -gt "$total" ] && total=$info_count

    echo
    for ((i=0; i<total; i++)); do
        local l="${logo[i]:-$(printf '%29s' '')}"
        local r="${INFO[i]:-}"
        printf "  ${C_CYAN}%s${C_RESET}   %b\n" "$l" "$r"
    done
    echo
}

# ────────────────────────────────────────────────────────────────
# Safety checks
# ────────────────────────────────────────────────────────────────
require_root() {
    if [ "$EUID" -ne 0 ]; then
        die "Run this with sudo, e.g.  sudo ./arch-update.sh"
    fi
    if [ -z "${SUDO_USER:-}" ]; then
        die "Run via sudo from a normal user account, not directly as root (needed for AUR builds)."
    fi
}

check_tools() {
    step "Checking required tools"
    command -v pacman &>/dev/null || die "pacman not found — is this really Arch Linux?"
    ok "pacman found"

    if command -v yay &>/dev/null; then
        HAS_YAY=1
        ok "yay found (AUR updates enabled)"
    else
        HAS_YAY=0
        warn "yay not found — AUR packages will be skipped"
    fi

    if command -v reflector &>/dev/null; then
        HAS_REFLECTOR=1
        ok "reflector found (mirrorlist will be refreshed)"
    else
        HAS_REFLECTOR=0
        warn "reflector not found — mirrorlist refresh will be skipped"
    fi

    if command -v paccache &>/dev/null; then
        HAS_PACCACHE=1
        ok "pacman-contrib found (cache cleanup enabled)"
    else
        HAS_PACCACHE=0
        warn "pacman-contrib not found — cache cleanup will be skipped"
    fi
}

check_connectivity() {
    step "Checking internet connectivity"
    if ping -c1 -W2 archlinux.org &>/dev/null || ping -c1 -W2 1.1.1.1 &>/dev/null; then
        ok "Connection looks good"
    else
        die "No internet connection detected — fix your network before updating."
    fi
}

check_disk_space() {
    step "Checking free space on /"
    local avail_kb
    avail_kb=$(df --output=avail / 2>/dev/null | tail -1 | tr -d '[:space:]')
    if [ -z "$avail_kb" ]; then
        warn "Could not determine free space, continuing anyway"
        return
    fi
    local avail_mb=$((avail_kb / 1024))
    if [ "$avail_mb" -lt 1024 ]; then
        die "Only ${avail_mb} MiB free on / — need at least 1024 MiB to update safely."
    fi
    ok "${avail_mb} MiB free"
}

# ────────────────────────────────────────────────────────────────
# Update steps
# ────────────────────────────────────────────────────────────────
backup_mirrorlist() {
    step "Backing up mirrorlist"
    if cp /etc/pacman.d/mirrorlist "/etc/pacman.d/mirrorlist.backup.$(date +%Y%m%d%H%M%S)"; then
        ok "Backup saved"
    else
        die "Could not back up mirrorlist — aborting before any changes."
    fi
}

refresh_mirrors() {
    [ "$HAS_REFLECTOR" -eq 1 ] || return 0
    step "Refreshing mirrorlist with reflector"
    if reflector \
        --country 'Singapore,Japan,Taiwan,Hong Kong,South Korea,India,Bangladesh,Germany' \
        --latest 20 --age 12 --protocol https --sort rate --download-timeout 5 \
        --save /etc/pacman.d/mirrorlist.new; then
        if [ -s /etc/pacman.d/mirrorlist.new ]; then
            mv /etc/pacman.d/mirrorlist.new /etc/pacman.d/mirrorlist
            ok "Mirrorlist updated"
        else
            warn "reflector produced an empty file — keeping existing mirrorlist"
            rm -f /etc/pacman.d/mirrorlist.new
        fi
    else
        warn "reflector failed — keeping existing mirrorlist"
        rm -f /etc/pacman.d/mirrorlist.new
    fi
}

update_system() {
    step "Syncing repositories and upgrading packages"
    if ! pacman -Syu; then
        die "pacman -Syu failed — resolve the error above before re-running."
    fi
    ok "System packages up to date"
}

update_aur() {
    [ "$HAS_YAY" -eq 1 ] || return 0
    step "Upgrading AUR packages as ${SUDO_USER}"
    if sudo -u "$SUDO_USER" yay -Sua; then
        ok "AUR packages up to date"
    else
        warn "yay reported a problem — check the output above (repo packages were still updated)"
    fi
}

clean_cache() {
    [ "$HAS_PACCACHE" -eq 1 ] || return 0
    step "Cleaning package cache safely"
    paccache -rk2 && ok "Kept last 2 versions of installed packages"
    paccache -ruk0 && ok "Removed cache of uninstalled packages"
}

check_orphans() {
    step "Checking for orphaned packages"
    local orphans
    orphans=$(pacman -Qtdq 2>/dev/null)
    if [ -n "$orphans" ]; then
        warn "Orphans found — review and remove with:"
        printf "      ${C_DIM}sudo pacman -Rns \$(pacman -Qtdq)${C_RESET}\n"
    else
        ok "No orphaned packages"
    fi
}

check_pacnew() {
    step "Checking for unmerged config files"
    local files
    files=$(find /etc -type f \( -name "*.pacnew" -o -name "*.pacsave" \) 2>/dev/null)
    if [ -n "$files" ]; then
        warn "Found .pacnew/.pacsave files — review with 'pacdiff':"
        while IFS= read -r f; do
            printf "      ${C_DIM}%s${C_RESET}\n" "$f"
        done <<< "$files"
    else
        ok "No .pacnew or .pacsave files"
    fi
}

# ────────────────────────────────────────────────────────────────
# Main
# ────────────────────────────────────────────────────────────────
main() {
    require_root
    print_banner

    section "Pre-flight checks"
    check_tools
    check_connectivity
    check_disk_space

    section "Update"
    backup_mirrorlist
    refresh_mirrors
    update_system
    update_aur

    section "Maintenance"
    clean_cache
    check_orphans
    check_pacnew

    echo
    printf "${C_GREEN}${BOX_TL}${BOX_H}${BOX_H}${C_RESET} ${C_WHITE}All done — system is fully updated.${C_RESET}\n\n"
}

main "$@"
