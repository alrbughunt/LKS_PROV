# 🔎 OSINT (Open-Source Intelligence) — Cheatsheet LKS Jawa Barat

## 📖 Konsep Dasar

**OSINT** = Pengumpulan dan analisis informasi dari sumber yang **tersedia publik** untuk tujuan investigasi atau intelijen.

### Sumber OSINT
- Search engines (Google, Bing, DuckDuckGo)
- Social media
- Domain & IP records (WHOIS, DNS)
- Leak databases
- Image metadata & reverse search
- Dark web (dengan izin)
- Government records
- News & media

### Prinsip OSINT
```
1. Passive reconnaissance (tidak berinteraksi langsung dengan target)
2. Legal & ethical
3. Dokumentasi setiap langkah
4. Verifikasi informasi dari multiple sources
```

---

## 🌐 Domain & IP Intelligence

### WHOIS Lookup
```bash
# Terminal
whois example.com
whois 8.8.8.8

# Website:
# https://whois.domaintools.com
# https://who.is
# https://lookup.icann.org
```

### DNS Records
```bash
# nslookup
nslookup example.com                    # A record (IPv4)
nslookup -type=MX example.com           # Mail server
nslookup -type=TXT example.com          # Text records (SPF, DKIM)
nslookup -type=NS example.com           # Nameservers
nslookup -type=CNAME example.com        # Canonical name
nslookup -type=ANY example.com          # Semua record

# dig (lebih detail)
dig example.com                         # Default (A record)
dig example.com A                       # IPv4
dig example.com AAAA                    # IPv6
dig example.com MX                      # Mail
dig example.com TXT                     # Text
dig example.com NS                      # Nameservers
dig example.com SOA                     # Start of Authority
dig +short example.com                  # Output singkat
dig @8.8.8.8 example.com               # Query ke DNS spesifik

# Reverse DNS
dig -x 8.8.8.8                         # PTR record
nslookup 8.8.8.8
```

### Subdomain Enumeration
```bash
# subfinder (passive)
subfinder -d example.com
subfinder -d example.com -o subdomains.txt

# amass
amass enum -passive -d example.com
amass enum -d example.com -o amass.txt

# assetfinder
assetfinder example.com
assetfinder --subs-only example.com

# Online:
# https://dnsdumpster.com
# https://subdomainfinder.c99.nl
# https://crt.sh (Certificate Transparency)
```

### crt.sh — Certificate Transparency
```bash
# Via curl
curl -s "https://crt.sh/?q=%.example.com&output=json" | python3 -m json.tool | grep "name_value"

# Kunjungi langsung: https://crt.sh/?q=%.example.com
```

---

## 🔍 Search Engine Techniques (Google Dorks)

### Syntax Dasar
```
"exact phrase"          → Pencarian persis
site:example.com        → Hanya di domain ini
filetype:pdf            → Tipe file tertentu
inurl:admin             → URL mengandung kata
intitle:login           → Judul halaman
intext:password         → Teks di halaman
-kata                   → Kecualikan kata
OR                      → Salah satu
*                       → Wildcard
```

### Google Dorks Berguna
```
# Cari file sensitif
site:example.com filetype:pdf
site:example.com filetype:xlsx OR filetype:csv
site:example.com filetype:sql

# Login pages
site:example.com inurl:admin
site:example.com inurl:login
site:example.com intitle:"admin panel"

# Config files (jangan abuse!)
site:example.com inurl:config filetype:txt
site:example.com inurl:wp-config

# Cari email
site:example.com "@example.com"
"email" OR "contact" site:example.com

# Exposed directories
site:example.com intitle:"index of"
site:example.com intitle:"directory listing"

# Social media profiles
site:linkedin.com "nama orang"
site:twitter.com "nama orang"
site:instagram.com "nama orang"

# Database Dork GHDB
# https://www.exploit-db.com/google-hacking-database
```

---

## 👤 Person OSINT

### Email Investigation
```bash
# theHarvester — gather email, subdomain, IP
theHarvester -d example.com -b google,bing,linkedin

# hunter.io (web)
# https://hunter.io

# Verify email
python3 -c "
import smtplib, dns.resolver
# MX records
mx = dns.resolver.resolve('example.com', 'MX')
"

# h8mail — email breach checker
h8mail -t target@example.com
```

### Username Search
```bash
# sherlock — cari username di ratusan platform
sherlock username_target
sherlock username --print-found
sherlock username --timeout 5

# Whatsmyname
# https://whatsmyname.app/

# InstantUsername
# https://instantusername.com/
```

### Email Breach Database
```bash
# HIBP (Have I Been Pwned)
# https://haveibeenpwned.com
# API:
curl "https://haveibeenpwned.com/api/v3/breachedaccount/test@example.com" -H "hibp-api-key: KEY"

# Dehashed (berbayar tapi powerful)
# https://dehashed.com
```

---

## 🖼️ Image OSINT

### Metadata (EXIF)
```bash
# Lokasi GPS, kamera, timestamp
exiftool gambar.jpg
exiftool -GPSLatitude -GPSLongitude gambar.jpg
exiftool -CreateDate gambar.jpg

# Jeffrey's Exif Viewer
# http://exif.regex.info/exif.cgi

# Konversi GPS coordinates
# DMS ke Decimal: Degree + Minute/60 + Second/3600
# -6°55'10" = -(6 + 55/60 + 10/3600) = -6.919444
```

