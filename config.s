DEBUG = 1

name equ du
kernel equ du

show_menu db 1

boot_entry db 1;start from 1

entries du 0;start entries
  name "VM Linux",0
  kernel "vmlinuz",0
  du "root=/dev/sda1 rw fstype=fat",0
  name "Pavon Linux",0
  kernel "vmlinuz2",0
  du "root=/dev/sda1 rw fstype=fat",0
  name "Gentoo Linux",0
  kernel "vmlinuz3",0
  du "root=/dev/sda1 rw fstype=fat",0
db 0xFF;end entries

