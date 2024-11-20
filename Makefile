virtual_machine_path := /root/virtual_machine/disk/EFI/BOOT

CC := clang
LD := ld.lld

CFLAGS := -ffreestanding -MMD -mno-red-zone -std=c11 \
	-target x86_64-unknown-windows
LDFLAGS := -flavor link -subsystem:efi_application -entry:efi_main

fasm: main.s
	fasm main.s BOOTX64.EFI
clang: main.o
	$(LD) $(LDFLAGS) main.o -out:BOOTX64.EFI

main.o: main.c config.h types.h efi.h
	$(CC) $(CFLAGS) -c main.c -o main.o

clean:
	rm -f *.o
	rm -f *.d
	rm -f BOOTX64.EFI

install:
	cp BOOTX64.EFI $(virtual_machine_path)/BOOTX64.EFI

release:
	cp BOOTX64.EFI /boot/EFI/asm/asmboot.efi

