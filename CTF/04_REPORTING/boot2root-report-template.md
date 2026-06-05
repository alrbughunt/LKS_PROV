# Boot2Root / PoC Report Template

## Executive Summary

Target berhasil dianalisis melalui enumerasi, eksploitasi, dan validasi flag. Celah utama terdapat pada `[service/fitur]` dengan dampak `[dampak]`.

## Scope

```txt
Target:
Tanggal:
Waktu:
Tools:
```

## Enumeration

```bash
nmap -sC -sV -oN nmap.txt TARGET
```

| Port | Service | Version | Notes |
|---|---|---|---|
| 80 | HTTP | - | Web app |

## Exploitation Steps

```txt
1. ...
2. ...
3. ...
```

## Flags

```txt
User flag:
Root flag:
```

## Recommendation

| Finding | Risk | Recommendation |
|---|---|---|
| Weak access control | High | Enforce server-side authorization |
| Command injection | Critical | Avoid shell execution and validate input |
