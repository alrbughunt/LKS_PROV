# Read This First

Kamu tinggal punya waktu pendek, jadi cara mainnya harus tajam:

```txt
Web Exploit : poin utama
Forensic    : quick win dan backup poin
Binary      : ambil basic, jangan tenggelam di heap/ROP berat
```

## Pola Kerja Setiap Soal

```txt
Baca deskripsi → cek attack surface → coba jalur termudah → catat bukti → submit flag
```

## Rule Anti-Stuck

Kalau 25–30 menit tidak ada progress nyata, pindah.

Progress nyata contohnya:

- Ada endpoint baru.
- Ada leak/error berbeda.
- Ada file hasil extract.
- Ada offset binary.
- Ada clue flag.

Payload random tanpa feedback bukan progress.

## Yang Harus Siap Sebelum Lomba

- Tools sudah dicek dengan `05_TOOLS/verify-tools.sh`.
- Catatan offline sudah rapi.
- Template laporan sudah siap.
- Folder evidence sudah siap: `evidence/screenshots/`, `evidence/extracted/`, `evidence/tmp/`.