### Reverse Image Search
```
Google Images    → https://images.google.com (drag & drop)
TinEye           → https://tineye.com
Yandex Images    → https://yandex.com/images (TERBAIK untuk orang)
Bing Visual      → https://www.bing.com/visualsearch
```

### Geolocation dari Gambar
```
Petunjuk:
- Bahasa pada tanda/papan
- Plat nomor kendaraan
- Arsitektur bangunan
- Vegetasi/tanaman
- Sun position/shadows → arah
- Landmark yang bisa diidentifikasi

Tools:
- Google Street View
- GeoGuessr techniques
- https://www.geoimgr.com
```

---

## 🌍 IP Intelligence

```bash
# ipinfo.io
curl ipinfo.io/8.8.8.8
curl https://ipinfo.io/8.8.8.8/json

# Shodan — "search engine for the Internet of Things"
# https://shodan.io (web)
# CLI:
pip3 install shodan
shodan host 8.8.8.8
shodan search "apache server:2.4"

# Censys
# https://censys.io

# VirusTotal — IP/domain reputation
curl --request GET \
  --url "https://www.virustotal.com/api/v3/ip_addresses/8.8.8.8" \
  --header "x-apikey: YOUR_API_KEY"
```

### Geolocation IP
```bash
# CLI tools
curl ipinfo.io/8.8.8.8
curl ip-api.com/json/8.8.8.8

# Web:
# https://ipinfo.io
# https://ipgeolocation.io
# https://www.maxmind.com

# Python
python3 -c "
import requests
r = requests.get('http://ip-api.com/json/8.8.8.8')
print(r.json())
"
```

---

## 📱 Social Media OSINT

### Tools
```bash
# Instagram
# https://imginn.com (tanpa login)
# https://picuki.com

# Twitter/X
# https://twitterfall.com
# Advanced search: https://twitter.com/search-advanced

# LinkedIn
# InSpy (LinkedIn enumeration)
python3 inspy.py --empspy example.com

# Facebook
# https://www.sowsearch.info
```

### Analisis Konten
```
- Waktu posting → timezone hint
- Bahasa → lokasi kemungkinan
- Foto → metadata EXIF, geolocation
- Followers/following → network mapping
- Hashtags → interests, locations
- Checked-in locations
```

---

## 🔧 Framework & Tools Terintegrasi

### Maltego
```
GUI tool untuk OSINT & link analysis
Entities: Person, Domain, IP, Email, dll
Transforms: otomatis query multiple sources
```

### Spiderfoot
```bash
# Install
pip3 install spiderfoot
# atau
git clone https://github.com/smicallef/spiderfoot

# Run
python3 sf.py -l 127.0.0.1:5001
# Buka browser: http://127.0.0.1:5001

# CLI mode
python3 sfcli.py -s "example.com" -t internet -u all
```

### Recon-ng
```bash
# Install
sudo apt install recon-ng

# Jalankan
recon-ng

# Basic commands dalam recon-ng
[recon-ng] workspaces create lks2025
[recon-ng] modules search whois
[recon-ng] modules load recon/domains-hosts/google_site_web
[recon-ng] options set SOURCE example.com
[recon-ng] run
```

### theHarvester
```bash
# Install
sudo apt install theharvester

# Collect email, subdomain, IP
theHarvester -d example.com -b all
theHarvester -d example.com -b google -l 500
theHarvester -d example.com -b bing,google,linkedin -f output.html

# Sources: google, bing, linkedin, twitter, hunter, shodan, dll
```

---

## 🔄 Workflow OSINT

```
TARGET: Domain/IP/Person/Organization

LANGKAH 1: Passive Recon (tidak berinteraksi langsung)
├── WHOIS → pemilik domain
├── DNS records → infrastruktur
├── crt.sh → subdomain via SSL cert
└── Google dorks → informasi publik

LANGKAH 2: Infrastructure Mapping
├── Shodan/Censys → exposed services
├── Subdomain enumeration
└── IP ranges (ASN lookup)

LANGKAH 3: Person/Organization
├── LinkedIn → karyawan
├── Email harvesting
├── Username search (sherlock)
└── Breach database (HIBP)

LANGKAH 4: Deep Dive
├── Social media analysis
├── Image OSINT (EXIF, reverse search)
└── Historical data (Wayback Machine)

LANGKAH 5: Dokumentasi
└── Mind map → Maltego atau manual
```

---

## 🗺️ Wayback Machine

```bash
# Cek riwayat website
# https://web.archive.org

# API
curl "http://archive.org/wayback/available?url=example.com&timestamp=20200101"

# Cari halaman yang sudah dihapus
# https://web.archive.org/web/*/example.com/*
```

---

## 📋 OSINT Resources Penting

| Resource | URL | Fungsi |
|----------|-----|--------|
| Shodan | shodan.io | Internet-facing devices |
| Censys | censys.io | Internet scan |
| VirusTotal | virustotal.com | Malware/IP reputation |
| HIBP | haveibeenpwned.com | Email breach |
| crt.sh | crt.sh | SSL certs/subdomains |
| WaybackMachine | web.archive.org | Archived pages |
| DNSDumpster | dnsdumpster.com | DNS recon |
| Hunter.io | hunter.io | Email finder |
| Sherlock | github | Username OSINT |
| theHarvester | built-in Kali | Multi-source recon |
| Maltego CE | maltego.com | Link analysis |
| IntelX | intelx.io | Search engine OSINT |

---

*Digital Forensics Cheatsheet | LKS Jawa Barat*
