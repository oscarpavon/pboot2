kernel_name dq ?
kernel_arguments dq ?

kernel_test du 'vmlinuz',0
kernel_parameters_test du 'root=/dev/sda1 rw fstype=fat',0

kernel_name_buffer rw 32
kernel_parameters_buffer rw 128

kernel_name_memory dq ?

;menu
new_line du 13,10,0
selected_entry_sign du '*',0

entries_count db 0

;input
input_key du 0
          du 0

handles_size dq 0
handles dq ?
FileSystemDevicePath dq ?

max_size dq 0xFFFFFFFFFFFFFFFF

BootLoaderImage dq ?
FileSystemProtocol dq ?
RootDirectory dq ?
KernelFile dq ?
KernelFileSize dq ?
KernelLoadedImage dq ?
KernelImageHandle dq ?
DevicePathProtocol rq 1
readed rq 1

boot_services dq ?
open_protocol dq ?

allocated_memory dq 0
arguments_memory dq 0
arguments_char_count dd 0

;menu debug
parsed_entry du "parsed entry2",13,10,0


;messages
welcome du "pboot2",13,10,0
boot_services_configured du "Boot services configured",13,10,0
open_protocol_configured du "Open protocol configured",13,10,0
menu_configured du "Menu configured",13,10,0
kernel_file_closed du "Kernel file closed",13,10,0
root_directoy_closed du "Root directory closed",13,10,0
kernel_arguments_configured du "Kernel arguments configured",13,10,0
memory_allocated_msg du 'Allocated pool',13,10,0
open_protocol_ok du 'Open protocol OK',13,10,0
got_loaded_image du "Got loaded image",13,10,0
got_file_size du "Got file size",13,10,0
file_loaded_to_memory du "File loaded to memory",13,10,0
volume_opened du "Volume opened",13,10,0
image_loaded du "Image loaded",13,10,0
setted_max_file du "Setted max file",13,10,0
file_opened du "File opened",13,10,0
got_device_path du "Got device path",13,10,0

got_loaded_kernel_image du "Got loaded kernel image",13,10,0

buffer_too_small_msg du 'Buffer too small',13,10,0

kernel_not_readed_msg du 'Kernel not readed',13,10,0

all_ok_msg du 'All OK',13,10,0

;error messages
unsupported_msg du 'Unsupported',13,10,0
invalid_parameter_msg du 'Invalid Parameter',13,10,0
not_found_msg du 'Not found',13,10,0
load_error_msg du 'Load error',13,10,0

error_open_loaded_image_msg du 'Error open loaded image',13,10,0
error_memory_msg du 'Error allocating pool',13,10,0
error_msg du 'Error',13,10,0
error_open_file_msg du 'Error open file',13,10,0

EFI_SYSTEM_TABLE dq ?
EFI_BOOT_LOADER_HANDLE dq ?

;Protocols GUID
EFI_LOADED_IMAGE_PROTOCOL_GUID dd 0x5B1B31A1
                                dw 0x9562,0x11d2
                                db 0x8E,0x3F,0x00,0xA0,0xC9,0x69,0x72,0x3B

EFI_SIMPLE_FILE_SYSTEM_PROTOCOL_GUID dd 0x0964e5b22
                                      dw 0x6459, 0x11d2
                                      db 0x8e,0x39,0x00,0xa0,0xc9,0x69,0x72,0x3b

EFI_DEVICE_PATH_PROTOCOL_GUID dd 0x09576e91
                              dw 0x6d3f,0x11d2
                              db 0x8e,0x39,0x00,0xa0,0xc9,0x69,0x72,0x3b


memory_device_path db EFI_HARDWARE_DEVICE_PATH
                    db EFI_MEMORY_MAPPED_DEVICE_PATH
                    db 24;size of memory device path
                    db 0;right shiftted 8 bit
                    dd EFI_MEMORY_LOADER_DATA
                    dq 0;start address
                    dq 0;end address
                    ;end device path
                    db EFI_END_HARDWARE_DEVICE_PATH
                    db EFI_END_ENTIRE_DEVICE_PATH
                    db 4;size of device path
                    db 0;right 4 siftted 8 bit


;debug
hex_table db '0123456789abcdef'
decimal_buffer du '000000000',13,10,0
hex_buffer db 'FFFFFFFFFFFFFFFF'
hex_buffer_unicode du '0000000000000000',13,10,0
