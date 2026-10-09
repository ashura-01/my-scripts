#!/bin/bash

# ==============================================================================
# KALI LINUX SYSTEM HEALTH CHECK - MASTER EDITION v3.3
# Fixed: Header alignment, sub-headers, footer positioning
# ==============================================================================

if [ "$EUID" -ne 0 ]; then
  echo -e "\e[1;31m[-] Please run as root: sudo bash $0\e[0m"
  exit 1
fi

# ── Colors ─────────────────────────────────────────────────────────────────────
NC=$'\e[0m'
BOLD=$'\e[1m'
WHITE=$'\e[1;37m'
WGREEN=$'\e[38;5;158m'  # Whitish green
YELLOW=$'\e[1;33m'
RED=$'\e[1;31m'
GRAY=$'\e[0;37m'
DKGRAY=$'\e[2;37m'

# ── Helpers ────────────────────────────────────────────────────────────────────
bar() {
    local pct=${1:-0} width=36 color fill empty
    pct=$(( pct > 100 ? 100 : pct < 0 ? 0 : pct ))
    fill=$(( pct * width / 100 ))
    empty=$(( width - fill ))
    if   [ "$pct" -ge 85 ]; then color=$RED
    elif [ "$pct" -ge 60 ]; then color=$YELLOW
    else color=$WGREEN
    fi
    printf "${DKGRAY}[${color}"
    for ((i=0;i<fill;i++));  do printf '█'; done
    printf "${DKGRAY}"
    for ((i=0;i<empty;i++)); do printf '░'; done
    printf "${DKGRAY}]${NC} ${BOLD}${WHITE}%3d%%${NC}" "$pct"
}

hdr() {
    local title="$1"
    local len=${#title}
    local padding=$(( 76 - len - 2 ))  # 76 = content width, 2 for "⚡ "
    echo -e "\n${WGREEN}╔══════════════════════════════════════════════════════════════════════════════════╗${NC}"
    printf "${WGREEN}║${NC} ${WGREEN}${BOLD}⚡ %s${NC}%*s${WGREEN}${NC}\n" "$title" "$padding" ""
    echo -e "${WGREEN}╚══════════════════════════════════════════════════════════════════════════════════╝${NC}"
}

sub() {
    local title="$1"
    local len=${#title}
    local dash_count=$(( 70 - len - 4 ))
    printf "\n  ${WGREEN}── %s %*s${NC}\n" "$title" "$dash_count" ""
}

ok()  { echo -e "  ${WGREEN}${BOLD} ✔ ${NC} $*"; }
warn(){ echo -e "  ${YELLOW}${BOLD} ⚠ ${NC} $*"; }
err() { echo -e "  ${RED}${BOLD} ✘ ${NC} $*"; }
inf() { echo -e "  ${WGREEN}${BOLD} • ${NC} $*"; }
kv()  { printf "  ${WGREEN}${BOLD}%-22s${NC}${WHITE}%s${NC}\n" "$1" "$2"; }

# ── Gather Data ────────────────────────────────────────────────────────────────
os_name="Kali GNU/Linux Rolling"
os_id=$(lsb_release -c 2>/dev/null | awk '{print $2}')
kernel_ver=$(uname -r)
cpu_arch=$(uname -m)
hostname_val=$(hostname)

# CPU — cores = physical, threads = logical (total)
cpu_model=$(lscpu | awk -F': +' '/Model name/{print $2; exit}')
cpu_cores=$(lscpu | awk '/^Core\(s\) per socket/{c=$NF} /^Socket\(s\)/{s=$NF} END{print c*s}')
cpu_logical=$(lscpu | awk '/^CPU\(s\):/{print $2; exit}')
[ -z "$cpu_cores" ] && cpu_cores=$cpu_logical
cpu_freq=$(lscpu | awk '/^CPU MHz/{printf "%.0f", $NF; exit}')
cpu_max=$(lscpu | awk '/^CPU max MHz/{printf "%.0f", $NF; exit}')
cpu_min=$(lscpu | awk '/^CPU min MHz/{printf "%.0f", $NF; exit}')
cpu_virt=$(lscpu | awk -F': +' '/^Virtualization/{print $2}')
cpu_l3=$(lscpu | awk -F': +' '/^L3 cache/{print $2}')

gpu_model=$(lspci 2>/dev/null | grep -Ei 'vga|3d|display' | head -1 \
  | sed 's/.*: //' | sed 's/ (.*//' | xargs)

uptime_str=$(uptime -p | sed 's/up //')

# Shell — get version properly per shell
shell_name=$(basename "$SHELL")
case "$shell_name" in
  zsh)  shell_ver=$(zsh --version 2>/dev/null | awk '{print $2}') ;;
  bash) shell_ver=$(bash --version 2>/dev/null | head -1 | grep -oP '\d+\.\d+\.\d+') ;;
  fish) shell_ver=$(fish --version 2>/dev/null | awk '{print $3}') ;;
  *)    shell_ver=$("$SHELL" --version 2>/dev/null | head -1 | awk '{print $NF}') ;;
