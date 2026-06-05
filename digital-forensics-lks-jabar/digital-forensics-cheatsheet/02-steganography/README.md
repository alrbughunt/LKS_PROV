# 🖼️ Steganography — Cheatsheet LKS Jawa Barat

## 📖 Konsep Dasar

**Steganography** = Menyembunyikan data di dalam file lain (image, audio, video, text) tanpa terlihat mencurigakan.

**Bedanya dengan Kriptografi:**
- Kriptografi → data dienkripsi (terlihat tapi tidak terbaca)
- Steganografi → data disembunyikan (tidak terlihat sama sekali)

### Media yang Sering Dipakai
| Media | Teknik Umum | Tool |
|-------|-------------|------|
| **Image (PNG/JPG)** | LSB, metadata, appended data | steghide, zsteg, stegsolve |
| **Audio (WAV/MP3)** | LSB, spectrum | steghide, sonic-visualiser |
| **Video** | Frame manipulation | ffmpeg |
| **Text** | Whitespace, Unicode | manual |
| **ZIP/Binary** | Data appended | binwalk, foremost |

---

## 🛠️ Tools & Commands

### 1. `file` — Identifikasi Tipe File
```bash
file gambar.png
file gambar.jpg
file audio.wav
# Jika hasil tidak sesuai ekstensi = mencurigakan!
```

### 2. `exiftool` — Metadata Analysis
```bash
exiftool gambar.png          # Semua metadata
exiftool -comment gambar.jpg # Cek comment field
exiftool -all gambar.png     # Semua tag termasuk tersembunyi

# Cek semua file sekaligus
exiftool *.jpg | grep -i "comment\|description\|artist"
```

### 3. `strings` — Extract Strings
```bash
strings gambar.png           # Semua printable string
strings -n 6 gambar.png      # String minimal 6 karakter
strings gambar.png | grep -i "flag\|CTF\|htb\|password"
```

### 4. `xxd` / `hexdump` — Hex Analysis
```bash
xxd gambar.png | head -20    # Cek magic bytes (header)
xxd gambar.png | tail -20    # Cek akhir file (appended data)
xxd gambar.png | grep -i "flag"

# Bandingkan dua file
xxd file1.png > hex1.txt
xxd file2.png > hex2.txt
diff hex1.txt hex2.txt
```

### 5. `binwalk` — Embedded Files Detection ⭐ WAJIB
```bash
binwalk gambar.png            # Scan embedded files
binwalk -e gambar.png         # Extract semua embedded files
binwalk -Me gambar.png        # Recursive extract
binwalk --dd='.*' gambar.png  # Extract semua tipe
```

### 6. `steghide` — Steg dengan Password
```bash
# Extract data (akan minta password)
steghide extract -sf gambar.jpg
steghide extract -sf gambar.jpg -p "password"
steghide extract -sf gambar.jpg -p "" -f   # tanpa password

# Embed data
steghide embed -cf gambar.jpg -sf secret.txt -p "password"

# Info
steghide info gambar.jpg
```

### 7. `zsteg` — PNG/BMP Steganography ⭐
```bash
zsteg gambar.png              # Auto-detect semua channel
zsteg -a gambar.png           # All tests
zsteg -v gambar.png           # Verbose
zsteg gambar.png --bits 1 --order xy  # Manual specify

# Install: gem install zsteg
```

### 8. `stegsolve` / `stegoveritas` — Visual Analysis
```bash
# stegoveritas (CLI)
stegoveritas gambar.png       # Auto analysis semua teknik
stegoveritas -out ./output gambar.png

# Install: pip3 install stegoveritas
```

### 9. `foremost` — File Carving dari Image
```bash
foremost -i gambar.png -o ./output
foremost -t jpg,png,zip -i file.bin -o ./output
```

### 10. `pngcheck` — Validate PNG
```bash
pngcheck -v gambar.png        # Verbose chunk analysis
pngcheck -c gambar.png        # Check CRC
```

