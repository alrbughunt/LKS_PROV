# 🧠 Memory Forensics — Cheatsheet LKS Jawa Barat

## 📖 Konsep Dasar

**Memory Forensics** = Analisis RAM dump untuk menemukan bukti digital yang hanya ada di memori (tidak tersimpan di disk).

### Kenapa Memory Penting?
- **Enkripsi keys** tersimpan di RAM
- **Running processes** (termasuk malware in-memory)
- **Network connections** aktif
- **Credentials** (password, token) bisa ada di RAM
- **Volatile data** yang hilang saat shutdown
- **Code injection** dan **rootkit** bisa terdeteksi

### Format Memory Dump
| Format | Ekstensi | Keterangan |
|--------|----------|-----------|
| Raw | `.raw`, `.mem`, `.bin` | Dump langsung |
| VMware | `.vmem` | VMware snapshot |
| VirtualBox | `.sav` | VirtualBox state |
| Hibernation | `hiberfil.sys` | Windows hibernation |
| Crash Dump | `.dmp` | Windows crash dump |
| LiME | `.lime` | Linux Memory Extractor |

---

## 🛠️ Volatility 3 — Tool Utama ⭐

### Instalasi
```bash
# Via pip
pip3 install volatility3

# Atau clone
git clone https://github.com/volatilityfoundation/volatility3
cd volatility3
pip3 install -r requirements.txt
python3 vol.py -h

# Symbols untuk Windows (download dari Volatility)
# Simpan di: volatility3/volatility3/symbols/
```

### Syntax Dasar
```bash
# Volatility 3
python3 vol.py -f memory.raw PLUGIN_NAME

# Atau jika sudah install
vol -f memory.raw PLUGIN_NAME
vol -f memory.raw windows.PLUGIN_NAME   # Windows plugins
vol -f memory.raw linux.PLUGIN_NAME     # Linux plugins
```

---

## 🪟 Windows Memory Plugins

### 1. Identifikasi OS
```bash
vol -f memory.raw windows.info          # Info sistem operasi
vol -f memory.raw banners               # OS banner/version
```

### 2. Process Analysis ⭐ MULAI DARI SINI
```bash
# List proses
vol -f memory.raw windows.pslist        # Process list
vol -f memory.raw windows.pstree        # Process tree (hierarki)
vol -f memory.raw windows.psscan        # Scan (temukan hidden process!)
vol -f memory.raw windows.cmdline       # Command line tiap proses
vol -f memory.raw windows.dlllist       # DLL yang di-load tiap proses
vol -f memory.raw windows.handles       # Handle/resource tiap proses

# Bandingkan pslist vs psscan (hidden process akan muncul di psscan tapi tidak di pslist)
```

### 3. Network Connections
```bash
vol -f memory.raw windows.netstat       # Koneksi aktif + proses
vol -f memory.raw windows.netscan       # Semua network artifacts
```

### 4. Registry
```bash
vol -f memory.raw windows.registry.hivelist    # List registry hives
vol -f memory.raw windows.registry.printkey    # Print registry key
vol -f memory.raw windows.registry.printkey --key "Software\Microsoft\Windows\CurrentVersion\Run"

# Hive dump
vol -f memory.raw windows.registry.hivescan
```

### 5. Files
```bash
vol -f memory.raw windows.filescan      # Scan semua file objects
vol -f memory.raw windows.filescan | grep -i "\.exe\|\.dll\|\.bat\|\.ps1"
vol -f memory.raw windows.filescan | grep "flag\|secret\|password"

# Dump file dari memory
vol -f memory.raw windows.dumpfiles --pid 1234             # Dump files dari PID
vol -f memory.raw windows.dumpfiles --physaddr 0xXXXXXX    # Dump by physical address
```

### 6. Malfind — Deteksi Code Injection ⭐
```bash
vol -f memory.raw windows.malfind             # Deteksi injected code
vol -f memory.raw windows.malfind --pid 1234  # Untuk PID tertentu

# Output: region yang tidak biasa = kemungkinan injected code / shellcode
```

### 7. Process Memory Dump
```bash
# Dump seluruh memory proses
vol -f memory.raw windows.memmap --pid 1234 --dump

# Dump dari vadump
vol -f memory.raw windows.vadump --pid 1234 --dump
```

### 8. User & Credentials
```bash
# Hashes dari SAM/SYSTEM
vol -f memory.raw windows.hashdump      # NTLM hashes (butuh SAM + SYSTEM hive)

# LSA secrets
vol -f memory.raw windows.lsadump       # LSA secrets

# Credentials dari memory
vol -f memory.raw windows.cachedump     # Cached domain credentials
```

### 9. Misc Plugins
```bash
# Screenshot (jika ada GUI)
vol -f memory.raw windows.screenshot --dump

# Clipboard
vol -f memory.raw windows.clipboard

# Environment variables
vol -f memory.raw windows.envars --pid 1234

# Loaded modules/drivers
vol -f memory.raw windows.driverscan
vol -f memory.raw windows.modscan
```

---

## 🐧 Linux Memory Plugins