esac

pkgs=$(dpkg -l 2>/dev/null | grep -c '^ii')
de_wm="${XDG_CURRENT_DESKTOP:-${DESKTOP_SESSION:-TTY}}"
term="${TERM:-unknown}"
ip_local=$(ip route get 1.1.1.1 2>/dev/null | awk '/src/{for(i=1;i<=NF;i++) if($i=="src") print $(i+1)}')
locale_val=$(locale 2>/dev/null | awk -F= '/^LANG=/{print $2; exit}')
tz_val=$(timedatectl 2>/dev/null | awk '/Time zone/{print $3}')

# Memory
ram_total_kb=$(awk '/MemTotal/{print $2}' /proc/meminfo)
ram_avail_kb=$(awk '/MemAvailable/{print $2}' /proc/meminfo)
ram_used_kb=$(( ram_total_kb - ram_avail_kb ))
ram_pct=$(( ram_used_kb * 100 / ram_total_kb ))
to_h() { awk -v k="$1" 'BEGIN{
  if(k>=1073741824) printf "%.1f TiB", k/1073741824
  else if(k>=1048576) printf "%.1f GiB", k/1048576
  else if(k>=1024) printf "%.1f MiB", k/1024
  else printf "%d KiB", k }'; }
ram_total_h=$(to_h $ram_total_kb)
ram_used_h=$(to_h $ram_used_kb)
ram_avail_h=$(to_h $ram_avail_kb)

swap_total_kb=$(awk '/SwapTotal/{print $2}' /proc/meminfo)
swap_free_kb=$(awk '/SwapFree/{print $2}'  /proc/meminfo)
swap_used_kb=$(( swap_total_kb - swap_free_kb ))
swap_pct=0
[ "$swap_total_kb" -gt 0 ] && swap_pct=$(( swap_used_kb * 100 / swap_total_kb ))
swap_total_h=$(to_h $swap_total_kb)
swap_used_h=$(to_h $swap_used_kb)

# Storage
root_dev=$(df / | awk 'NR==2{print $1}')
root_size=$(df -h / | awk 'NR==2{print $2}')
root_used=$(df -h / | awk 'NR==2{print $3}')
root_avail=$(df -h / | awk 'NR==2{print $4}')
root_pct=$(df / | awk 'NR==2{gsub(/%/,"",$5); print $5}')

# ── HEADER ─────────────────────────────────────────────────────────────────────
clear
printf "${WGREEN}"
echo "  ╔══════════════════════════════════════════════════════════════════════════════════╗"
echo "  ║          KALI LINUX  ·  SYSTEM INTEGRITY & DIAGNOSTICS  v3.3                     ║"
echo "  ╚══════════════════════════════════════════════════════════════════════════════════╝"
printf "${NC}"

