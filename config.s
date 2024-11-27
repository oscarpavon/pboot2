;for a nice menu entry
name equ du
kernel equ du
arguments equ du

;use to configure the bootloader
DEBUG = 1

show_menu db 1

boot_entry db 1;start from 1

entries du 0;start entries
  name "Pavon Linux",0
  kernel "pavonlinuz",0
  arguments "quiet root=/dev/nvme0n1p3 rw fstype=ext4 init=/sbin/pinit",0
  name "Gentoo Linux",0
  kernel "vmlinuz",0
  arguments "quiet root=/dev/nvme0n1p2 ro fstype=ext4",0
  name "PKernel",0
  kernel "pkernel",0
  arguments "",0
  name "VM",0
  kernel "vmlinuz",0
  arguments "root=/dev/sda1 rw fstype=fat",0
db 0xFF;end entries


