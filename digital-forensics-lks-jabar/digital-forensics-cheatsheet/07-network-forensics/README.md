# 🌐 Network Forensics (PCAP) — Cheatsheet LKS Jawa Barat

## 📖 Konsep Dasar

**Network Forensics** = Analisis lalu lintas jaringan untuk menemukan bukti kejahatan siber, data exfiltration, serangan, dan komunikasi tersembunyi.

### PCAP = Packet Capture
File PCAP berisi rekaman seluruh paket jaringan termasuk header dan payload.

---

## 🛠️ Tools

| Tool | Fungsi |
|------|--------|
| **Wireshark** | GUI analysis, terlengkap |
| **tshark** | CLI Wireshark |
| **tcpdump** | Capture & basic filter |
| **NetworkMiner** | Otomatis extract files dari PCAP |
| **ngrep** | Grep di network traffic |
| **scapy** | Python network analysis |
| **strings** | Cari text di PCAP |
| **binwalk** | Extract files dari PCAP |

---

## 🦈 Wireshark — Panduan Lengkap

### Buka PCAP
```bash
wireshark capture.pcap &      # GUI
tshark -r capture.pcap        # CLI
```

### Display Filters — WAJIB HAFAL ⭐

```wireshark
# Protocol
http
tcp
udp
dns
ftp
smtp
ssh
telnet
icmp
arp

# IP Address
ip.addr == 192.168.1.1            # Source ATAU destination
ip.src == 192.168.1.1             # Source only
ip.dst == 192.168.1.1             # Destination only
ip.addr == 192.168.1.0/24         # Subnet

# Port
tcp.port == 80
tcp.dstport == 443
tcp.srcport == 4444
udp.port == 53

# Kombinasi
ip.addr == 192.168.1.1 && tcp.port == 80
http || dns
ip.src == 10.0.0.1 && tcp.flags.syn == 1

# HTTP
http.request                      # HTTP requests
http.response                     # HTTP responses
http.request.method == "POST"     # POST requests
http.request.uri contains "login" # URI mengandung login
http.response.code == 200         # HTTP 200 OK
http.response.code == 404         # HTTP 404
http.host == "evil.com"           # Host tertentu

# DNS
dns.qry.name contains "evil"      # DNS query ke domain tertentu
dns.flags.response == 0           # DNS queries only
dns.flags.response == 1           # DNS responses only

# TCP Flags
tcp.flags.syn == 1                # SYN (koneksi baru)
tcp.flags.reset == 1              # RST (reset koneksi)
tcp.flags.syn == 1 && tcp.flags.ack == 0  # SYN scan (port scan)

# FTP
ftp.request.command == "RETR"     # Download
ftp.request.command == "STOR"     # Upload
ftp.response.code == 230          # Login sukses

# Follow Stream
# Klik kanan → Follow → TCP/UDP/HTTP Stream
```

---

## 📟 tshark — CLI Commands

### Basic
```bash
# List interfaces
tshark -D

# Capture live
tshark -i eth0 -w capture.pcap

# Read file
tshark -r capture.pcap

# Read dengan filter
tshark -r capture.pcap -Y "http"
tshark -r capture.pcap -Y "tcp.port == 4444"

# Read fields tertentu
tshark -r capture.pcap -T fields -e ip.src -e ip.dst -e tcp.dstport

# Statistik
tshark -r capture.pcap -q -z io,stat,0            # Traffic stats
tshark -r capture.pcap -q -z conv,tcp             # TCP conversations
tshark -r capture.pcap -q -z endpoints,ip         # IP endpoints
```

### Extract Informasi Spesifik
```bash
# Semua URL HTTP
tshark -r capture.pcap -Y http.request -T fields -e http.host -e http.request.uri

# DNS queries
tshark -r capture.pcap -Y dns -T fields -e dns.qry.name | sort -u

# Credentials FTP
tshark -r capture.pcap -Y ftp -T fields -e ftp.request.command -e ftp.request.arg

# Credentials HTTP Basic Auth
tshark -r capture.pcap -Y "http.authorization" -T fields -e http.authorization

# POST data
tshark -r capture.pcap -Y "http.request.method == POST" -T fields -e http.file_data

# IP conversations
tshark -r capture.pcap -q -z conv,tcp | head -20
```

---

## 🔍 Investigasi Serangan Umum

### Port Scan Detection
```bash
# SYN scan (banyak SYN ke berbagai port)
tshark -r capture.pcap -Y "tcp.flags.syn == 1 && tcp.flags.ack == 0" -T fields -e ip.src -e tcp.dstport | sort | uniq -c | sort -rn

# Wireshark filter:
# tcp.flags.syn==1 && tcp.flags.ack==0
```

### Brute Force HTTP
```bash
# Banyak request ke /login dengan 401/403
tshark -r capture.pcap -Y "http.response.code == 401" -T fields -e ip.src | sort | uniq -c | sort -rn

# Wireshark filter:
# http.response.code == 401
```

### DNS Exfiltration
```bash
# DNS query panjang mencurigakan
tshark -r capture.pcap -Y dns -T fields -e dns.qry.name | awk 'length > 40' | sort -u

# Banyak DNS query ke satu domain
tshark -r capture.pcap -Y dns -T fields -e dns.qry.name | grep -oP '[^.]+\.[^.]+$' | sort | uniq -c | sort -rn
```

### Data Exfiltration via HTTP
```bash
# Upload besar (POST dengan data besar)
tshark -r capture.pcap -Y "http.request.method == POST" -T fields -e ip.src -e http.host -e http.content_length

# Filter: http.request.method == "POST" && http.content_length > 1000
```

