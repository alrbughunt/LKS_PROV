# Migration Guide — dari Folder Lama ke Struktur Profesional

Kalau repo lama kamu hanya punya:

```txt
web-exploit/
├── File-Inclusion.md
├── sql.md
├── xss.md
└── xxe.md
```

rapikan menjadi:

```txt
01_WEB_EXPLOIT/
├── 00-web-triage.md
├── 01-sqli.md
├── 02-xss.md
├── 03-command-injection.md
├── 04-lfi-rfi-path-traversal.md
├── 05-idor-broken-access-control.md
├── 06-jwt-api-ssrf.md
├── 07-xxe.md
└── 08-upload-bypass.md
```

## Penempatan File Lama

| File Lama | Pindah ke | Tindakan |
|---|---|---|
| `sql.md` | `01_WEB_EXPLOIT/01-sqli.md` | Gabungkan payload + checklist |
| `xss.md` | `01_WEB_EXPLOIT/02-xss.md` | Tambahkan reflected/stored/admin bot note |
| `File-Inclusion.md` | `01_WEB_EXPLOIT/04-lfi-rfi-path-traversal.md` | Gabungkan LFI, RFI, traversal, wrapper PHP |
| `xxe.md` | `01_WEB_EXPLOIT/07-xxe.md` | Tambahkan XML parser clue dan file target |

Catatan lama yang belum rapi taruh dulu di `99_ARCHIVE/`, jangan dicampur dengan playbook utama.

## Format Nama File

Pakai angka agar urut di GitHub:

```txt
00-checklist.md
01-topic-basic.md
02-topic-medium.md
03-template.md
```

## Commit Profesional

```bash
git add .
git commit -m "structure: organize LKS CTF preparation pack"
git commit -m "docs: add web exploitation playbooks"
git commit -m "docs: add binary and forensic triage workflows"
git commit -m "tools: add CTF environment verification scripts"
```
