#include "types.h"

uint8_t default_entry = 2;
bool show_menu = false;

static const BootLoaderEntry entries[] = {
	{u"Pavon Linux", u"pavonlinuz", u"quiet root=/dev/nvme0n1p3 rw fstype=ext4 init=/sbin/pinit"},
	{u"Gentoo", u"vmlinuz", u"quiet root=/dev/nvme0n1p2 ro fstype=ext4"},
	{u"PKernel", u"pkernel", u""},
	{u"Pavon VM", u"vmlinuz", u"initcall_debug quiet root=/dev/sda1 rw fstype=vfat init=/sbin/init"},
	{u"Pavon Linux USB", u"vmlinuz",
		u"rootwait root=PARTUUID=45e8184f-fd5c-4e77-a94e-b16a4a9823cb rw fstype=ext4"},
	{u"Pavon stinit quiet initcall debug", u"pavonlinuz", u"initcall_debug quiet root=/dev/nvme0n1p3 rw fstype=ext4 init=/sbin/pinit"},
	{u"Pavon sinit usb off", u"vmlinuz", u"quiet root=/dev/nvme0n1p3 rw fstype=ext4 init=/sbin/pinit usbcore.authorized_default=0"},
	{u"Pavon /sbin/pinit", u"vmlinuz", u"root=/dev/nvme0n1p3 rw fstype=ext4 init=/sbin/pinit"},
	{u"Pavon sinit", u"pavonlinuz", u"quiet root=/dev/nvme0n1p3 rw fstype=ext4 init=/sbin/sinit"},
};
