# 📋 Log Analysis — Cheatsheet LKS Jawa Barat

## 🗂️ Jenis-Jenis Log Penting

| Log File | Lokasi (Linux) | Isi |
|----------|---------------|-----|
| **auth.log** | `/var/log/auth.log` | Login attempts, sudo, SSH |
| **syslog** | `/var/log/syslog` | System events umum |
| **access.log** | `/var/log/apache2/access.log` | HTTP requests web server |
| **error.log** | `/var/log/apache2/error.log` | Error web server |
| **kern.log** | `/var/log/kern.log` | Kernel messages |
| **wtmp/utmp** | `/var/log/wtmp` | Login history |
| **lastlog** | `/var/log/lastlog` | Last login tiap user |
| **btmp** | `/var/log/btmp` | Failed login attempts |

---

## 🔑 Format Log Penting

### Apache Access Log Format
```
IP - USER [TIMESTAMP] "METHOD /path HTTP/ver" STATUS SIZE "REFERRER" "USER-AGENT"
192.168.1.1 - - [10/Jun/2024:13:55:36 +0700] "GET /login.php HTTP/1.1" 200 1234
```

### Auth Log Format
```
Jun 10 13:55:36 hostname sshd[1234]: Accepted password for user from 192.168.1.1 port 22 ssh2
Jun 10 13:55:40 hostname sshd[1234]: Failed password for root from 10.0.0.1 port 4444 ssh2
```

### Syslog Format
```
TIMESTAMP HOSTNAME PROCESS[PID]: MESSAGE
Jun 10 13:55:36 debian-server cron[1234]: (root) CMD (/usr/bin/python3 /tmp/evil.py)
```

---

## 🔎 Grep Commands — Wajib Hafal

### Auth Log Analysis
```bash
# Semua failed login
grep "Failed password" /var/log/auth.log

# Failed login per IP (sort terbanyak)
grep "Failed password" /var/log/auth.log | grep -oP '(\d+\.){3}\d+' | sort | uniq -c | sort -rn

# Successful login
grep "Accepted password\|Accepted publickey" /var/log/auth.log

# Brute force detection (lebih dari 10 failed dari 1 IP)
grep "Failed password" /var/log/auth.log | awk '{print $11}' | sort | uniq -c | sort -rn | awk '$1 > 10'

# Root login attempts
grep "Failed password for root" /var/log/auth.log

# Invalid user
grep "Invalid user" /var/log/auth.log

# New user created
grep "useradd\|adduser" /var/log/auth.log

# Sudo usage
grep "sudo" /var/log/auth.log
```

### Apache Access Log Analysis
```bash
# Semua request ke file tertentu
grep "login.php" /var/log/apache2/access.log

# HTTP 404 errors
grep " 404 " /var/log/apache2/access.log

# HTTP 500 errors (server error)
grep " 500 " /var/log/apache2/access.log

# Top IP addresses
awk '{print $1}' /var/log/apache2/access.log | sort | uniq -c | sort -rn | head -20

# Top requested URLs
awk '{print $7}' /var/log/apache2/access.log | sort | uniq -c | sort -rn | head -20

# SQL Injection detection
grep -i "union\|select\|insert\|drop\|--\|'or'1'='1" /var/log/apache2/access.log

# XSS detection
grep -i "script\|<script\|alert(" /var/log/apache2/access.log

# Directory traversal
grep "\.\./\|\.\.%2F\|%2e%2e" /var/log/apache2/access.log

# Request dalam rentang waktu tertentu
awk -F'[' '$2 ~ /10\/Jun\/2024:13/' /var/log/apache2/access.log
```

### Syslog Analysis
```bash
# Cron jobs mencurigakan
grep "CRON\|cron" /var/log/syslog

# Service restart
grep "restart\|start\|stop" /var/log/syslog

# Error messages
grep -i "error\|fail\|critical" /var/log/syslog

# Kernel messages
dmesg | grep -i "error\|fail"
```

---

## 🕵️ Investigasi Pola Serangan

### Brute Force SSH
```bash
# Step 1: Identifikasi IP penyerang
grep "Failed password" /var/log/auth.log | grep -oP '(\d+\.){3}\d+' | sort | uniq -c | sort -rn

# Step 2: Cek apakah berhasil login
grep "Accepted" /var/log/auth.log | grep "IP_TERSANGKA"

# Step 3: Cek aktivitas setelah login
grep "IP_TERSANGKA\|USER_TERSANGKA" /var/log/auth.log
```

### Web Shell Upload
```bash
# File PHP diakses dari luar
grep "\.php" /var/log/apache2/access.log | grep "POST"

# Response 200 untuk file di upload folder
grep "/upload\|/uploads\|/tmp" /var/log/apache2/access.log | grep " 200 "

# User-agent mencurigakan
grep -v "Mozilla\|Chrome\|Safari" /var/log/apache2/access.log
```

---

## 📊 Analisis dengan Tools

### last & lastb
```bash
last              # Login history dari /var/log/wtmp
last -n 20        # 20 login terakhir
lastb             # Failed login dari /var/log/btmp
lastlog           # Last login semua user
who               # User yang sedang login
w                 # Detail user yang sedang login
```

### journalctl (systemd)
```bash
journalctl -u ssh           # Log service SSH
journalctl --since "2024-06-10 13:00:00"
journalctl --until "2024-06-10 14:00:00"
journalctl -p err           # Hanya error
journalctl -f               # Follow/realtime
```

### Log Parsing dengan AWK
```bash
# Hitung request per jam
awk -F'[' '{print $2}' access.log | cut -d: -f2 | sort | uniq -c

# Hitung total bytes transferred per IP
awk '{sum[$1]+=$10} END {for(ip in sum) print sum[ip], ip}' access.log | sort -rn

# Status code distribution
awk '{print $9}' access.log | sort | uniq -c | sort -rn
```

---

## 🚩 Red Flags dalam Log

| Tanda | Kemungkinan |
|-------|-------------|
| Ratusan Failed password dalam 1 menit | Brute force |
| Login berhasil setelah banyak failed | Brute force sukses |
| Login dari IP/negara asing | Unauthorized access |
| Akses ke `/etc/passwd`, `/etc/shadow` | Privilege escalation |
| POST ke file .php di folder upload | Web shell |
| Perintah `wget/curl` di syslog | Download malware |
| Cron job ke `/tmp` atau `/dev/shm` | Persistence malware |
| `useradd` tanpa alasan jelas | Backdoor user |

---

## 📝 Template Laporan Log Analysis

```
=== LOG ANALYSIS REPORT ===
Tanggal Analisis : [DATE]
Log File         : [FILE PATH]
Rentang Waktu    : [START] - [END]

1. TEMUAN UTAMA:
   - [Temuan 1]
   - [Temuan 2]

2. IP MENCURIGAKAN:
   - [IP]: [Jumlah attempt], [Status]

3. TIMELINE SERANGAN:
   [TIMESTAMP] - [EVENT]

4. KESIMPULAN:
   [Jenis serangan dan dampak]
```

---

*Digital Forensics Cheatsheet | LKS Jawa Barat*
