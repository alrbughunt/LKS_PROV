# PCAP / Wireshark

## Filter Penting

```txt
http
dns
tcp
ftp
icmp
frame contains "flag"
tcp contains "flag"
http.request
http.response.code == 200
```

## Workflow

```txt
1. Protocol Hierarchy
2. Conversations
3. Follow TCP Stream
4. Export Objects HTTP/SMB
5. Cek DNS query panjang
6. Cek POST request, cookie, auth header
```

## tshark

```bash
tshark -r capture.pcap -Y 'frame contains "flag"'
tshark -r capture.pcap -Y http.request -T fields -e http.host -e http.request.uri
```
