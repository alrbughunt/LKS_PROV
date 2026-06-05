# ⚡ QUICK REFERENCE — Digital Forensics LKS Jawa Barat
> Print dan tempel ini di depan meja. One-page master cheatsheet.

---

## 🔥 FIRST 5 MINUTES CHECKLIST

```bash
# Dapat file/evidence apapun? Mulai sini:
file <evidence>                        # Apa tipe filenya?
exiftool <evidence>                    # Ada metadata?
strings <evidence> | grep -i flag     # Ada flag langsung?
xxd <evidence> | head && xxd <evidence> | tail  # Magic bytes?
binwalk <evidence>                     # Ada embedded files?
```

---

## 📊 CHEAT SHEET MATRIX

| Evidence | Tool Pertama | Tool Kedua | Yang Dicari |
|----------|-------------|------------|-------------|
| `.img`/disk | `mmls` → `mount` | `foremost`, `fls -rd` | Deleted files, partitions |
| `.raw`/memory | `vol windows.pslist` | `vol windows.cmdline` | Proses aneh, cmdline |
| `.pcap` | Wireshark buka | `tshark http.request` | Credentials, files |
| Image PNG/JPG | `strings` + `zsteg` | `steghide` + `binwalk` | Hidden data |
| Audio WAV/MP3 | `steghide extract` | Spectrogram | Hidden message |
| Log file | `grep "Failed\|Error"` | `awk` count | Anomali, brute force |
| ZIP/archive | `unzip -l` | `binwalk` | Nested files |
| Unknown binary | `file` + `xxd` | `strings` | Magic bytes, text |

---

## 🔑 VOLATILITY 3 — TOP COMMANDS

```bash
vol -f mem.raw windows.info           # OS info
vol -f mem.raw windows.pslist         # Process list
vol -f mem.raw windows.pstree         # Process hierarchy  
vol -f mem.raw windows.psscan         # Hidden process scan
vol -f mem.raw windows.cmdline        # Command lines
vol -f mem.raw windows.netstat        # Network connections
vol -f mem.raw windows.filescan       # Files in memory
vol -f mem.raw windows.malfind        # Code injection
vol -f mem.raw windows.hashdump       # Password hashes
vol -f mem.raw windows.dumpfiles --pid [PID]  # Dump process files
```

---

## 🦈 WIRESHARK TOP FILTERS

```
http                          → Semua HTTP
http.request.method == "POST" → POST requests
ftp                           → Semua FTP
dns.qry.name contains "evil"  → DNS ke domain ini
tcp.flags.syn==1 && tcp.flags.ack==0  → Port scan
ip.addr == 10.0.0.1           → Traffic dari/ke IP ini
http.response.code == 200     → HTTP 200
tcp.stream eq 0               → TCP stream pertama
```

---

## 🔢 MAGIC BYTES

```
FF D8 FF    → JPEG
89 50 4E 47 → PNG
50 4B 03 04 → ZIP/DOCX/JAR
25 50 44 46 → PDF
52 61 72 21 → RAR
4D 5A       → EXE/DLL
7F 45 4C 46 → ELF (Linux exec)
52 49 46 46 → WAV/AVI
```

---

## 📂 LINUX PATHS WAJIB CEK

```
/etc/passwd       → Users
/etc/shadow       → Password hashes
/var/log/auth.log → Login attempts
/tmp/ /dev/shm/   → Malware hiding spot
~/.bash_history   → Command history
~/.ssh/           → SSH keys
/etc/crontab      → Persistence
```

---

## 📋 LOG GREP COMMANDS

```bash
grep "Failed password" /var/log/auth.log | grep -oP '(\d+\.){3}\d+' | sort | uniq -c | sort -rn
grep "Accepted" /var/log/auth.log                # Successful logins
grep " 200 " access.log | awk '{print $1}' | sort | uniq -c | sort -rn
grep -i "union\|select\|drop\|--" access.log     # SQL injection
grep "\.\.\/" access.log                         # Path traversal
```

---

## 🔧 STEGANOGRAPHY QUICK

```bash
# Image:
zsteg image.png                       # PNG LSB
steghide extract -sf image.jpg -p ""  # JPG no password
exiftool image.* | grep -i comment    # Metadata
binwalk -e image.*                    # Embedded

# Audio:
steghide extract -sf audio.wav -p ""  # WAV
sox audio.wav -n spectrogram -o s.png # Visualize spectrum

# Universal:
strings file | grep -i flag
binwalk -Me file
```

---

## 🌐 OSINT QUICK HITS

```bash
whois domain.com               # Domain owner
dig domain.com ANY             # All DNS records
theHarvester -d domain -b all  # Emails, subdomains
sherlock username              # Social media lookup

# Web: crt.sh, shodan.io, dnsdumpster.com, haveibeenpwned.com
```

---

## 🚩 RED FLAGS TO SPOT

| Konteks | Red Flag |
|---------|----------|
| Log | Ratusan "Failed password" dari 1 IP |
| Log | Login berhasil setelah banyak gagal |
| Log | Cron job ke `/tmp` |
| Process | `svchost.exe` parent bukan `services.exe` |
| Process | 2x `lsass.exe` |
| Process | Browser spawn `cmd.exe` |
| Network | DNS query > 50 karakter |
| Network | POST ke file PHP di /upload/ |
| File | Magic bytes tidak sesuai ekstensi |
| File | SUID binary di lokasi aneh |

---

## 🔓 DECODE SHORTCUTS

```bash
echo "BASE64==" | base64 -d                    # Base64
echo "68656c6c6f" | xxd -r -p                  # Hex to ASCII
echo "ROT13" | tr 'A-Za-z' 'N-ZA-Mn-za-m'    # ROT13
python3 -c "print(bytes.fromhex('68656c6c6f').decode())"  # Python hex
python3 -c "import urllib.parse; print(urllib.parse.unquote('%68%65%6c%6c%6f'))"  # URL decode
```

---

*🏆 Semangat LKS! — Digital Forensics | Jawa Barat*
