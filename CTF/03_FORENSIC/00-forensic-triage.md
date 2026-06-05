# Forensic Triage Checklist

## Universal

```bash
file sample
ls -lah sample
sha256sum sample
strings sample | less
strings sample | grep -iE "flag|ctf|password|secret|key"
xxd sample | head
binwalk sample
exiftool sample
```

## Jika Gambar

```bash
exiftool image.jpg
strings image.jpg
binwalk -e image.jpg
steghide extract -sf image.jpg
zsteg image.png
```

## Jika PCAP

```txt
Wireshark → Statistics → Protocol Hierarchy
Wireshark → Follow TCP Stream
Wireshark → Export Objects → HTTP
Filter: frame contains "flag"
```

## Jika Log

```bash
grep -iE "flag|admin|login|union|select|passwd|shell|cmd|error" *.log
```

## Jika Archive

```bash
7z l file.zip
zip2john file.zip > hash.txt
john hash.txt
john --show hash.txt
```