# ── Kali Logo + Info ───────────────────────────────────────────────────────────
cat << EOF
  ${WGREEN}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⡀⠀⡀${NC}               ${WGREEN}╔═════════════════════════════════════════╗${NC}
  ${WGREEN}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠱⣄⠘⣆${NC}              ${WGREEN}║${NC}  ${WHITE}${BOLD}$(printf '%-39s' "  ${hostname_val}  @  kali")${NC}${WGREEN} ${NC}
  ${WGREEN}⠀⠀⠀⠀⠀⠀⣀⠀⠀⢢⣤⣀⣦⣄⡀⠙⣶⡘⢷⣄${NC}            ${WGREEN}╚═════════════════════════════════════════╝${NC}
  ${WGREEN}⠀⠀⠀⠀⣀⣀⣨⣿⣿⣿⣿⣿⣿⣿⣿⣷⣿⣿⣯⣿⣷⣄${NC}
  ${WGREEN}⠀⠀⠀⢀⣽⣿⣿⣿⣿⠟⠛⠛⠛⠛⠻⢿⣿⣿⣿⣿⣿⣿⣷⣄${NC}
  ${WGREEN}⠀⠀⠘⣻⣿⣿⡿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⢿⣿⣿⣿⣿⢿⣷⡀${NC}      ${WGREEN}${BOLD}OS${NC}         ${WHITE}${os_name}${NC}
  ${WGREEN}⠀⠀⣴⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⣿⣿⣿⣷⣽⣷⣄${NC}     ${WGREEN}${BOLD}Kernel${NC}     ${WHITE}${kernel_ver}${NC}
  ${WGREEN}⠀⠀⠀⣾⣿⣿⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠛⢿⣿⣿⣿⣯⠁${NC}    ${WGREEN}${BOLD}Shell${NC}      ${WHITE}${shell_name} ${shell_ver}${NC}
  ${WGREEN}⠀⠀⠐⠛⢿⣿⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠻⣿⣿⣷⣄⡀${NC}  ${WGREEN}${BOLD}Uptime${NC}     ${WHITE}${uptime_str}${NC}
  ${WGREEN}⠀⠀⠀⠀⠘⠟⠿⣿⣿⣦⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢿⣿⣿⠇${NC}  ${WGREEN}${BOLD}Packages${NC}   ${WHITE}${pkgs} (dpkg)${NC}
  ${WGREEN}⠀⠀⠀⠀⠀⠀⠀⠈⠙⠻⣿⣷⣦⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡼⠟⠋${NC}   ${WGREEN}${BOLD}Terminal${NC}   ${WHITE}${term}${NC}
  ${WGREEN}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⠻⢿⣷⣶⣄⠀⠀⠀⠀⠀⠀⠀⠀${NC}      ${WGREEN}${BOLD}DE/WM${NC}      ${WHITE}${de_wm}${NC}
  ${WGREEN}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⠻⣿⣦⡀⠀⠀⠀⠀⠀${NC}      ${WGREEN}${BOLD}IP${NC}         ${WHITE}${ip_local}${NC}
  ${WGREEN}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢿⡄⠀⠀⠀⠀${NC}
  ${WGREEN}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⡄⠀⠀⠀⠀${NC}
  ${WGREEN}⠲⣶⣶⣦⠀⢀⣴⣶⣶⠖⠀⠀⠒⢶⣶⣶⣶⠀⠀⠐⢶⣶⣶⣦⠀⠀⠀⠒⢶⣶⣶⡆${NC}
  ${WGREEN}⠀⣿⣿⣿⣠⣾⣿⡿⠋⠀⠀⠀⢠⣿⣿⣿⣿⣧⠀⠀⠠⣿⣿⣿⠀⠀⠀⠀⢸⣿⣿⡇${NC}
  ${WGREEN}⠀⣿⣿⣿⣿⣿⣿⡀⠀⠀⠀⠀⣾⣿⡿⠹⣿⣿⣇⠀⠐⣿⣿⣿⠀⠀⠀⠀⢸⣿⣿⡇${NC}
  ${WGREEN}⠀⣿⣿⣿⠟⣿⣿⣿⣄⠀⠀⣼⣿⣿⣿⣶⣿⣿⣿⣆⢈⣿⣿⣿⣤⣤⣄⣀⣸⣿⣿⡇${NC}
  ${WGREEN}⠀⣿⣿⡿⠀⠈⢿⣿⣿⡆⢸⣿⣿⠏⠉⠉⠉⢿⣿⡿⡄⣿⣿⣿⣿⢿⣿⡿⢸⣿⣿⡇${NC}
EOF

