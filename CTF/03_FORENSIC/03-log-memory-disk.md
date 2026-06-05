# Log, Memory, Disk

## Log Analysis

```bash
grep -iE "flag|ctf|admin|login|password|secret" *.log
grep -iE "union|select|sleep|or 1=1|/etc/passwd|cmd=" *.log
awk '{print $1}' access.log | sort | uniq -c | sort -nr | head
awk '{print $7}' access.log | sort | uniq -c | sort -nr | head
```

## Memory Basic

```bash
strings memory.raw | grep -iE "flag|ctf|password|secret"
vol -f memory.raw windows.info
vol -f memory.raw windows.pslist
vol -f memory.raw windows.cmdline
vol -f memory.raw windows.netscan
```

## Disk Basic

```bash
file disk.img
fdisk -l disk.img
binwalk disk.img
strings disk.img | grep -iE "flag|password|secret"
foremost -i disk.img -o output_foremost
```