---

## 🎵 Audio Steganography

### Audacity / Sonic Visualizer
```bash
# Install Sonic Visualizer untuk spectrum analysis
sudo apt install sonic-visualiser

# DTMF/spectrum: lihat di Spectrogram view
# Flag sering tersembunyi dalam frequency domain
```

### `sox` & Manipulasi Audio
```bash
sox audio.wav -n spectrogram -o spectrum.png  # Buat spectrogram
sox audio.wav output.mp3       # Convert format
```

### `steghide` untuk Audio WAV
```bash
steghide extract -sf audio.wav -p "password"
```

### `mp3stego` untuk MP3
```bash
mp3stego -X -P password audio.mp3  # Extract
```

---

## 🔢 Magic Bytes — Wajib Hafal

| Format | Magic Bytes (Hex) | Signature |
|--------|-------------------|-----------|
| **PNG** | `89 50 4E 47 0D 0A 1A 0A` | `‰PNG....` |
| **JPG** | `FF D8 FF` | `ÿØÿ` |
| **GIF** | `47 49 46 38` | `GIF8` |
| **ZIP** | `50 4B 03 04` | `PK..` |
| **PDF** | `25 50 44 46` | `%PDF` |
| **RAR** | `52 61 72 21` | `Rar!` |
| **7Z** | `37 7A BC AF 27 1C` | `7z¼¯'` |
| **ELF** | `7F 45 4C 46` | `.ELF` |
| **PE/EXE** | `4D 5A` | `MZ` |
| **MP3** | `FF FB` | `ÿû` |
| **WAV** | `52 49 46 46` | `RIFF` |
| **BMP** | `42 4D` | `BM` |

---

## 🔄 Alur Investigasi Steganografi

```
LANGKAH 1: Identifikasi
├── file <filename>        → cek tipe asli
├── exiftool <filename>    → cek metadata
└── strings <filename>    → cari teks tersembunyi

LANGKAH 2: Hex Analysis
├── xxd <file> | head      → cek header/magic bytes
├── xxd <file> | tail      → cek apakah ada appended data
└── binwalk <file>        → cek embedded files

LANGKAH 3: Ekstraksi
├── binwalk -e <file>      → extract embedded
├── steghide extract       → jika JPG/WAV + password
├── zsteg <file>           → jika PNG (LSB)
└── foremost -i <file>    → file carving

LANGKAH 4: Analisis Hasil
├── Buka file hasil ekstraksi
├── Ulangi dari Langkah 1 untuk file baru
└── Decode jika perlu (base64, hex, dll)
```

---

## 🔐 Encoding yang Sering Muncul

```bash
# Base64
echo "SGVsbG8=" | base64 -d

# Hex to ASCII
echo "48656c6c6f" | xxd -r -p

# ROT13
echo "Uryyb" | tr 'A-Za-z' 'N-ZA-Mn-za-m'

# Binary to ASCII
python3 -c "print(bytes(int(b,2) for b in '01001000 01101001'.split()))"

# URL Decode
python3 -c "import urllib.parse; print(urllib.parse.unquote('%48%65%6c%6c%6f'))"
```

---

## 📝 Contoh Soal LKS & Pendekatannya

**Soal tipikal:** *"Diberikan file image.png. Temukan hidden message."*

```bash
# Workflow cepat:
file image.png
exiftool image.png
strings image.png | grep -i flag
binwalk image.png
binwalk -e image.png
zsteg image.png
steghide extract -sf image.png -p ""
```

**Soal tipikal 2:** *"File audio berisi pesan tersembunyi."*

```bash
file audio.wav
steghide extract -sf audio.wav -p ""
sox audio.wav -n spectrogram -o spec.png
strings audio.wav | grep -i flag
binwalk audio.wav
```

---

*Digital Forensics Cheatsheet | LKS Jawa Barat*