# ══════════════════════════════════════════════════════
# 1. OS DETAILS
# ══════════════════════════════════════════════════════
hdr "OPERATING SYSTEM DETAILS"
kv "Distribution:"    "$os_name"
kv "Codename:"        "${os_id:-kali-rolling}"
kv "Kernel:"          "$kernel_ver"
kv "Architecture:"    "$cpu_arch"
kv "Hostname:"        "$hostname_val"
kv "Shell:"           "${shell_name} ${shell_ver}"
kv "DE / WM:"         "$de_wm"
kv "Terminal:"        "$term"
kv "Uptime:"          "$uptime_str"
kv "Packages:"        "$pkgs (dpkg)"
kv "Local IP:"        "$ip_local"
kv "Locale:"          "${locale_val:-N/A}"
kv "Timezone:"        "${tz_val:-N/A}"
if [ -d /sys/firmware/efi ]; then
  kv "Boot Mode:"     "UEFI"
else
  kv "Boot Mode:"     "Legacy BIOS"
fi

# ══════════════════════════════════════════════════════
# 2. STORAGE DETAILS
# ══════════════════════════════════════════════════════
hdr "STORAGE POOL DETAILS"

echo -e "\n  ${WGREEN}${BOLD}Filesystem Mounts${NC}  ${DKGRAY}(tmpfs/devtmpfs hidden)${NC}"
printf "  ${WGREEN}${BOLD}%-22s %6s %6s %6s %5s  %s${NC}\n" \
  "Device" "Size" "Used" "Avail" "Use%" "Mount"
echo -e "  ${WGREEN}$(printf '%.0s─' {1..75})${NC}"
df -h --output=source,size,used,avail,pcent,target \
    -x tmpfs -x devtmpfs -x overlay -x squashfs 2>/dev/null | tail -n +2 | \
while IFS= read -r line; do
    p=$(echo "$line" | awk '{gsub(/%/,"",$5); print $5+0}')
    if [ "$p" -ge 85 ]; then
        printf "  ${RED}%-22s %6s %6s %6s %5s  %s${NC}\n" $line
    elif [ "$p" -ge 70 ]; then
        printf "  ${YELLOW}%-22s %6s %6s %6s %5s  %s${NC}\n" $line
    else
        printf "  ${WHITE}%-22s %6s %6s %6s %5s  %s${NC}\n" $line
    fi
done

echo -e "\n  ${WGREEN}${BOLD}Root Partition   ${DKGRAY}${root_dev}${NC}"
printf "  "; bar "$root_pct"; echo -e "  ${DKGRAY}${root_used} used / ${root_size} total — ${root_avail} free${NC}"

echo -e "\n  ${WGREEN}${BOLD}RAM${NC}"
printf "  "; bar "$ram_pct"; echo -e "  ${DKGRAY}${ram_used_h} used / ${ram_total_h} total — ${ram_avail_h} free${NC}"

echo -e "\n  ${WGREEN}${BOLD}Swap${NC}"
if [ "$swap_total_kb" -gt 0 ]; then
    printf "  "; bar "$swap_pct"; echo -e "  ${DKGRAY}${swap_used_h} used / ${swap_total_h} total${NC}"
else
    echo -e "  ${DKGRAY}  No swap configured${NC}"
fi

echo -e "\n  ${WGREEN}${BOLD}Block Devices${NC}"
echo -e "  ${DKGRAY}$(lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS,MODEL 2>/dev/null \
  | head -20 | sed 's/^/  /')${NC}"

# ══════════════════════════════════════════════════════
# 3. HARDWARE DETAILS
# ══════════════════════════════════════════════════════
hdr "HARDWARE SPECIFICATION"

sub "CPU"
kv "Model:"           "$cpu_model"
kv "Cores / Threads:" "${cpu_cores} cores / ${cpu_logical} threads"
[ -n "$cpu_freq"   ] && kv "Current Freq:"  "${cpu_freq} MHz"
[ -n "$cpu_min" ] && [ -n "$cpu_max" ] && kv "Freq Range:"  "${cpu_min} – ${cpu_max} MHz"
[ -n "$cpu_virt"   ] && kv "Virtualization:" "$cpu_virt"
[ -n "$cpu_l3"     ] && kv "L3 Cache:"       "$cpu_l3"

sub "GPU"
kv "Primary GPU:"  "${gpu_model:-N/A}"
# driver
for d in nvidia nouveau amdgpu radeon i915; do
  lsmod 2>/dev/null | grep -q "^$d" && kv "Driver:" "$d" && break
