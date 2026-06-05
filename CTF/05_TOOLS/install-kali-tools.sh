#!/usr/bin/env bash
set -e
sudo apt update
sudo apt install -y git curl wget python3 python3-pip python3-venv build-essential gdb binutils file   wireshark tshark exiftool binwalk foremost steghide john unzip p7zip-full   nmap netcat-traditional tmux jq ripgrep
python3 -m pip install --user --upgrade pwntools ropper
printf "
[+] Done. Run ./verify-tools.sh
"
