#!/bin/bash

echo 'Use current terminal as VGA output...'
mkdir -p ~/.local/qemu-vga
rm -f ~/.local/qemu-vga/vga.tty
echo "$(shell tty)" > ~/.local/qemu-vga/vga.tty
clear
trap 'stty echo; echo -e "\n[INFO] Terminal echo restored."' EXIT INT TERM; \
stty -echo; \
cat