done

sub "MEMORY"
kv "Total RAM:"  "$ram_total_h"
kv "Used:"       "$ram_used_h"
kv "Available:"  "$ram_avail_h"
kv "Swap Total:" "$swap_total_h"
kv "Swap Used:"  "$swap_used_h"

if command -v dmidecode &>/dev/null; then
    dimm=$(dmidecode --type 17 2>/dev/null \
      | awk '/Memory Device/,0' \
      | grep -E '^\s+(Size|Type:|Speed:|Manufacturer):' \
      | grep -v 'Unknown\|No Module\|Volatile' | head -16)
    if [ -n "$dimm" ]; then
        echo -e "\n  ${WGREEN}${BOLD}  DIMM Slots (DMI):${NC}"
        echo "$dimm" | while IFS= read -r l; do
          echo -e "  ${DKGRAY}    $l${NC}"
        done
    fi
fi

sub "NETWORK"
printf "  ${WGREEN}${BOLD}%-16s %-24s %-20s %s${NC}\n" "Interface" "Address" "MAC" "State"
echo -e "  ${WGREEN}$(printf '%.0s─' {1..72})${NC}"
ip -o link show 2>/dev/null | awk -F': ' '{print $2}' | grep -v '^lo$' | \
while read -r iface; do
    ipaddr=$(ip -4 addr show "$iface" 2>/dev/null \
      | grep -oP '(?<=inet )\S+' | head -1)
    if [ -z "$ipaddr" ]; then
        ipaddr="no IPv4"
    fi
    mac=$(cat "/sys/class/net/${iface}/address" 2>/dev/null || echo "N/A")
    state=$(cat "/sys/class/net/${iface}/operstate" 2>/dev/null || echo "?")
    case "$state" in
      up)   sc="${WGREEN}up${NC}" ;;
      down) sc="${RED}down${NC}" ;;
      *)    sc="${YELLOW}${state}${NC}" ;;
    esac
    printf "  ${WHITE}%-16s${NC} %-24s ${DKGRAY}%-20s${NC} %b\n" \
      "$iface" "$ipaddr" "$mac" "$sc"
done

sub "PERIPHERALS"
lspci 2>/dev/null | grep -Ei 'audio|sound|usb controller|bluetooth|wireless|ethernet|network' \
  | awk -F': ' '{print $2}' | sed 's/ (.*//' | sort -u \
  | while IFS= read -r d; do echo -e "  ${DKGRAY}•${NC} ${WHITE}$d${NC}"; done

# ══════════════════════════════════════════════════════
# 4. OS HEALTH
# ══════════════════════════════════════════════════════
hdr "OPERATING SYSTEM HEALTH CHECK"

# 4.1 Package integrity
echo -e "\n  ${WGREEN}${BOLD}[4.1] Package Database Integrity${NC}"
broken=$(dpkg --audit 2>&1)
if [ -z "$broken" ]; then
    ok "DPKG database clean — no broken packages"
else
    err "Broken/unconfigured packages detected:"
    echo "$broken" | while IFS= read -r l; do echo -e "        ${YELLOW}$l${NC}"; done
    inf "Fix: sudo dpkg --configure -a && sudo apt -f install"
fi

# 4.2 Pending updates
echo -e "\n  ${WGREEN}${BOLD}[4.2] Pending System Updates${NC}"
update_list=$(apt list --upgradable 2>/dev/null | grep -v "^Listing" | grep -v "WARNING")
update_count=$(echo "$update_list" | grep -c '/')
security_count=$(echo "$update_list" | grep -ci security)
if [ "$update_count" -eq 0 ] || [ -z "$update_list" ]; then
    ok "System is fully up to date"
else
    warn "${update_count} package(s) available for upgrade"
    inf "Run: sudo apt update && sudo apt upgrade"
    [ "$security_count" -gt 0 ] && \
        err "${security_count} SECURITY update(s) — upgrade immediately!"
fi

# 4.3 Failed services
echo -e "\n  ${WGREEN}${BOLD}[4.3] Systemd Service Status${NC}"
mapfile -t failed_svcs < <(
    systemctl --failed --no-legend 2>/dev/null \
    | sed 's/^[[:space:]]*//' \
    | awk '$1 != "" && $1 != "●" {print $1}' \
    | grep '\.')