```bash
# Banner/OS info
vol -f memory.raw banners

# Process list
vol -f memory.raw linux.pslist
vol -f memory.raw linux.pstree
vol -f memory.raw linux.psscan

# Network
vol -f memory.raw linux.netstat
vol -f memory.raw linux.ifconfig

# Files
vol -f memory.raw linux.find_file        # Cari file
vol -f memory.raw linux.bash             # Bash history dari memory!

# Modules (rootkit detection)
vol -f memory.raw linux.lsmod
vol -f memory.raw linux.check_modules    # Deteksi modul tersembunyi

# Mounts
vol -f memory.raw linux.mountinfo
```

---

## 🔄 Workflow Memory Forensics ⭐

```
LANGKAH 1: Identifikasi
├── vol -f memory.raw windows.info    → OS info
└── file memory.raw                  → tipe file

LANGKAH 2: Process Analysis
├── vol -f memory.raw windows.pslist   → semua proses
├── vol -f memory.raw windows.pstree   → hierarki proses
├── vol -f memory.raw windows.psscan   → bandingkan (hidden?)
└── vol -f memory.raw windows.cmdline  → command line mencurigakan

LANGKAH 3: Network
└── vol -f memory.raw windows.netstat  → koneksi aktif

LANGKAH 4: Suspect Process
├── Identifikasi PID yang mencurigakan
├── vol -f memory.raw windows.dlllist --pid [PID]
├── vol -f memory.raw windows.handles --pid [PID]
└── vol -f memory.raw windows.malfind --pid [PID]

LANGKAH 5: File & Registry
├── vol -f memory.raw windows.filescan | grep -i "flag\|secret"
└── vol -f memory.raw windows.registry.hivelist

LANGKAH 6: Dump & Analisis
├── vol -f memory.raw windows.dumpfiles --pid [PID]
└── strings dump_file | grep -i "flag\|password\|http"
```

---

## 🔍 Teknik Investigasi Spesifik

### Mencari Flag/Secret di Memory
```bash
# strings langsung di memory dump
strings memory.raw | grep -i "flag{" 
strings memory.raw | grep -i "CTF\|LKS"

# strings dari proses yang di-dump
strings pid.1234.dmp | grep -i flag

# Setelah filescan
vol -f memory.raw windows.filescan | grep "flag\|note\|secret\|password"
```

### Deteksi Malware
```bash
# 1. Cari proses dengan nama aneh atau mirip sistem
vol -f memory.raw windows.pslist | grep -v "System\|smss\|csrss\|wininit\|services\|lsass\|svchost\|explorer"

# 2. Cek parent-child relationship
vol -f memory.raw windows.pstree

# 3. Code injection
vol -f memory.raw windows.malfind

# 4. Network connection dari proses aneh
vol -f memory.raw windows.netstat

# 5. Strings dari proses mencurigakan
vol -f memory.raw windows.dumpfiles --pid [SUSPICIOUS_PID]
strings *.dmp | grep -i "http\|wget\|curl\|powershell\|cmd\|download"
```

### Analisis Proses Windows Normal vs Anomali

| Proses | Parent Normal | Count Normal |
|--------|--------------|-------------|
| `System` | None (PID 4) | 1 |
| `smss.exe` | System | 1 |
| `csrss.exe` | smss.exe | 1-2 |
| `wininit.exe` | smss.exe | 1 |
| `services.exe` | wininit.exe | 1 |
| `lsass.exe` | wininit.exe | 1 |
| `svchost.exe` | services.exe | Banyak (normal) |
| `explorer.exe` | userinit.exe | 1 per user |

**Red flags:**
- `svchost.exe` parent bukan `services.exe`
- 2x `lsass.exe`
- `cmd.exe` atau `powershell.exe` child dari browser
- Proses dengan nama mirip sistem tapi typo (`svch0st.exe`, `lssas.exe`)

---

## 🧰 Tools Tambahan

### Rekall (alternatif Volatility)
```bash
rekall -f memory.raw pslist
rekall -f memory.raw netscan
```

### Strings + grep
```bash
strings -a memory.raw | grep -oE '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}' # Email
strings -a memory.raw | grep -oE 'https?://[^ ]+' # URLs
strings -a memory.raw | grep -oE '\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b' # IPs
```

### Bulk Extractor — Extract Artifacts Otomatis
```bash
bulk_extractor -o ./output memory.raw
# Akan extract: emails, URLs, credit cards, MAC addresses, dll
```

---

## 📝 Cheat Perintah Cepat (LKS Mode)

```bash
# 5 perintah pertama saat dapat memory dump:
vol -f mem.raw windows.info
vol -f mem.raw windows.pslist > pslist.txt
vol -f mem.raw windows.cmdline > cmdline.txt
vol -f mem.raw windows.netstat > netstat.txt
vol -f mem.raw windows.filescan > filescan.txt

# Cari yang mencurigakan:
grep -i "temp\|appdata\|flag\|password\|secret" filescan.txt
cat cmdline.txt | grep -v "svchost\|System"
```

---

*Digital Forensics Cheatsheet | LKS Jawa Barat*
