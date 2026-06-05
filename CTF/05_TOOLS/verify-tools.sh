#!/usr/bin/env bash
tools=(python3 gdb file strings objdump readelf checksec curl nmap wireshark tshark exiftool binwalk foremost steghide john tmux jq)
for t in "${tools[@]}"; do
  if command -v "$t" >/dev/null 2>&1; then echo "[OK] $t"; else echo "[MISS] $t"; fi
done
python3 - <<'PY'
try:
    import pwn
    print('[OK] pwntools')
except Exception:
    print('[MISS] pwntools')
PY