if [ "${#failed_svcs[@]}" -eq 0 ]; then
    ok "All system services running normally"
else
    err "${#failed_svcs[@]} failed service(s):"
    for svc in "${failed_svcs[@]}"; do
        echo -e "        ${RED}✘ ${svc}${NC}"
        desc=$(systemctl show -p Description "$svc" 2>/dev/null \
          | sed 's/Description=//')
        [ -n "$desc" ] && echo -e "          ${DKGRAY}↳ ${desc}${NC}"
    done
    inf "Inspect: journalctl -xe -u <service>"
fi

# 4.4 Journal errors
echo -e "\n  ${WGREEN}${BOLD}[4.4] Journal Critical Errors (this boot)${NC}"
crit_lines=$(journalctl -p 3 -b --no-pager -q 2>/dev/null)
crit_count=$(echo "$crit_lines" | grep -c .)
if [ "$crit_count" -eq 0 ]; then
    ok "No critical errors in journal since last boot"
else
    warn "${crit_count} critical message(s). Last 5:"
    echo "$crit_lines" | tail -5 | while IFS= read -r l; do
        echo -e "        ${RED}${l}${NC}"
    done
fi

# 4.5 dmesg errors
echo -e "\n  ${WGREEN}${BOLD}[4.5] Disk I/O Errors (dmesg)${NC}"
disk_errs=$(dmesg 2>/dev/null | grep -iE \
  'ata[0-9]+.*error|i/o error|bad sector|disk failure|nvme.*error|blk_update_request' \
  | tail -5)
if [ -z "$disk_errs" ]; then
    ok "No disk I/O errors in kernel ring buffer"
else
    warn "Disk errors detected:"
    echo "$disk_errs" | while IFS= read -r l; do
        echo -e "        ${YELLOW}$l${NC}"
    done
fi

# 4.6 Load
echo -e "\n  ${WGREEN}${BOLD}[4.6] System Load${NC}"
read load_1 load_5 load_15 _ < /proc/loadavg
kv "Load average:" "1m: ${load_1}  5m: ${load_5}  15m: ${load_15}  (${cpu_logical} logical CPUs)"
high=$(awk -v l="$load_1" -v c="$cpu_logical" 'BEGIN{print (l > c*1.5) ? 1 : 0}')
[ "$high" = "1" ] && err "System overloaded! Load ${load_1} > $(awk "BEGIN{printf \"%.1f\", $cpu_logical*1.5}")" \
                  || ok "Load within normal range"

# Top 5 processes
echo -e "\n  ${WGREEN}${BOLD}  Top 5 by CPU:${NC}"
printf "  ${WGREEN}%-10s %-28s %s${NC}\n" "PID" "Process" "CPU%"
echo -e "  ${WGREEN}$(printf '%.0s─' {1..50})${NC}"
ps -eo pid,comm,%cpu --sort=-%cpu --no-headers 2>/dev/null | head -5 | \
while read -r pid comm pcpu; do
    printf "  ${WHITE}%-10s${NC} ${WGREEN}%-28s${NC} ${WGREEN}%s%%${NC}\n" \
      "$pid" "$comm" "$pcpu"
done

# 4.7 Disk space
echo -e "\n  ${WGREEN}${BOLD}[4.7] Root Partition Space${NC}"
if   [ "$root_pct" -gt 85 ]; then
    err "CRITICAL: root is ${root_pct}% full (${root_used}/${root_size})"
    inf "Clean: sudo apt autoremove && sudo apt autoclean"
elif [ "$root_pct" -gt 70 ]; then
    warn "Root usage elevated: ${root_pct}% (${root_avail} free)"
else
    ok "Root healthy: ${root_pct}% used — ${root_avail} free"
fi

# 4.8 Swap
echo -e "\n  ${WGREEN}${BOLD}[4.8] Swap / Virtual Memory${NC}"
if [ "$swap_used_kb" -gt 524288 ]; then
    warn "High swap usage: ${swap_used_h} — RAM pressure detected"
else
    ok "Swap nominal: ${swap_used_h} / ${swap_total_h}"