---

## 📁 Extract Files dari PCAP

### Wireshark GUI
```
File → Export Objects → HTTP (atau IMF, SMB, TFTP, dll)
```

### tshark
```bash
# Export HTTP objects
tshark -r capture.pcap --export-objects http,./extracted_files/

# Export SMB files
tshark -r capture.pcap --export-objects smb,./extracted_files/

# Export FTP data
tshark -r capture.pcap --export-objects tftp,./extracted_files/
```

### NetworkMiner (GUI atau CLI)
```bash
# Install
sudo apt install networkminer

# Jalankan
mono /usr/lib/NetworkMiner/NetworkMiner.exe capture.pcap
# Files otomatis di-extract ke AssembledFiles/
```

### Cara Manual
```bash
# Extract TCP stream sebagai binary
tshark -r capture.pcap -Y "tcp.stream eq 5" -T fields -e data | xxd -r -p > stream5.bin

# Atau dengan tcpflow
tcpflow -r capture.pcap -o ./flows/
```

---

## 🔐 Analisis Protokol Spesifik

### HTTP Analysis
```bash
# Wireshark: Statistics → HTTP → Requests
# Wireshark: Statistics → HTTP → Load Distribution

# tshark HTTP summary
tshark -r capture.pcap -q -z http,stat,

# User agents
tshark -r capture.pcap -Y http.request -T fields -e http.user_agent | sort | uniq -c

# Cookies
tshark -r capture.pcap -Y "http.cookie" -T fields -e http.cookie
```

### FTP Analysis
```bash
# FTP credentials (plaintext!)
tshark -r capture.pcap -Y "ftp.request.command == USER || ftp.request.command == PASS" -T fields -e ftp.request.command -e ftp.request.arg

# Files yang ditransfer
tshark -r capture.pcap -Y "ftp.request.command == RETR || ftp.request.command == STOR" -T fields -e ftp.request.arg
```

### SMTP Analysis
```bash
# Email headers
tshark -r capture.pcap -Y smtp -T fields -e smtp.data.fragment

# Follow TCP stream untuk lihat email lengkap
```

### DNS Analysis
```bash
# Semua domain yang di-resolve
tshark -r capture.pcap -Y "dns.flags.response == 0" -T fields -e dns.qry.name | sort -u

# DNS resolution (query + answer)
tshark -r capture.pcap -Y dns -T fields -e dns.qry.name -e dns.a | sort -u
```

---

## 📊 Statistics & Overview

### Wireshark Statistics
```
Statistics → Protocol Hierarchy     → breakdown semua protokol
Statistics → Conversations          → semua percakapan
Statistics → Endpoints              → semua endpoint IP
Statistics → IO Graph               → traffic timeline
Statistics → Expert Information     → anomali otomatis
Analyze → Expert Info               → error, warning, notes
```

### tshark Statistics
```bash
# Protocol hierarchy
tshark -r capture.pcap -q -z io,phs

# Top talkers
tshark -r capture.pcap -q -z conv,ip | head -20

# Packet counts
tshark -r capture.pcap -q -z io,stat,60   # Per 60 detik

# Follow stream ke file
tshark -r capture.pcap -q -z follow,tcp,ascii,0   # Stream 0
```

---

## 🚩 Checklist Analisis PCAP (LKS)

```
□ 1. Buka di Wireshark
□ 2. Statistics → Protocol Hierarchy (protokol apa saja?)
□ 3. Statistics → Conversations (siapa komunikasi dengan siapa?)
□ 4. Filter HTTP → follow stream → cari credential/flag
□ 5. Filter DNS → domain mencurigakan?
□ 6. Filter FTP → transfer file? credential?
□ 7. Export Objects (HTTP/SMB/FTP) → analisis file yang ditransfer
□ 8. Cek TCP stream satu per satu jika perlu
□ 9. strings pada PCAP file langsung:
     strings capture.pcap | grep -i "flag\|CTF\|password"
□ 10. binwalk/foremost jika ada file embedded
```

---

## 🔄 Workflow Cepat (LKS Mode)

```bash
# 1. Overview cepat
tshark -r capture.pcap -q -z io,phs        # Protocol breakdown

# 2. HTTP check
tshark -r capture.pcap -Y http.request -T fields -e ip.src -e http.host -e http.request.uri

# 3. Credential hunting
tshark -r capture.pcap -Y "ftp || http.authorization || smtp" -T fields -e ftp.request.arg -e http.authorization

# 4. DNS exfil check
tshark -r capture.pcap -Y dns -T fields -e dns.qry.name | awk 'length > 50'

# 5. String search
strings capture.pcap | grep -i "flag\|password\|secret\|key"

# 6. Extract HTTP files
tshark -r capture.pcap --export-objects http,./http_files/
file ./http_files/*
```

---

## 📝 Decode Data

```bash
# Base64 dalam HTTP/network
echo "SGVsbG8gV29ybGQ=" | base64 -d

# URL encoded
python3 -c "import urllib.parse; print(urllib.parse.unquote('%68%65%6c%6c%6f'))"

# Hex encoded
echo "48656c6c6f" | xxd -r -p

# XOR (jika tahu key)
python3 -c "
data = bytes.fromhex('1b2d3c4e')
key = 0x41
print(''.join(chr(b ^ key) for b in data))
"
```

---

*Digital Forensics Cheatsheet | LKS Jawa Barat*
