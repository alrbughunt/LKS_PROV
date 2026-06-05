# LKS PROV Cyber Security 2026 — Professional CTF Battle Pack

Pack ini dibuat untuk persiapan cepat dan rapi menghadapi **CTF Jeopardy LKS Cyber Security**, khususnya bagian **Web Exploitation**, **Binary Exploitation**, dan **Digital Forensic**.

Tujuan pack ini: bukan sekadar kumpulan payload, tapi **sistem kerja saat lomba**: apa yang dibuka dulu, file diletakkan di mana, catatan ditulis bagaimana, tools dicek bagaimana, dan laporan/PoC disiapkan dari awal.

> Gunakan hanya untuk CTF, lab, VM pribadi, platform latihan resmi, atau target yang memang diberikan panitia.

## Struktur Profesional

```txt
LKS_PROV_CTF_ProPack_v2/
├── 00_START_HERE/        # strategi 3 hari, ritme lomba, prioritas solve
├── 01_WEB_EXPLOIT/       # playbook web exploit dan payload matrix
├── 02_BINARY_EXPLOIT/    # workflow binary, gdb, pwntools template
├── 03_FORENSIC/          # workflow forensic, pcap, stego, log, carving
├── 04_REPORTING/         # template writeup, evidence log, laporan PoC
├── 05_TOOLS/             # install script, verify script, checklist tools
├── 06_SIMULATION/        # simulasi 5 jam dan evaluasi performa
├── 99_ARCHIVE/           # simpan catatan lama, jangan campur dengan playbook utama
├── .gitignore
└── MIGRATION-GUIDE.md
```

## Cara Pakai Cepat

1. Buka `00_START_HERE/00-read-this-first.md`.
2. Ikuti `00_START_HERE/01-3-days-battle-plan.md`.
3. Saat latihan, gunakan checklist:
   - Web: `01_WEB_EXPLOIT/00-web-triage.md`
   - Binary: `02_BINARY_EXPLOIT/00-binary-triage.md`
   - Forensic: `03_FORENSIC/00-forensic-triage.md`
4. Saat simulasi, pakai `06_SIMULATION/5-hour-mock-ctf.md`.
5. Saat butuh laporan, isi `04_REPORTING/quick-writeup-template.md` dan `04_REPORTING/evidence-log.md`.

## Prinsip Lomba

- Jangan stuck lebih dari **25–30 menit** tanpa progress.
- Ambil quick win dulu: Web easy, Forensic easy, Binary strings/ret2win.
- Catat bukti sejak awal, jangan menunggu akhir.
- Saat latihan terakhir, hindari AI dan video; biasakan pakai catatan offline.
