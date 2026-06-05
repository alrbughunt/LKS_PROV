# 🖥️ OS Forensics — Cheatsheet LKS Jawa Barat

## 📖 Konsep Dasar

**OS Forensics** = Investigasi artifacts yang ditinggalkan oleh sistem operasi: file sistem, registry, log, prefetch, history, dll.

---

## 🐧 LINUX FORENSICS

### Lokasi File Kritis

| Path | Isi |
|------|-----|
| `/etc/passwd` | Daftar user (username:x:uid:gid:comment:home:shell) |
| `/etc/shadow` | Password hash user |
| `/etc/group` | Daftar grup |
| `/etc/sudoers` | Konfigurasi sudo |
| `/etc/hosts` | Host mapping |
| `/etc/crontab` | System cron jobs |
| `/var/spool/cron/` | User cron jobs |
| `/tmp/` | File sementara (sering dipakai malware!) |
| `/dev/shm/` | Shared memory (volatil, malware suka di sini) |
| `~/.bash_history` | Command history user |
| `~/.ssh/authorized_keys` | SSH public keys |
| `~/.ssh/known_hosts` | Hosts yang pernah dikoneksi |

### Commands Investigasi Linux

#### User & Session
```bash
# Siapa yang pernah login
last -F                           # Login history detail
lastb -F                          # Failed login
who                               # Yang sedang online
w                                 # Detail session aktif
id <username>                     # Info user

# Cek semua user dengan shell
grep -v "nologin\|false" /etc/passwd

# User dengan UID 0 (root-equivalent!)
awk -F: '$3==0{print $1}' /etc/passwd

# Cek sudo access
cat /etc/sudoers
getent group sudo
```

#### Proses & Koneksi
```bash
# Proses berjalan
ps aux                            # Semua proses
ps aux | grep -v "$(whoami)"      # Proses user lain
pstree -aup                       # Process tree

# Koneksi jaringan
netstat -antp                     # All connections + PID
ss -antp                          # Modern netstat
lsof -i                           # Open network connections
lsof -i :22                       # Pada port tertentu

# Proses dengan network
ss -ntp | awk 'NR>1{print $5}' | cut -d: -f1 | sort -u
```

#### Cron & Persistence
```bash
# System cron
cat /etc/crontab
ls /etc/cron.d/
ls /etc/cron.hourly/
ls /etc/cron.daily/

# User cron
crontab -l                        # Cron user ini
crontab -l -u username            # Cron user tertentu

# Systemd services (persistence)
systemctl list-units --type=service --all
ls /etc/systemd/system/
ls /lib/systemd/system/

# Init scripts
ls /etc/init.d/
ls /etc/rc.local
```

#### File Suspect
```bash
# File SUID/SGID (privilege escalation!)
find / -perm -4000 -type f 2>/dev/null    # SUID
find / -perm -2000 -type f 2>/dev/null    # SGID
find / -perm -4000 -o -perm -2000 2>/dev/null

# File world-writable
find / -perm -002 -type f 2>/dev/null

# File baru-baru ini dimodifikasi (24 jam terakhir)
find / -mtime -1 -type f 2>/dev/null
find /tmp /var/tmp /dev/shm -type f 2>/dev/null

# Hidden files
find / -name ".*" -type f 2>/dev/null | grep -v "proc\|sys"

# File executable di /tmp (mencurigakan!)
find /tmp /var/tmp /dev/shm -type f -executable 2>/dev/null

# File besar
find / -size +10M -type f 2>/dev/null
```

#### Command History
```bash
# Bash history
cat ~/.bash_history
cat /home/*/.bash_history 2>/dev/null
cat /root/.bash_history

# Zsh history
cat ~/.zsh_history

# History dengan timestamp
HISTTIMEFORMAT="%F %T " history
```

#### Jaringan & Firewall
```bash
# Interface dan IP
ip addr show
ifconfig -a

# Routing table
ip route show
route -n

# ARP cache
arp -a
ip neigh

# Firewall rules
iptables -L -n -v
iptables-save

# DNS
cat /etc/resolv.conf
```

---

## 🪟 WINDOWS FORENSICS

### Lokasi Artifacts Penting

| Path | Isi |
|------|-----|
| `C:\Windows\System32\winevt\Logs\` | Event logs (.evtx) |
| `C:\Windows\Prefetch\` | Prefetch files (.pf) |
| `C:\Windows\System32\config\` | Registry hives |
| `C:\Users\*\NTUSER.DAT` | User registry |
| `C:\Users\*\AppData\Roaming\Microsoft\Windows\Recent\` | Recent files |
| `C:\Users\*\AppData\Local\Temp\` | Temp files |
| `C:\Users\*\Desktop\` | Desktop |
| `C:\$Recycle.Bin\` | Recycle bin |
| `C:\Windows\Tasks\` | Scheduled tasks |
| `C:\Windows\System32\drivers\etc\hosts` | Hosts file |
| `C:\pagefile.sys` | Page file (memory swap) |
| `C:\hiberfil.sys` | Hibernation file |
| `C:\$MFT` | NTFS Master File Table |

---

### Registry Forensics

#### Hive Utama
| Hive | Mount Point | File |
|------|-------------|------|
| HKLM\SYSTEM | System config | `config\SYSTEM` |
| HKLM\SOFTWARE | Installed software | `config\SOFTWARE` |
| HKLM\SAM | Local accounts | `config\SAM` |
| HKLM\SECURITY | Security policy | `config\SECURITY` |
| HKCU | Current user | `NTUSER.DAT` |
| HKCU\...\UsrClass | Shell classes | `UsrClass.dat` |

#### Key Registry Forensik Penting

```
# Autorun / Persistence
HKLM\Software\Microsoft\Windows\CurrentVersion\Run
HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce
HKCU\Software\Microsoft\Windows\CurrentVersion\Run
HKLM\System\CurrentControlSet\Services

