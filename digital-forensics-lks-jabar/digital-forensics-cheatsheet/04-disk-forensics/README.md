# 💿 Disk Forensics — Cheatsheet LKS Jawa Barat

## 📖 Konsep Dasar

**Disk Forensics** = Investigasi media penyimpanan (HDD, SSD, USB, SD Card) untuk mencari bukti digital.

### Prinsip Utama: Jangan Ubah Evidence!
```
Chain of Custody:
  Original Disk → Write Blocker → Forensic Copy (Image) → Analisis
```

**Write Blocker** = Perangkat yang mencegah penulisan ke disk original saat imaging.

---

## 🗂️ Struktur Disk

### MBR (Master Boot Record)
```
Offset 0x000 – 0x1BD : Bootstrap code (446 bytes)
Offset 0x1BE – 0x1FD : Partition Table (4 entries × 16 bytes)
Offset 0x1FE – 0x1FF : Boot Signature (0x55 0xAA)
```

### Partition Table Entry (16 bytes)
```
Byte 0    : Status (0x80 = bootable, 0x00 = tidak)
Byte 1-3  : CHS First Sector
Byte 4    : Partition Type
Byte 5-7  : CHS Last Sector
Byte 8-11 : LBA First Sector
Byte 12-15: Partition Size (sectors)
```

### Partition Types Penting
| Hex | Type |
|-----|------|
| `0x07` | NTFS / exFAT |
| `0x83` | Linux ext2/3/4 |
| `0x82` | Linux swap |
| `0x0B` | FAT32 (CHS) |
| `0x0C` | FAT32 (LBA) |
| `0x05` | Extended |
| `0xEE` | GPT |

---

## 🛠️ Tools & Commands

### Disk Imaging

#### `dd` — Standar
```bash
# Buat image dari disk
dd if=/dev/sdb of=evidence.img bs=4096 status=progress

# Buat image + verifikasi
dd if=/dev/sdb of=evidence.img bs=512 conv=noerror,sync status=progress

# Split image (tiap 2GB)
dd if=/dev/sdb | split -b 2G - evidence.img.

# Compress
dd if=/dev/sdb | gzip -c > evidence.img.gz
```

#### `dc3dd` — Forensic Grade
```bash
# Imaging dengan hash otomatis
dc3dd if=/dev/sdb of=evidence.img hof=evidence.md5 bs=512 progress=on

# Dengan SHA256
dc3dd if=/dev/sdb of=evidence.img hash=sha256 hof=evidence.sha256
```

#### `dcfldd` — Forensic dd
```bash
dcfldd if=/dev/sdb of=evidence.img bs=512 hash=md5 hashlog=evidence.md5
```

#### `ewfacquire` — E01 Format
```bash
# Buat E01 (EnCase format)
ewfacquire /dev/sdb
ewfinfo evidence.E01
ewfmount evidence.E01 /mnt/ewf/
```

---

### Analisis Partisi

#### `mmls` — List Partitions
```bash
mmls disk.img
mmls -t dos disk.img   # MBR/DOS
mmls -t gpt disk.img   # GPT

# Output:
# Slot  Start       End         Length      Description
# 00:   Meta        0           0           Primary Table (#0)
# 01:   -------     0           0           Unallocated
# 02:   00:00       2048        1026047     Linux (0x83)
```

#### `fdisk` — Partition Info
```bash
fdisk -l disk.img
fdisk -l -u disk.img   # Tampilkan dalam sectors

# Hitung offset untuk mount:
# offset = start_sector × 512
# Jika start = 2048 → offset = 2048 × 512 = 1048576
```

---

### Filesystem Analysis

#### `fsstat` — Filesystem Statistics
```bash
fsstat disk.img                    # Auto-detect filesystem
fsstat -o 2048 disk.img            # Dengan offset (sectors)
fsstat -f ext4 disk.img            # Spesifik filesystem
```

#### `fls` — File Listing (termasuk deleted)
```bash
fls disk.img                       # Root directory
fls -r disk.img                    # Recursive
fls -rd disk.img                   # Deleted files only
fls -rp disk.img                   # Full path
fls -o 2048 disk.img               # Dengan offset

# Output format:
# r/r = regular file
# d/d = directory
# r/- = deleted file (!)
# -/r = file dengan inode yang ada tapi tidak di-list
```

#### `istat` — Inode Statistics
```bash
istat disk.img 12345               # Info inode #12345
istat -o 2048 disk.img 12345
```

#### `icat` — Extract File by Inode
```bash
icat disk.img 12345 > recovered.txt     # Extract file by inode
icat -r disk.img 12345 > recovered.txt  # Termasuk slack space
```

#### `blkcat` — Extract Data by Block
```bash
blkcat disk.img 54321              # Tampilkan block
blkcat disk.img 54321 > block.bin  # Simpan
```