fi

# ══════════════════════════════════════════════════════
# 5. HARDWARE HEALTH
# ══════════════════════════════════════════════════════
hdr "HARDWARE HEALTH CHECK"

# 5.1 Thermals
echo -e "\n  ${WGREEN}${BOLD}[5.1] Thermal Status${NC}"
thermal_found=false
for zone in /sys/class/thermal/thermal_zone*/; do
    temp_raw=$(cat "${zone}temp" 2>/dev/null)
    zone_type=$(cat "${zone}type" 2>/dev/null)
    [ -z "$temp_raw" ] || [ "$temp_raw" -le 0 ] 2>/dev/null && continue
    temp_c=$(( temp_raw / 1000 ))
    thermal_found=true
    if   [ "$temp_c" -gt 90 ]; then err "🔥 ${zone_type}: ${temp_c}°C — CRITICAL"
    elif [ "$temp_c" -gt 75 ]; then warn "🌡 ${zone_type}: ${temp_c}°C — High"
    else                             ok  "🌡 ${zone_type}: ${temp_c}°C"
    fi
done
$thermal_found || inf "No thermal sysfs data available"

if command -v sensors &>/dev/null; then
    echo -e "\n  ${WGREEN}${BOLD}  lm-sensors:${NC}"
    sensors 2>/dev/null | grep -E '°C|RPM' | grep -v '0\.0°C' | \
    while IFS= read -r l; do echo -e "  ${DKGRAY}  $l${NC}"; done
fi

# 5.2 Battery
echo -e "\n  ${WGREEN}${BOLD}[5.2] Battery${NC}"
bat_found=false
for bat_path in /sys/class/power_supply/BAT*; do
    [ -d "$bat_path" ] || continue
    bat_found=true
    bat_name=$(basename "$bat_path")
    bat_status=$(cat "$bat_path/status"   2>/dev/null || echo "Unknown")
    bat_pct=$(cat    "$bat_path/capacity" 2>/dev/null || echo "?")
    bat_manuf=$(cat  "$bat_path/manufacturer"  2>/dev/null || echo "N/A")
    bat_model=$(cat  "$bat_path/model_name"    2>/dev/null || echo "N/A")
    bat_tech=$(cat   "$bat_path/technology"    2>/dev/null || echo "N/A")
    bat_cycle=$(cat  "$bat_path/cycle_count"   2>/dev/null || echo "N/A")
    bat_vuv=$(cat    "$bat_path/voltage_now"   2>/dev/null || echo "")

    kv "Battery (${bat_name}):" "${bat_status} — ${bat_pct}%"
    kv "Manufacturer:"          "${bat_manuf} (${bat_model})"
    kv "Technology:"            "$bat_tech"
    kv "Cycle Count:"           "$bat_cycle"
    if [ -n "$bat_vuv" ] && [ "$bat_vuv" -gt 0 ] 2>/dev/null; then
        bat_v=$(awk -v v="$bat_vuv" 'BEGIN{printf "%.2f", v/1000000}')
        kv "Voltage:"           "${bat_v} V"
    fi

    ef=$(cat "$bat_path/energy_full"        2>/dev/null || \
         cat "$bat_path/charge_full"        2>/dev/null || echo "")
    ed=$(cat "$bat_path/energy_full_design" 2>/dev/null || \
         cat "$bat_path/charge_full_design" 2>/dev/null || echo "")
    if [ -n "$ef" ] && [ -n "$ed" ] && [ "$ed" -gt 0 ] 2>/dev/null; then
        health=$(( ef * 100 / ed ))
        kv "Cell Health:"      "${health}% of design"
        if   [ "$health" -lt 60 ]; then err "Severely degraded — replacement recommended"
        elif [ "$health" -lt 80 ]; then warn "Wear detected: ${health}% capacity"
        else                            ok  "Health satisfactory: ${health}%"
        fi
    fi
done
$bat_found || inf "No battery — desktop / AC-only system"

# 5.3 Power management
echo -e "\n  ${WGREEN}${BOLD}[5.3] Power Management${NC}"
if command -v tlp &>/dev/null && systemctl is-active --quiet tlp 2>/dev/null; then
    profile=$(tlp-stat -s 2>/dev/null | awk -F'= ' '/TLP profile/{print $2; exit}')
    ok "TLP active${profile:+ — profile: ${profile}}"
