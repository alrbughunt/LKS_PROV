# File Analysis & Image Stego

## Magic Bytes

```txt
PNG  : 89 50 4E 47
JPG  : FF D8 FF
ZIP  : 50 4B 03 04
PDF  : 25 50 44 46
ELF  : 7F 45 4C 46
```

## Extract Embedded

```bash
binwalk -e file
foremost file
```

## JPG

```bash
steghide info image.jpg
steghide extract -sf image.jpg
```

## PNG

```bash
zsteg image.png
zsteg -a image.png
```

## Visual Tools

```txt
stegsolve.jar
aperisolve
```

Tips: jangan percaya extension. Cek metadata, strings, akhir file, dan hasil binwalk.
