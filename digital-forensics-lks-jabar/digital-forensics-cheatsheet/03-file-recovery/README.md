# 🗃️ File Recovery & Carving — Cheatsheet LKS Jawa Barat

## 📖 Konsep Dasar

**File Carving** = Proses menemukan dan memulihkan file dari raw data (disk image, memory dump) berdasarkan **magic bytes** (header/footer), tanpa bergantung pada filesystem.

**Kapan digunakan:**
- File terhapus tapi belum di-overwrite
- Filesystem rusak/corrupt
- Recover file dari image disk
- Extract file dari memory dump
- File embedded dalam file lain

---

## 🛠️ Tools Utama

### 1. `foremost` ⭐ Tool Utama
```bash
# Basic usage
foremost -i disk.img -o ./output

# Specify file type
foremost -t jpg,png,pdf,zip,doc -i disk.img -o ./output

# Dari physical disk
foremost -i /dev/sdb -o ./output

# Verbose
foremost -v -i disk.img -o ./output

# Konfigurasi custom
foremost -c /etc/foremost.conf -i disk.img -o ./output
```

**Output structure:**
```
./output/
├── audit.txt       ← Log semua file yang ditemukan
├── jpg/            ← Semua file .jpg
├── png/            ← Semua file .png
└── pdf/            ← Semua file .pdf
```

### 2. `photorec` / `testdisk` ⭐
```bash
# photorec - GUI untuk file recovery
sudo photorec disk.img

# testdisk - recovery partition table
sudo testdisk disk.img

# Install
sudo apt install testdisk
```

**photorec langkah-langkah:**
1. Pilih disk/image
2. Pilih partition
3. Pilih filesystem type
4. Pilih output folder
5. Let it run

### 3. `scalpel` — File Carving Advanced
```bash
sudo apt install scalpel

# Edit config: /etc/scalpel/scalpel.conf
# Uncomment tipe file yang diinginkan

scalpel disk.img -o ./output
scalpel -c scalpel.conf disk.img -o ./output
```

### 4. `binwalk` — Carve dari Binary
```bash
binwalk -e firmware.bin         # Extract semua
binwalk -D 'jpeg image:jpg' file.bin  # Extract tipe spesifik
binwalk --dd='.*' file.bin      # Extract semua signature
binwalk -Me image.jpg           # Recursive extract
```

### 5. `dd` — Raw Copy & Image
```bash
# Buat disk image
dd if=/dev/sdb of=disk.img bs=4096 status=progress

# Image dengan hash
dc3dd if=/dev/sdb of=disk.img hof=disk.md5 bs=512

# Mount image (read-only)
sudo mount -o ro,loop disk.img /mnt/evidence

# Ekstrak offset tertentu
dd if=disk.img of=partition.bin bs=512 skip=2048 count=1000000
```

### 6. `strings` + Manual Carving
```bash
# Find strings dalam binary
strings disk.img | grep -i "flag\|password\|secret"

# Hexdump untuk manual analysis
xxd disk.img | grep -i "PNG\|JFIF\|%PDF"
```

---

## 📐 Header & Footer Magic Bytes

| File Type | Header (Hex) | Footer (Hex) |
|-----------|-------------|-------------|
| **JPEG** | `FF D8 FF` | `FF D9` |
| **PNG** | `89 50 4E 47 0D 0A 1A 0A` | `49 45 4E 44 AE 42 60 82` |
| **GIF** | `47 49 46 38 37/39 61` | `00 3B` |
| **PDF** | `25 50 44 46` | `25 25 45 4F 46` |
| **ZIP** | `50 4B 03 04` | `50 4B 05 06` |
| **RAR** | `52 61 72 21 1A 07` | N/A |
| **DOCX** | `50 4B 03 04` (ZIP) | `50 4B 05 06` |
| **EXE** | `4D 5A` | N/A |
| **MP3** | `FF FB` / `49 44 33` | N/A |
| **WAV** | `52 49 46 46` | N/A |
| **AVI** | `52 49 46 46` | N/A |

---

## 🔍 Manual File Carving dengan Python

```python
#!/usr/bin/env python3
# manual_carve.py — Carve JPEG dari binary

with open('disk.img', 'rb') as f:
    data = f.read()

# JPEG header & footer
jpeg_header = bytes([0xFF, 0xD8, 0xFF])
jpeg_footer = bytes([0xFF, 0xD9])

count = 0
offset = 0

while True:
    start = data.find(jpeg_header, offset)
    if start == -1:
        break
    
    end = data.find(jpeg_footer, start) + 2
    if end == 1:  # Not found
        break
    
    jpeg_data = data[start:end]
    with open(f'carved_{count}.jpg', 'wb') as out:
        out.write(jpeg_data)
    
    print(f"[+] Found JPEG at offset {start:#x} → {end:#x} ({len(jpeg_data)} bytes)")
    count += 1
    offset = end

print(f"[*] Total: {count} files carved")
```