#### `jls` / `jcat` — Journal Analysis
```bash
jls disk.img                       # List journal
jcat disk.img 3 > journal.bin      # Extract journal entry
```

---

### Mount & Browse

```bash
# Mount ext4 (read-only)
sudo mount -t ext4 -o ro,loop disk.img /mnt/evidence

# Mount dengan offset (partition)
sudo mount -o ro,loop,offset=1048576 disk.img /mnt/evidence

# Mount NTFS
sudo mount -t ntfs-3g -o ro,loop disk.img /mnt/evidence

# Gunakan offset dari mmls (multiply by 512)
OFFSET=$(( 2048 * 512 ))
sudo mount -o ro,loop,offset=$OFFSET disk.img /mnt/evidence

# Unmount
sudo umount /mnt/evidence
```

---

### Recover Deleted Files

```bash
# List semua deleted
fls -rd disk.img

# Recover satu file
icat disk.img INODE_NUMBER > filename.ext

# Recover semua (unallocated space)
tsk_recover disk.img ./recovered/
tsk_recover -e disk.img ./recovered/    # Unallocated only
tsk_recover -f fat32 disk.img ./recovered/   # Spesifik filesystem
```

---

## 📁 NTFS Artifacts

### Master File Table (MFT)
```bash
# Extract MFT
icat disk.img 0 > mft.raw

# Parse MFT dengan mftparser
python3 mftparser.py mft.raw

# Dengan Autopsy/Sleuthkit
fls -r disk.img | grep "\$MFT"
```

### NTFS Alternate Data Streams (ADS)
```bash
# Temukan ADS
fls -r disk.img | grep ":"

# Extract ADS
icat disk.img INODE:STREAM_ID > ads_content
```

### Windows Registry (dari disk image)
```bash
# Lokasi registry hives di NTFS:
# /Windows/System32/config/SAM        → User accounts & hashes
# /Windows/System32/config/SYSTEM     → System config
# /Windows/System32/config/SOFTWARE   → Installed software
# /Windows/System32/config/SECURITY   → Security policies
# /Users/<user>/NTUSER.DAT            → User profile

# Extract dan analisis:
cp /mnt/evidence/Windows/System32/config/SAM ./SAM
regripper -r SAM -p samparse > sam_output.txt
```

---

## 🔢 Penting: Offset Calculation

```bash
# Dari mmls output:
# Slot 02: Start = 2048, Length = 1026048

# Offset dalam bytes:
OFFSET = 2048 × 512 = 1048576

# Mount:
sudo mount -o loop,ro,offset=1048576 disk.img /mnt/part

# Untuk TSK tools: gunakan -o dalam sectors (bukan bytes)
fls -o 2048 disk.img      # Benar
fsstat -o 2048 disk.img   # Benar
```

---

## 🔄 Workflow Disk Forensics

```
1. AKUISISI (Imaging)
   ├── Pasang write blocker
   ├── dc3dd if=/dev/sdX of=evidence.img hash=sha256 hof=evidence.sha256
   └── Verifikasi: sha256sum evidence.img

2. DOKUMENTASI
   └── Catat: MD5/SHA256, tanggal, waktu, chain of custody

3. ANALISIS STRUKTUR
   ├── mmls evidence.img          → struktur partisi
   ├── fsstat evidence.img        → filesystem info
   └── mount read-only untuk browse

4. TIMELINE & ARTIFACTS
   ├── fls -r evidence.img        → semua file
   ├── fls -rd evidence.img       → deleted files
   └── mactime → timeline analysis

5. RECOVERY
   ├── icat untuk file spesifik
   ├── tsk_recover untuk semua
   └── foremost/scalpel untuk carving

6. ANALISIS KONTEN
   └── strings, grep, exiftool pada file hasil
```

---

## 📊 Hash Verification

```bash
# Buat hash sebelum dan sesudah
md5sum evidence.img > evidence.md5
sha256sum evidence.img > evidence.sha256

# Verifikasi
md5sum -c evidence.md5
sha256sum -c evidence.sha256

# Hashing dengan dcfldd
dcfldd if=evidence.img of=copy.img bs=512 hash=sha256 hashlog=verify.sha256
```

---

## 🖥️ Autopsy — GUI Workflow

```
1. Buka Autopsy → New Case
2. Case Name: [Nama Kasus], Base Directory: [Folder]
3. Add Data Source → Disk Image/VM File
4. Pilih evidence.img
5. Configure Ingest Modules:
   ✓ Recent Activity
   ✓ Hash Lookup
   ✓ File Type Identification
   ✓ Embedded File Extractor
   ✓ Keyword Search
6. Finish → Tunggu ingest selesai
7. Explore:
   - Data Sources → browse filesystem
   - Deleted Files → file yang dihapus
   - File Views → by type, by MIME
   - Results → Keyword Hits
   - Timeline → urutan waktu
```

---

*Digital Forensics Cheatsheet | LKS Jawa Barat*
