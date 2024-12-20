virtual_machine_path := /root/virtual_machine/disk/EFI/BOOT

BOOTX64.EFI: main.s config.s data.s std.s const.s menu.s input.s console.s error.s file.s
	fasm main.s BOOTX64.EFI

clean:
	rm -f BOOTX64.EFI

install:
	cp BOOTX64.EFI $(virtual_machine_path)/BOOTX64.EFI

release:
	cp BOOTX64.EFI /boot/EFI/asm/asmboot.efi

