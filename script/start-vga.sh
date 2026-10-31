#!/bin/bash

echo 'Use current terminal as VGA output...'
mkdir -p ~/.local/qemu-vga
rm -f ~/.local/qemu-vga/vga.tty
echo "$(tty)" > ~/.local/qemu-vga/vga.tty
clear
trap 'stty echo; rm -f ~/.local/qemu-vga/vga.tty; echo -e "\n[INFO] Terminal echo restored."' EXIT INT TERM; \
stty -echo; \
cat
