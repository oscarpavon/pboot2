DEBUG = 1

show_menu db 1

entries db 0;start entries
  du "Pavon Linux",13,10,0
  du "Gentoo Linux",13,10,0
  du "Gentoo2 Linux",13,10,0
  du "Gentoo3 Linux",13,10,0
db 0xFF;end entries



kernel_name du 'vmlinuz',0

arguments du "root=/dev/sda1 rw fstype=fat",0
