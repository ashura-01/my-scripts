# Nmap & RustScan Ultimate Cheat Sheet

## Firewall & IDS/IPS Evasion Edition

---

## Table of Contents

- [Nmap Host Discovery](#nmap-host-discovery)
- [Nmap Scan Types](#nmap-scan-types)
- [Nmap Firewall Evasion](#nmap-firewall-evasion)
- [Nmap IDS/IPS Evasion](#nmap-idsips-evasion)
- [Nmap Decoy & Spoofing](#nmap-decoy--spoofing)
- [Nmap DNS Techniques](#nmap-dns-techniques)
- [Nmap Fragmentation](#nmap-fragmentation)
- [Nmap Timing & Performance](#nmap-timing--performance)
- [Nmap Output & Logging](#nmap-output--logging)
- [Nmap Advanced Evasion](#nmap-advanced-evasion)
- [RustScan Basic Scans](#rustscan-basic-scans)
- [RustScan Evasion Techniques](#rustscan-evasion-techniques)
- [RustScan Advanced Options](#rustscan-advanced-options)
- [Nmap + RustScan Combined](#nmap--rustscan-combined)
- [Quick Reference](#quick-reference)

---

## Nmap Host Discovery

### Skip Host Discovery
```bash
nmap -Pn <target>
```
Reason: Assumes host is up, bypasses ICMP blocking

### Skip Host Discovery + No DNS
```bash
nmap -Pn -n <target>
```
Reason: Faster scanning, avoids DNS leaks

### Skip ARP Ping
```bash
nmap -Pn -n --disable-arp-ping <target>
```
Reason: Avoids local network detection

### SYN Ping
```bash
nmap -PS22,80,443 <target>
```
Reason: SYN ping on common ports

### ACK Ping
```bash
nmap -PA22,80,443 <target>
```
Reason: ACK ping bypasses SYN filters

### UDP Ping (DNS)
```bash
nmap -PU53 <target>
```
Reason: Uses DNS port for discovery

### ICMP Echo Ping
```bash
nmap -PE <target>
```
Reason: Standard ICMP ping

### ICMP Timestamp Ping
```bash
nmap -PP <target>
```
Reason: Alternative ICMP ping method

### ICMP Netmask Ping
```bash
nmap -PM <target>
```
Reason: Alternative ICMP ping method

### ARP Ping (Local)
```bash
nmap -PR <target>
```
Reason: ARP is faster and more reliable locally

---

## Nmap Scan Types

### SYN Stealth Scan
```bash
nmap -sS <target>
```
Reason: Half-open, less likely to be logged

### TCP Connect Scan
```bash
nmap -sT <target>
```
Reason: Full handshake, use when no raw socket

### ACK Scan
```bash
nmap -sA <target>
```
Reason: Determines filtered vs unfiltered ports

### Window Scan
```bash
nmap -sW <target>
```
Reason: Uses TCP window size to determine state

### Maimon Scan
```bash
nmap -sM <target>
```
Reason: FIN/ACK flags, bypasses some firewalls

### NULL Scan
```bash
nmap -sN <target>
```
Reason: No flags set, evades stateless firewalls

### FIN Scan
```bash
nmap -sF <target>
```
Reason: FIN flag only, evades stateless firewalls

### XMAS Scan
```bash
nmap -sX <target>
```
Reason: FIN/URG/PSH flags, evades stateless firewalls

### UDP Scan
```bash
nmap -sU <target>
```
Reason: Scans UDP services

### Idle Scan
```bash
nmap -sI <zombie> <target>
```
Reason: Uses zombie host, completely stealthy

### IP Protocol Scan
```bash
nmap -sO <target>
```
Reason: Scans IP protocols

### Version Detection
```bash
nmap -sV <target>
```
Reason: Identifies service versions

### OS Detection
```bash
nmap -O <target>
```
Reason: Identifies operating system

### Default Script Scan
```bash
nmap -sC <target>
```
Reason: Runs default scripts for enumeration

---

## Nmap Firewall Evasion

### ACK Scan Bypass
```bash
nmap -sA <target>
```
Reason: Firewalls often pass ACK packets

### ACK Scan Specific Port
```bash
nmap -sA -p 80 <target>
```
Reason: Check if specific port is filtered

### Source Port DNS
```bash
nmap --source-port 53 <target>
```
Reason: DNS port often trusted

### Source Port HTTP
```bash
nmap --source-port 80 <target>
```
Reason: HTTP port often trusted

### Source Port HTTPS
```bash
nmap --source-port 443 <target>
```
Reason: HTTPS port often trusted

### Source Port FTP Data
```bash
nmap --source-port 20 <target>
```
Reason: FTP data port often trusted

### Short Source Port
```bash
nmap -g 53 <target>
```
Reason: Short version of --source-port

### SYN from DNS Port
```bash
nmap -sS -p 80 --source-port 53 <target>
```
Reason: SYN scan from trusted DNS port

### ACK from DNS Port
```bash
nmap -sA -p 80 --source-port 53 <target>
```
Reason: ACK scan from trusted DNS port

### Fragment Packets
```bash
nmap -f <target>
```
Reason: Splits packets into 8-byte fragments

### Double Fragmentation
```bash
nmap -f -f <target>
```
Reason: 16-byte fragments, harder to detect

### Custom MTU
```bash
nmap --mtu 24 <target>
```
Reason: Set custom MTU size

### Small MTU
```bash
nmap --mtu 16 <target>
```
Reason: Very small fragments

### Invalid Checksum
```bash
nmap --badsum <target>
```
Reason: Some firewalls ignore invalid checksums

### Connect Scan Fallback
```bash
nmap -sT -p 80 <target>
```
Reason: Use if SYN scans are blocked

### Window Scan Bypass
```bash
nmap -sW -p 80 <target>
```
Reason: Bypasses stateful firewalls

---

## Nmap IDS/IPS Evasion

### Paranoid Timing
```bash
nmap -T0 <target>
```
Reason: Serial, 5-minute wait between probes

### Sneaky Timing
```bash
nmap -T1 <target>
```
Reason: Serial, 15-second wait between probes

### Polite Timing
```bash
nmap -T2 <target>
```
Reason: Reduces network impact

### Scan Delay
```bash
nmap --scan-delay 10s <target>
```
Reason: 10-second delay between probes

### Custom Scan Delay
```bash
nmap --scan-delay 5s <target>
```
Reason: 5-second delay between probes

### Max Rate Limit
```bash
nmap --max-rate 10 <target>
```
Reason: Maximum 10 packets per second

### Min Rate
```bash
nmap --min-rate 1 --max-rate 10 <target>
```
Reason: Slow but steady scanning

### Host Timeout
```bash
nmap --host-timeout 30s <target>
```
Reason: Skip slow hosts after 30 seconds

### Max Retries
```bash
nmap --max-retries 0 <target>
```
Reason: No retries, reduces noise

### Randomize Hosts
```bash
nmap --randomize-hosts <target>
```
Reason: Randomizes scan order

### Spoof MAC
```bash
nmap --spoof-mac Cisco <target>
```
Reason: Pretend to be Cisco device

### Spoof MAC Vendor
```bash
nmap --spoof-mac 00:11:22:33:44:55 <target>
```
Reason: Specific MAC address spoof

### Data Length Padding
```bash
nmap --data-length 200 <target>
```
Reason: Adds random data to packets

---

## Nmap Decoy & Spoofing

### Random Decoys
```bash
nmap -D RND:5 <target>
```
Reason: 5 random decoy IPs

### Custom Decoys
```bash
nmap -D 10.0.0.1,10.0.0.2,ME <target>
```
Reason: Specific decoys with real IP

### Decoy with ME
```bash
nmap -D 10.0.0.1,ME,10.0.0.2 <target>
```
Reason: Places real IP in middle

### Source IP Spoof
```bash
nmap -S 10.0.0.100 -e eth0 <target>
```
Reason: Spoofs source IP address

### Spoof with Interface
```bash
nmap -S 10.0.0.100 -e tun0 <target>
```
Reason: Specifies interface for spoofing

### Decoy with ACK Scan
```bash
nmap -D RND:5 -sA <target>
```
Reason: ACK scan with decoys

### Decoy with OS Detection
```bash
nmap -D RND:3 -O <target>
```
Reason: OS detection with decoys

### Decoy with ICMP
```bash
nmap -D RND:5 -PE <target>
```
Reason: ICMP scan with decoys

### Proxy Chain
```bash
nmap --proxies socks4://127.0.0.1:9050 <target>
```
Reason: Routes through Tor proxy

### HTTP Proxy
```bash
nmap --proxies http://127.0.0.1:8080 <target>
```
Reason: Routes through HTTP proxy

---

## Nmap DNS Techniques

### Custom DNS Server
```bash
nmap --dns-server 8.8.8.8 <target>
```
Reason: Use Google DNS

### Multiple DNS Servers
```bash
nmap --dns-server 8.8.8.8,1.1.1.1 <target>
```
Reason: Redundant DNS resolution

### Disable DNS
```bash
nmap -n <target>
```
Reason: Skip DNS resolution

### Reverse DNS
```bash
nmap -R <target>
```
Reason: Force reverse DNS

### DNS Cache
```bash
nmap --dns-cache <target>
```
Reason: Use system DNS cache

### DNS Port 53
```bash
nmap --source-port 53 <target>
```
Reason: Use DNS port for scans

### DNS TTL
```bash
nmap -ttl 64 <target>
```
Reason: Set DNS TTL value

### DNS with Decoys
```bash
nmap -D RND:3 --dns-server 8.8.8.8 <target>
```
Reason: DNS with decoys

### System DNS
```bash
nmap --system-dns <target>
```
Reason: Use system DNS configuration

---

## Nmap Fragmentation

### Basic Fragment
```bash
nmap -f <target>
```
Reason: 8-byte fragments

### Double Fragment
```bash
nmap -ff <target>
```
Reason: 16-byte fragments

### MTU 24
```bash
nmap --mtu 24 <target>
```
Reason: Custom MTU size 24

### MTU 16
```bash
nmap --mtu 16 <target>
```
Reason: Very small fragments

### MTU 32
```bash
nmap --mtu 32 <target>
```
Reason: Medium fragmentation

### MTU 48
```bash
nmap --mtu 48 <target>
```
Reason: Alternative fragment size

### Fragment with TCP
```bash
nmap -f -sS <target>
```
Reason: Fragmented SYN scan

### Fragment with UDP
```bash
nmap -f -sU <target>
```
Reason: Fragmented UDP scan

### Fragment with ACK
```bash
nmap -f -sA <target>
```
Reason: Fragmented ACK scan

### Fragment with MTU
```bash
nmap --mtu 24 -sS <target>
```
Reason: Custom MTU with SYN scan

---

## Nmap Timing & Performance

### Insane Timing
```bash
nmap -T5 <target>
```
Reason: Maximum speed, high noise

### Aggressive Timing
```bash
nmap -T4 <target>
```
Reason: Fast scan, moderate noise

### Normal Timing
```bash
nmap -T3 <target>
```
Reason: Default balanced scan

### Polite Timing
```bash
nmap -T2 <target>
```
Reason: Slower, less intrusive

### Sneaky Timing
```bash
nmap -T1 <target>
```
Reason: Very slow, stealthy

### Paranoid Timing
```bash
nmap -T0 <target>
```
Reason: Extremely slow, maximum stealth

### Min Host Group
```bash
nmap --min-hostgroup 5 <target>
```
Reason: Minimum 5 hosts per group

### Max Host Group
```bash
nmap --max-hostgroup 10 <target>
```
Reason: Maximum 10 hosts per group

### Min Parallelism
```bash
nmap --min-parallelism 5 <target>
```
Reason: Minimum 5 parallel probes

### Max Parallelism
```bash
nmap --max-parallelism 10 <target>
```
Reason: Maximum 10 parallel probes

### Min Rate
```bash
nmap --min-rate 50 <target>
```
Reason: Minimum 50 packets per second

### Max Rate
```bash
nmap --max-rate 100 <target>
```
Reason: Maximum 100 packets per second

### Initial RTT Timeout
```bash
nmap --initial-rtt-timeout 100ms <target>
```
Reason: Initial RTT timeout

### Max RTT Timeout
```bash
nmap --max-rtt-timeout 300ms <target>
```
Reason: Maximum RTT timeout

### Min RTT Timeout
```bash
nmap --min-rtt-timeout 50ms <target>
```
Reason: Minimum RTT timeout

---

## Nmap Output & Logging

### Normal Output
```bash
nmap -oN scan.nmap <target>
```
Reason: Normal nmap output format

### XML Output
```bash
nmap -oX scan.xml <target>
```
Reason: XML format for tools

### Grepable Output
```bash
nmap -oG scan.gnmap <target>
```
Reason: Grepable format

### All Formats
```bash
nmap -oA scan <target>
```
Reason: All output formats

### Verbose Output
```bash
nmap -v <target>
```
Reason: Verbose progress updates

### Very Verbose
```bash
nmap -vv <target>
```
Reason: More detailed output

### Debug Output
```bash
nmap -d <target>
```
Reason: Debug information

### Packet Trace
```bash
nmap --packet-trace <target>
```
Reason: Shows all sent/received packets

### Reason Output
```bash
nmap --reason <target>
```
Reason: Shows reason for port states

### Statistics
```bash
nmap --stats-every 5s <target>
```
Reason: Periodic scan statistics

### Resume Scan
```bash
nmap --resume scan.nmap <target>
```
Reason: Resume interrupted scan

### Append Output
```bash
nmap -oN scan.nmap --append-output <target>
```
Reason: Append to existing output

### No Style Output
```bash
nmap --no-stylesheet <target>
```
Reason: No XML stylesheet

---

## Nmap Advanced Evasion

### Idle Scan Zombie
```bash
nmap -sI 10.0.0.5 <target>
```
Reason: Uses zombie for completely stealthy scan

### Idle Scan Port
```bash
nmap -sI 10.0.0.5 -p 80 <target>
```
Reason: Idle scan on specific port

### FTP Bounce Scan
```bash
nmap -b ftp://user:pass@10.0.0.5:21 <target>
```
Reason: FTP bounce for stealth

### FTP Bounce Port
```bash
nmap -b ftp://user:pass@10.0.0.5:21 -p 80 <target>
```
Reason: FTP bounce on specific port

### Spoof MAC Random
```bash
nmap --spoof-mac 0 <target>
```
Reason: Random MAC address

### Spoof MAC Apple
```bash
nmap --spoof-mac Apple <target>
```
Reason: Spoof as Apple device

### Spoof MAC Linux
```bash
nmap --spoof-mac Linux <target>
```
Reason: Spoof as Linux device

### Spoof MAC Windows
```bash
nmap --spoof-mac Windows <target>
```
Reason: Spoof as Windows device

### Bad Checksum
```bash
nmap --badsum <target>
```
Reason: Send invalid checksum packets

### Data Padding
```bash
nmap --data-length 100 <target>
```
Reason: Add random padding to packets

### Source Port 20
```bash
nmap --source-port 20 <target>
```
Reason: FTP data port bypass

### Source Port 53
```bash
nmap --source-port 53 <target>
```
Reason: DNS port bypass

### Source Port 123
```bash
nmap --source-port 123 <target>
```
Reason: NTP port bypass

### Source Port 161
```bash
nmap --source-port 161 <target>
```
Reason: SNMP port bypass

### Source Port 514
```bash
nmap --source-port 514 <target>
```
Reason: Syslog port bypass

### TTL Custom
```bash
nmap -ttl 32 <target>
```
Reason: Custom TTL value

### TTL OS Spoof
```bash
nmap -ttl 128 <target>
```
Reason: Spoof TTL as Windows

---

## RustScan Basic Scans

### Default Scan
```bash
rustscan -a 10.0.0.1
```
Reason: Quick default port scan

### Custom Ports
```bash
rustscan -a 10.0.0.1 -p 80,443,8080
```
Reason: Scan specific ports

### Port Range
```bash
rustscan -a 10.0.0.1 -p 1-1000
```
Reason: Scan port range

### Top Ports
```bash
rustscan -a 10.0.0.1 -t 1000
```
Reason: Scan top 1000 ports

### Batch Size
```bash
rustscan -a 10.0.0.1 -b 500
```
Reason: Set batch size for scanning

### Timeout
```bash
rustscan -a 10.0.0.1 -t 1000
```
Reason: Set timeout in milliseconds

### Multiple Targets
```bash
rustscan -a 10.0.0.1,10.0.0.2,10.0.0.3
```
Reason: Scan multiple hosts

### CIDR Range
```bash
rustscan -a 10.0.0.0/24
```
Reason: Scan entire subnet

### Hostname
```bash
rustscan -a example.com
```
Reason: Scan by hostname

### Port File
```bash
rustscan -a 10.0.0.1 -P ports.txt
```
Reason: Use port list from file

### No Nmap
```bash
rustscan -a 10.0.0.1 --no-nmap
```
Reason: Skip automatic Nmap scan

### Greppable
```bash
rustscan -a 10.0.0.1 -g
```
Reason: Grepable output format

### JSON Output
```bash
rustscan -a 10.0.0.1 -o json
```
Reason: JSON output format

---

## RustScan Evasion Techniques

### Slow Scan
```bash
rustscan -a 10.0.0.1 -b 100 -t 5000
```
Reason: Slow down scanning for stealth

### Very Slow
```bash
rustscan -a 10.0.0.1 -b 10 -t 10000
```
Reason: Maximum stealth, very slow

### UDP Scan
```bash
rustscan -a 10.0.0.1 -u
```
Reason: UDP port scanning

### No ARP Ping
```bash
rustscan -a 10.0.0.1 --disable-arp
```
Reason: Skip ARP ping

### No ICMP Ping
```bash
rustscan -a 10.0.0.1 --disable-icmp
```
Reason: Skip ICMP ping

### No Nmap Scripts
```bash
rustscan -a 10.0.0.1 --no-scripts
```
Reason: Skip Nmap scripts

### Aggressive
```bash
rustscan -a 10.0.0.1 -A
```
Reason: Aggressive scanning mode

### Top 1000 Slow
```bash
rustscan -a 10.0.0.1 -t 1000 -b 100
```
Reason: Slow top 1000 scan

### Top 1000 Stealth
```bash
rustscan -a 10.0.0.1 -t 1000 -b 10
```
Reason: Very slow top 1000 scan

### Random Ports
```bash
rustscan -a 10.0.0.1 --random-ports
```
Reason: Randomize port order

### Interface Binding
```bash
rustscan -a 10.0.0.1 -e eth0
```
Reason: Bind to specific interface

### Custom Source Port
```bash
rustscan -a 10.0.0.1 --source-port 53
```
Reason: Use DNS source port

### Custom TTL
```bash
rustscan -a 10.0.0.1 --ttl 64
```
Reason: Set custom TTL

### No DNS
```bash
rustscan -a 10.0.0.1 -n
```
Reason: Disable DNS resolution

### Proxy Support
```bash
rustscan -a 10.0.0.1 -x socks5://127.0.0.1:9050
```
Reason: Route through proxy

---

## RustScan Advanced Options

### Custom Nmap Args
```bash
rustscan -a 10.0.0.1 -- -sV -sC -A
```
Reason: Pass custom Nmap arguments

### Version Detection
```bash
rustscan -a 10.0.0.1 -- -sV
```
Reason: Enable version detection

### OS Detection
```bash
rustscan -a 10.0.0.1 -- -O
```
Reason: Enable OS detection

### Script Scan
```bash
rustscan -a 10.0.0.1 -- -sC
```
Reason: Run default scripts

### Aggressive Nmap
```bash
rustscan -a 10.0.0.1 -- -A
```
Reason: Aggressive Nmap scan

### Custom Nmap Ports
```bash
rustscan -a 10.0.0.1 -p 80 -- -sV
```
Reason: Scan port with version

### T4 Timing
```bash
rustscan -a 10.0.0.1 -- -T4
```
Reason: Faster Nmap scan

### T0 Timing
```bash
rustscan -a 10.0.0.1 -- -T0
```
Reason: Very slow Nmap scan

### Nmap Fragmentation
```bash
rustscan -a 10.0.0.1 -- -f
```
Reason: Fragment packets

### Nmap Decoys
```bash
rustscan -a 10.0.0.1 -- -D RND:5
```
Reason: Use decoys with Nmap

### Nmap Source Port
```bash
rustscan -a 10.0.0.1 -- --source-port 53
```
Reason: Source port manipulation

### Nmap Badsum
```bash
rustscan -a 10.0.0.1 -- --badsum
```
Reason: Send invalid checksum

### Nmap ACK Scan
```bash
rustscan -a 10.0.0.1 -- -sA
```
Reason: ACK scan via Nmap

### Nmap Window Scan
```bash
rustscan -a 10.0.0.1 -- -sW
```
Reason: Window scan via Nmap

### Nmap Idle Scan
```bash
rustscan -a 10.0.0.1 -- -sI 10.0.0.5
```
Reason: Idle scan via Nmap

---

## Nmap + RustScan Combined

### Quick Port Discovery
```bash
rustscan -a 10.0.0.1 -t 1000 | nmap -Pn -sV -p- 10.0.0.1
```
Reason: Fast discovery then detailed scan

### Fast then Full
```bash
rustscan -a 10.0.0.1 -t 1000 -b 500 | nmap -sS -sC -sV -p- 10.0.0.1
```
Reason: Quick scan then thorough scan

### Stealth Combined
```bash
rustscan -a 10.0.0.1 -b 10 -t 10000 | nmap -T1 -sS -sV -p- 10.0.0.1
```
Reason: Maximum stealth both tools

### Aggressive Combined
```bash
rustscan -a 10.0.0.1 -A | nmap -A -p- 10.0.0.1
```
Reason: Aggressive scanning both tools

### Bypass Firewall
```bash
rustscan -a 10.0.0.1 --source-port 53 | nmap --source-port 53 -sS -p- 10.0.0.1
```
Reason: DNS port bypass both tools

### Decoy Combined
```bash
rustscan -a 10.0.0.1 | nmap -D RND:5 -sS -p- 10.0.0.1
```
Reason: Decoys with Nmap after RustScan

### Fragmented Combined
```bash
rustscan -a 10.0.0.1 | nmap -f -sS -p- 10.0.0.1
```
Reason: Fragmented Nmap scan

### Slow Combined
```bash
rustscan -a 10.0.0.1 -b 50 -t 5000 | nmap -T2 -sS -p- 10.0.0.1
```
Reason: Slower, stealthier combined

### CIDR Combined
```bash
rustscan -a 10.0.0.0/24 -t 1000 | nmap -sS -sV 10.0.0.0/24
```
Reason: Scan entire subnet with both

### Port List Combined
```bash
rustscan -a 10.0.0.1 -P ports.txt | nmap -sV -p$(tr '\n' ',' < ports.txt) 10.0.0.1
```
Reason: Port list from file

### JSON Output Combined
```bash
rustscan -a 10.0.0.1 -o json | jq '.ports[].port' | nmap -p$(paste -sd ',') 10.0.0.1
```
Reason: Parse JSON for Nmap ports

### Grepable Combined
```bash
rustscan -a 10.0.0.1 -g | grep "Port" | cut -d'/' -f1 | nmap -p$(paste -sd ',') 10.0.0.1
```
Reason: Parse grepable for Nmap ports

### Interface Combined
```bash
rustscan -a 10.0.0.1 -e eth0 | nmap -e eth0 -sS -p- 10.0.0.1
```
Reason: Use same interface both tools

### Custom Scripts Combined
```bash
rustscan -a 10.0.0.1 | nmap --script=default,vuln -p- 10.0.0.1
```
Reason: Nmap scripts after RustScan

### Network Range
```bash
rustscan -a 10.0.0.0/24 --no-nmap | awk '/open/{print $2}' | nmap -p$(paste -sd ',')
```
Reason: Parse RustScan output for Nmap

---

## Quick Reference

### Essential Nmap Commands

| Command | Use Case |
|---------|----------|
| `nmap -sS <target>` | Stealth SYN scan |
| `nmap -sA <target>` | ACK scan for filtering |
| `nmap -f <target>` | Fragment packets |
| `nmap -D RND:5 <target>` | Use decoys |
| `nmap --source-port 53 <target>` | DNS port bypass |
| `nmap -T0 <target>` | Maximum stealth |
| `nmap -O <target>` | OS detection |
| `nmap -sV <target>` | Version detection |

### Essential RustScan Commands

| Command | Use Case |
|---------|----------|
| `rustscan -a <target>` | Default scan |
| `rustscan -a <target> -p 80,443` | Specific ports |
| `rustscan -a <target> -t 1000` | Top 1000 ports |
| `rustscan -a <target> -b 10` | Slow scan |
| `rustscan -a <target> --source-port 53` | DNS port bypass |
| `rustscan -a <target> -n` | No DNS |
| `rustscan -a <target> -u` | UDP scan |
| `rustscan -a <target> -- -sV` | Custom Nmap args |

### Most Common Evasion Chain

```bash
# Step 1: Quick port discovery with stealth
rustscan -a 10.0.0.1 -b 100 -t 5000 --source-port 53 -n

# Step 2: Detailed Nmap scan on discovered ports
nmap -sS -sV -sC -f -D RND:5 --source-port 53 -T2 -p <ports> 10.0.0.1
```

### Complete Single Command Chain

```bash
rustscan -a 10.0.0.1 -b 100 -t 5000 --source-port 53 -n | grep -E "open" | awk '{print $2}' | cut -d'/' -f1 | tr '\n' ',' | xargs nmap -sS -sV -f -D RND:5 --source-port 53 -T2 -p
```

### Port Bypass Priority

1. `--source-port 53` (DNS)
2. `--source-port 80` (HTTP)
3. `--source-port 443` (HTTPS)
4. `--source-port 20` (FTP Data)
5. `--source-port 123` (NTP)

### Timing Selection Guide

| Timing | Command | When to Use |
|--------|---------|-------------|
| Paranoid | `-T0` | Extreme stealth, IDS/IPS present |
| Sneaky | `-T1` | High stealth, slow network |
| Polite | `-T2` | Moderate stealth, production |
| Normal | `-T3` | Default, balanced |
| Aggressive | `-T4` | Fast scan, trusted network |
| Insane | `-T5` | Maximum speed, no stealth |

### Fragment Size Guide

| Command | Size | Use Case |
|---------|------|----------|
| `-f` | 8 bytes | Basic fragmentation |
| `-ff` | 16 bytes | Stronger fragmentation |
| `--mtu 24` | 24 bytes | Custom fragmentation |
| `--mtu 16` | 16 bytes | Very small fragments |
| `--mtu 32` | 32 bytes | Medium fragmentation |

### Decoy Usage Guide

| Command | Description |
|---------|-------------|
| `-D RND:3` | 3 random decoys |
| `-D RND:5` | 5 random decoys |
| `-D 10.0.0.1,ME` | One custom decoy |
| `-D 10.0.0.1,10.0.0.2,ME` | Two custom decoys |
| `-D 10.0.0.1,10.0.0.2` | No ME, pure decoys |

### Output Format Options

| Format | Command | Use Case |
|--------|---------|----------|
| Normal | `-oN` | Human readable |
| XML | `-oX` | Tools integration |
| Grepable | `-oG` | Grep parsing |
| All | `-oA` | All formats |

---

## Legal Disclaimer

**IMPORTANT**: This cheat sheet is for educational and authorized security testing only. Use these techniques only on systems you own or have explicit written permission to test. Unauthorized network scanning may violate laws and regulations in many jurisdictions. Always obtain proper authorization before conducting any security assessments.