```python
#!/usr/bin/env python3
# carve_zip.py — Carve ZIP dari binary

with open('disk.img', 'rb') as f:
    data = f.read()

zip_header = bytes([0x50, 0x4B, 0x03, 0x04])  # PK..
zip_eocd = bytes([0x50, 0x4B, 0x05, 0x06])    # End of Central Directory

count = 0
offset = 0

while True:
    start = data.find(zip_header, offset)
    if start == -1:
        break
    
    end = data.find(zip_eocd, start)
    if end == -1:
        break
    end += 22  # EOCD minimum size
    
    with open(f'carved_{count}.zip', 'wb') as out:
        out.write(data[start:end])
    
    print(f"[+] ZIP at {start:#010x} → {end:#010x}")
    count += 1
    offset = end

print(f"[*] Total: {count} ZIP files")
```

---

## 💾 Filesystem Analysis

### Melihat Struktur Disk Image
```bash
# List partitions
mmls disk.img
fdisk -l disk.img

# Info filesystem
fsstat disk.img
fsstat -o 2048 disk.img     # dengan offset

# List files (termasuk deleted)
fls -r disk.img              # recursive
fls -rd disk.img             # deleted only
fls -rp disk.img             # full path
```

### Mount & Akses
```bash
# Mount image
sudo mount -o ro,loop disk.img /mnt/evidence

# Mount dengan offset (partisi tertentu)
sudo mount -o ro,loop,offset=$((2048*512)) disk.img /mnt/evidence

# Unmount
sudo umount /mnt/evidence
```

### Recover File Terhapus dengan `tsk_recover`
```bash
tsk_recover disk.img ./recovered/      # Recover semua
tsk_recover -e disk.img ./recovered/   # Unallocated space
```

### `icat` — Extract File by Inode
```bash
fls -r disk.img | grep "secret.txt"  # Dapatkan inode
icat disk.img 12345 > secret.txt     # Extract by inode
```

---

## 🔄 Workflow File Recovery

```
1. BUAT IMAGE (jika fisik)
   └── dd if=/dev/sdX of=evidence.img bs=512 status=progress

2. VERIFIKASI INTEGRITAS
   └── md5sum evidence.img > evidence.md5

3. ANALISIS STRUKTUR
   ├── mmls evidence.img          → lihat partisi
   └── fsstat evidence.img        → filesystem info

4. CARVING
   ├── foremost -i evidence.img -o ./carved
   ├── binwalk -Me evidence.img
   └── photorec evidence.img

5. RECOVER DELETED FILES
   ├── fls -rd evidence.img       → list deleted
   └── tsk_recover evidence.img  → recover semua

6. ANALISIS FILE HASIL
   └── file, exiftool, strings pada setiap file
```

---

## 📊 Autopsy — GUI Forensics

```bash
# Install & run
sudo apt install autopsy
sudo autopsy

# Buka browser: http://localhost:9999/autopsy

# Workflow Autopsy:
# 1. New Case → isi detail kasus
# 2. Add Host → nama komputer
# 3. Add Image → pilih disk.img
# 4. Analyze → File Analysis / Keyword Search / File Type
# 5. Unallocated Space → untuk file carving
```

---

## 🧪 Latihan Soal LKS Tipikal

**Soal:** *"Diberikan file evidence.img. Temukan file-file tersembunyi/terhapus dan extract flagnya."*

```bash
# Step 1: Identifikasi
file evidence.img
mmls evidence.img

# Step 2: Carving otomatis
foremost -v -i evidence.img -o ./output
ls -la ./output/

# Step 3: Cek hasil
cat ./output/audit.txt           # Lihat semua file ditemukan
ls ./output/jpg/ ./output/png/ ./output/pdf/

# Step 4: Analisis tiap file
for f in ./output/jpg/*.jpg; do exiftool "$f"; done
strings ./output/jpg/00000000.jpg | grep flag

# Step 5: Jika ada ZIP
cd ./output/zip/
unzip -l 00000000.zip
unzip 00000000.zip -d ./unzipped/
```

---

*Digital Forensics Cheatsheet | LKS Jawa Barat*