# MRU (Most Recently Used)
HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs
HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU
HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths

# Network shares & mapped drives
HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2

# Installed programs
HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall

# USB devices (penting untuk investigasi!)
HKLM\System\CurrentControlSet\Enum\USBSTOR
HKLM\System\CurrentControlSet\Enum\USB

# Timezone
HKLM\System\CurrentControlSet\Control\TimeZoneInformation

# Computer name
HKLM\System\CurrentControlSet\Control\ComputerName

# Last shutdown time
HKLM\System\CurrentControlSet\Control\Windows → ShutdownTime

# User Account Last Login
HKLM\SAM\SAM\Domains\Account\Users\Names\
```

#### Tools Registry Analysis
```bash
# regripper (Linux)
regripper -r NTUSER.DAT -f ntuser > ntuser_output.txt
regripper -r SAM -p samparse
regripper -r SOFTWARE -p appcompatcache
regripper -l    # List semua plugins

# reglookup
reglookup NTUSER.DAT | grep -i "run\|autorun"

# Registry Explorer / RECmd (Windows)
# Autopsy (GUI, cross-platform)
```

---

### Windows Event Logs (.evtx)

#### Event ID Penting

| Event ID | Log | Kejadian |
|----------|-----|----------|
| **4624** | Security | Successful logon |
| **4625** | Security | Failed logon |
| **4634** | Security | Logon session ended |
| **4648** | Security | Logon using explicit credentials |
| **4672** | Security | Special privilege assigned (admin) |
| **4688** | Security | Process created |
| **4689** | Security | Process exited |
| **4698** | Security | Scheduled task created |
| **4720** | Security | User account created |
| **4726** | Security | User account deleted |
| **4732** | Security | User added to privileged group |
| **4771** | Security | Kerberos pre-auth failed |
| **7034** | System | Service crashed |
| **7036** | System | Service started/stopped |
| **7045** | System | New service installed |
| **1102** | Security | Audit log cleared! |
| **4104** | PowerShell | Script block logging |

#### Analisis EVTX di Linux
```bash
# Install evtx parser
pip3 install python-evtx

# Parse dengan python-evtx
evtx_dump.py Security.evtx > security_events.txt

# Install chainsaw untuk cepat
./chainsaw hunt EVTX/ --sigma sigma/ --mapping mappings/sigma-event-logs-all.yml

# logparser (Windows CLI)
logparser "SELECT TimeGenerated, EventID, Message FROM Security.evtx WHERE EventID=4625"
```

---

### Prefetch Files

```bash
# Lokasi: C:\Windows\Prefetch\*.pf
# Berisi: nama executable, kapan terakhir dijalankan, berapa kali

# Parse dengan PECmd (Windows)
PECmd.exe -d C:\Windows\Prefetch\ --csv output.csv

# Atau dengan python
pip3 install prefetch-parser
prefetch-parser CALC.EXE-XXXXXXXX.pf
```

---

### LNK Files (Shortcut)

```bash
# Lokasi:
# C:\Users\*\AppData\Roaming\Microsoft\Windows\Recent\

# Parse LNK files
pip3 install lnkfile
python3 -c "import lnkfile; l=lnkfile.load(open('file.lnk','rb')); print(l.local_path)"

# lnkparse
pip3 install lnkparse3
lnkparse file.lnk
```

---

### Browser Forensics

```bash
# Chrome History (SQLite)
# C:\Users\*\AppData\Local\Google\Chrome\User Data\Default\History
sqlite3 History "SELECT url, title, visit_count, last_visit_time FROM urls ORDER BY last_visit_time DESC LIMIT 50;"

# Firefox (SQLite)
# C:\Users\*\AppData\Roaming\Mozilla\Firefox\Profiles\*.default\places.sqlite
sqlite3 places.sqlite "SELECT url, title, visit_count FROM moz_places ORDER BY last_visit_date DESC LIMIT 50;"

# SQLite browser
sudo apt install sqlitebrowser
```

---

## 🔄 Workflow OS Forensics

### Linux
```
1. Cek user aktif dan history
   ├── who, w, last
   └── cat ~/.bash_history

2. Cek proses mencurigakan
   ├── ps aux | sort -rk 3 (CPU usage)
   └── netstat -antp (koneksi aktif)

3. Cek persistence
   ├── crontab -l (tiap user)
   ├── ls /etc/cron.d/ /etc/cron.daily/
   └── systemctl list-units

4. Cari file mencurigakan
   ├── find /tmp /var/tmp -type f -executable
   ├── find / -perm -4000 (SUID)
   └── find / -mtime -1 (modified recently)

5. Analisis log
   └── Lihat modul Log Analysis
```

### Windows
```
1. Event Log Analysis
   ├── Security.evtx → login/logon events
   ├── System.evtx → service events
   └── PowerShell/Operational → PS commands

2. Registry Analysis
   ├── Run keys (autorun)
   ├── USB history
   └── MRU lists

3. Prefetch & Timeline
   ├── Prefetch → apa yang dijalankan
   └── MFT timeline → kapan file diakses/dimodifikasi

4. Browser & User Activity
   ├── Browser history
   └── Recent documents
```

---

*Digital Forensics Cheatsheet | LKS Jawa Barat*
