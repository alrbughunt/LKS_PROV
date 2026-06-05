# 🔍 Digital Forensics Cheatsheet — LKS Jawa Barat
> **Dipersiapkan untuk: LKS Provinsi Jawa Barat | Skill: Cyber Security**  
> Covers: Log Analysis • Steganography • File Recovery • Disk Forensics • OS Forensics • Memory Forensics • Network Forensics • OSINT

---

## 📂 Struktur Folder

```
digital-forensics-cheatsheet/
├── 01-log-analysis/          → Auth, Access, Syslog analysis
├── 02-steganography/         → Steg detection & extraction
├── 03-file-recovery/         → File carving & recovery
├── 04-disk-forensics/        → Disk imaging & analysis
├── 05-os-forensics/          → Windows & Linux artifacts
├── 06-memory-forensics/      → Volatility & RAM analysis
├── 07-network-forensics/     → PCAP & Wireshark
└── 08-osint/                 → OSINT tools & techniques
```

---

## 🛠️ Tools Wajib Install

| Tool | Install | Fungsi |
|------|---------|--------|
| `autopsy` | `sudo apt install autopsy` | GUI Disk & File Forensics |
| `volatility3` | `pip3 install volatility3` | Memory Forensics |
| `wireshark` | `sudo apt install wireshark` | Network/PCAP Analysis |
| `binwalk` | `sudo apt install binwalk` | File Carving/Steg |
| `steghide` | `sudo apt install steghide` | Steganography |
| `foremost` | `sudo apt install foremost` | File Recovery |
| `exiftool` | `sudo apt install exiftool` | Metadata Analysis |
| `strings` | Built-in Linux | Extract strings dari binary |
| `xxd / hexdump` | Built-in Linux | Hex analysis |
| `tcpdump` | `sudo apt install tcpdump` | Capture network |

---

## ⚡ Quick Reference — Flag Hunting

```
CTF mindset: Semua evidence punya artifact. Artifact punya trail. Trail punya flag.
```

1. **File masuk** → `file`, `exiftool`, `strings`, `xxd`
2. **Image/Audio** → steganography tools
3. **PCAP** → Wireshark filter → follow stream
4. **Memory dump** → Volatility pslist → cmdline → filescan → dump
5. **Disk image** → `mmls` → mount → Autopsy
6. **Log** → grep untuk IP/user/timestamp anomali

---

*Maintained for LKS Jawa Barat preparation | Last updated: 2025*