elif systemctl is-active --quiet power-profiles-daemon 2>/dev/null; then
    pp=$(powerprofilesctl get 2>/dev/null || echo "unknown")
    ok "power-profiles-daemon active — ${pp}"
else
    inf "No active power manager (TLP not running)"
    inf "Enable: sudo systemctl enable --now tlp"
fi

# 5.4 ECC
echo -e "\n  ${WGREEN}${BOLD}[5.4] Memory ECC Errors${NC}"
if [ -d /sys/devices/system/edac ]; then
    ce=$(cat /sys/devices/system/edac/mc/mc*/ce_count 2>/dev/null \
         | paste -sd+ | bc 2>/dev/null || echo 0)
    ue=$(cat /sys/devices/system/edac/mc/mc*/ue_count 2>/dev/null \
         | paste -sd+ | bc 2>/dev/null || echo 0)
    if [ "$ce" -gt 0 ] || [ "$ue" -gt 0 ] 2>/dev/null; then
        warn "ECC: ${ce} corrected, ${ue} uncorrected"
    else
        ok "No ECC errors"
    fi
else
    inf "EDAC not available (no ECC hardware or not exposed)"
fi

# 5.5 SMART
echo -e "\n  ${WGREEN}${BOLD}[5.5] Disk SMART Health${NC}"
if command -v smartctl &>/dev/null; then
    found_any=false
    for disk in /dev/sd? /dev/nvme?n1 /dev/hd?; do
        [ -b "$disk" ] || continue
        found_any=true
        res=$(smartctl -H "$disk" 2>/dev/null | grep -E "overall-health|result")
        realloc=$(smartctl -A "$disk" 2>/dev/null \
          | awk '/Reallocated_Sector_Ct/{print $10}')
        pending=$(smartctl -A "$disk" 2>/dev/null \
          | awk '/Current_Pending_Sector/{print $10}')
        if echo "$res" | grep -qi "PASSED\|OK"; then
            ok "${disk} — SMART PASSED"
        elif echo "$res" | grep -qi "FAILED"; then
            err "${disk} — SMART FAILED — imminent failure!"
        else
            inf "${disk} — ${res:-no SMART data}"
        fi
        [ -n "$realloc" ] && [ "$realloc" -gt 0 ] 2>/dev/null && \
            warn "${disk}: ${realloc} reallocated sectors"
        [ -n "$pending" ] && [ "$pending" -gt 0 ] 2>/dev/null && \
            warn "${disk}: ${pending} pending sectors"
    done
    $found_any || inf "No physical disks found for SMART"
else
    inf "smartmontools not installed: sudo apt install smartmontools"
fi

# 5.6 CPU steal
echo -e "\n  ${WGREEN}${BOLD}[5.6] CPU Steal & IRQ${NC}"
steal=$(top -bn1 2>/dev/null | awk '/^%Cpu/{print $16}' | tr -d ',')
[ -z "$steal" ] && steal="0.0"
if awk -v s="${steal:-0}" 'BEGIN{exit !(s+0 > 5)}'; then
    warn "CPU steal: ${steal}% — hypervisor overhead"
else
    ok "CPU steal: ${steal}% — clean"
fi
irqs=$(awk 'END{print NR-1}' /proc/interrupts 2>/dev/null)
inf "Active interrupt lines: ${irqs}"

# ══════════════════════════════════════════════════════
# FOOTER
# ══════════════════════════════════════════════════════
echo ""
printf "${WGREEN}╔══════════════════════════════════════════════════════════════════════════════════╗\n${NC}"
printf "${WGREEN}║${NC}  ${WGREEN}${BOLD}✔  KALI DIAGNOSTIC COMPLETE${NC}  ${DKGRAY}%s${NC}%*s${WGREEN}${NC}\n" \
  "$(date '+%Y-%m-%d %H:%M:%S %Z')" $((80 - 30 - $(date '+%Y-%m-%d %H:%M:%S %Z' | wc -c))) ""
printf "${WGREEN}╚══════════════════════════════════════════════════════════════════════════════════╝\n${NC}"
echo ""
