
handles_size dq 0
handles dq ?
FileSystemDevicePath dq ?


BootLoaderImage dq ?
KernelImageHandle dq ?
FileSystemProtocol dq ?
RootDirectory dq ?
KernelFile dq ?
KernelFileSize dq ?
DevicePathProtocol rq 1
readed rq 1

boot_services dq ?
open_protocol dq ?

allocated_memory dq 0

kernel_name du 'vmlinuz',0

;messages
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
