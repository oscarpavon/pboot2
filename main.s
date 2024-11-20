format pe64 efi
include "efi_constants.inc"


;[rsp+8*0] ; shadow space for parm one (volitile)
;[rsp+8*1] ; shadow space for parm two (volitile)
;[rsp+8*2] ; shadow space for parm three (volitile)
;[rsp+8*3] ; shadow space for parm four (volitile)
;[rsp+8*4] ; param five must be stored here
;[rsp+8*5] ; param six must be stored here
;;Calling convertion parameters rcx, rdx, r8, r9 
;;return value are in rax
;;need 32 bytes of shadow space
;; shadow space is dedicated memory for saving four registers, precisely: rcx, rdx, r8 and r9

section '.text' code executable readable

entry $
 
  push rbx;align stack to 16 bytes
  
  mov [EFI_SYSTEM_TABLE], rdx
  mov [EFI_BOOT_LOADER_HANDLE], rcx



  ;get loader image
  mov r11,[EFI_SYSTEM_TABLE]
  mov r12,[r11 + EFI_BOOT_SERVICES]
 ; mov r13, [r12 + EFI_OPEN_PROTOCOL]

  mov rcx, [EFI_BOOT_LOADER_HANDLE]
  mov rdx, EFI_LOADED_IMAGE_PROTOCOL_GUID
  mov r8, BootLoaderImage
  mov r9, [EFI_BOOT_LOADER_HANDLE]


  sub rsp,8*6

  mov rax, EFI_OPEN_PROTOCOL_BY_HANDLE_PROTOCOL
  mov qword [rsp+8*5],rax
  mov rax, 0
  mov qword [rsp+8*4],rax

  call qword [r12+EFI_OPEN_PROTOCOL]

  add rsp,8*6

  cmp rax, EFI_SUCCESS
  jne error

  mov rdx,got_loaded_image
  call print


  call get_device_path

  jmp open_volume

  ;get file system protocol
  mov r13, [BootLoaderImage]
  mov rcx, [r13 + DEVICE]
  mov rdx, EFI_SIMPLE_FILE_SYSTEM_PROTOCOL_GUID
  mov r8, FileSystemProtocol
  mov r9, [EFI_BOOT_LOADER_HANDLE]

  sub rsp,8*6

  mov rax, EFI_OPEN_PROTOCOL_BY_HANDLE_PROTOCOL
  mov qword [rsp+8*5],rax
  mov rax, 0
  mov qword [rsp+8*4],rax

  call qword [r12+EFI_OPEN_PROTOCOL]

  add rsp,8*6
 
  cmp rax, EFI_SUCCESS
  jne error
  
  open_volume:
  ;open volume
  sub rsp, 8*4
  mov rax, [FileSystemProtocol]
  
  mov rcx, [FileSystemProtocol]
  mov rdx, RootDirectory
  call qword [rax+OPEN_VOLUME]

  add rsp, 8*4

  cmp rax, EFI_SUCCESS
  jne error
  
  mov rdx,volume_opened
  call print

  ;open file 
  sub rsp, 8*6
  mov rax, [RootDirectory]
  mov rcx, [RootDirectory] 
  mov rdx, KernelFile
  mov r8, kernel_name
  mov r9, EFI_FILE_MODE_READ
  mov r13, EFI_FILE_READ_ONLY
  mov qword [rsp+8*4], r13

  call qword [rax+OPEN]
  add rsp, 8*6
   
  cmp rax, EFI_SUCCESS
  jne error_open_file

  mov rdx,file_opened
  call print
 
  ;get file size
  sub rsp, 8*4
  mov rax, [KernelFile]
  mov rcx, [KernelFile] 
  mov rdx, MAX_FILE_POSITION
  call qword [rax+SET_POSITION]
  add rsp, 8*4

  cmp rax, EFI_SUCCESS
  jne error


  sub rsp, 8*4
  mov rax, [KernelFile]
  mov rcx, [KernelFile] 
  mov rdx, KernelFileSize
  call qword [rcx+GET_POSITION]
  add rsp, 8*4

  cmp rax, EFI_SUCCESS
  jne error

  mov rax,[KernelFileSize]
  ;call print_decimal

  ;allocate memory for kernel file
 
  sub rsp,8*4
  mov r11,[EFI_SYSTEM_TABLE]
  mov r12,[r11 + EFI_BOOT_SERVICES]

  mov rcx,EFI_MEMORY_LOADER_DATA
  mov rdx, [KernelFileSize]
  mov r8, allocated_memory
  call qword [r12+EFI_ALLOCATE_POOL]
  add rsp,8*4

  cmp rax, EFI_SUCCESS
  jne error

  ;load kernel to memory

  sub rsp, 8*4
  mov rax, [KernelFile]
  mov rcx, [KernelFile] 
  mov rdx, 0;we start from the zero position
  call qword [rax+SET_POSITION]
  add rsp, 8*4
  cmp rax, EFI_SUCCESS
  jne error

  ;read kernel file to memory

  mov r14,0 
  read_kernel:
  mov rcx,[KernelFile]
  mov r13,[KernelFileSize]
  sub r13,r14
  mov [readed],r13;total to read
  mov rdx,readed
  mov r15,[allocated_memory]
  lea r8, [r15+r14]
  ;mov r8,allocated_memory
  sub rsp,4*8
  call qword [rcx+READ]
  add rsp,4*8
  cmp rax,EFI_SUCCESS
  jne error
  mov rax, [readed]
  mov rdx, [KernelFileSize]
  cmp rax,rdx
  jne print_not_readed

read_continue:
  add r14,[readed]
  cmp r14,[KernelFileSize]
  je continue
  jl read_kernel



 
  ;close kernel file after reading
  add rsp,32
  mov r15, [KernelFile]
  mov rcx,[KernelFile]
  call qword [r15+CLOSE]
  sub rsp,32
  cmp rax,EFI_SUCCESS
  jne error
 
  ;close root directory
  add rsp,32
  mov r15, [RootDirectory]
  mov rcx,[RootDirectory]
  call qword [r15+CLOSE]
  sub rsp,32
  cmp rax,EFI_SUCCESS
  jne error
  
  
  continue:

  mov rdx,[allocated_memory]
  ;call print

  mov rax,[KernelFileSize]
  call print_decimal

 
  ;create device memory path
  lea rax,[memory_device_path]
  mov rdx, [allocated_memory]
  mov qword [rax+OFFSET_START_ADDRESS],rdx
  mov rcx,[KernelFileSize]
  mov rax,[allocated_memory]
  mov rdx,[rax+rcx]
  mov qword [rax+OFFSET_END_ADDRESS],rdx

  mov rdi,rdx
  ;call print_hex

  ;image load
  mov r11,[EFI_SYSTEM_TABLE]
  mov r12,[r11 + EFI_BOOT_SERVICES]

  mov rcx,0;false
  mov rdx, [EFI_BOOT_LOADER_HANDLE] 
  
  mov r8, [FileSystemDevicePath]

  mov r9,[allocated_memory]


  sub rsp,8*6
  mov rax, KernelImageHandle
  mov qword [rsp + 8*5], rax
  mov rax, [KernelFileSize]
  mov qword [rsp + 8*4], rax
  call qword [r12+EFI_IMAGE_LOAD]
  add rsp,8*6

  cmp rax, EFI_SUCCESS
  jne error





  mov rdx,all_ok_msg
  call print

  
main_loop:

  jmp $



print_not_readed:
  mov rdx,kernel_not_readed_msg
  call print
  jmp continue

error_open_file:
  push rax
  mov rdx, error_open_file_msg
  call print
  pop rax
  cmp rax,EFI_SUCCESS
  jne error
  jmp main_loop

error:
  mov rbx, EFI_INVALID_PARAMETER
  cmp qword rax,rbx
  je invalid_parameter
  mov rbx, EFI_NOT_FOUND
  cmp qword rax,rbx
  je not_found
  mov rbx, EFI_LOAD_ERROR
  cmp qword rax,rbx
  je load_error
  mov rbx, EFI_UNSUPPORTED
  cmp qword rax,rbx
  je unsupported
  mov rdx, error_msg
  call print
  jmp main_loop
  
invalid_parameter:
  mov rdx, invalid_parameter_msg
  call print
  jmp main_loop
unsupported:
  mov rdx, unsupported_msg
  call print
  jmp main_loop
not_found:
  mov rdx, not_found_msg
  call print
  jmp main_loop
load_error:
  mov rdx, load_error_msg
  call print
  jmp main_loop
  
;rdx string
print:
  enter 32,0

  mov r15,[EFI_SYSTEM_TABLE]
  mov rcx,[r15 + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL]

  call qword [rcx + EFI_TEXT_STRING]
  
  leave
  
  ret

;https://forum.osdev.org/viewtopic.php?t=50623

get_handles:
  push rbp

  mov r15,[EFI_SYSTEM_TABLE] 
  mov r14,[r15+EFI_BOOT_SERVICES]
 
  mov rcx,LOCATE_BY_PROTOCOL
  mov rdx,EFI_SIMPLE_FILE_SYSTEM_PROTOCOL_GUID
  mov r8,0
  mov r9,handles_size

  sub rsp,6*8
  mov qword [rsp+4*8],handles
  call qword [r14+EFI_LOCATE_HANDLE]
  add rsp,6*8

  pop rbp
  ret

get_device_path:
  push rbp

  call get_handles 
  mov rbx,EFI_BUFFER_TOO_SMALL
  cmp rax,rbx
  je find_handle
  jne error

find_handle:


  call get_handles
  cmp rax,EFI_SUCCESS
  jne error
  
  
  mov r15,[EFI_SYSTEM_TABLE] 
  mov r14,[r15+EFI_BOOT_SERVICES]
  
  mov rcx,[handles]
  mov rdx,EFI_SIMPLE_FILE_SYSTEM_PROTOCOL_GUID
  mov r8,FileSystemProtocol
  sub rsp,32
  call qword [r14+EFI_HANDLE_PROTOCOL]
  add rsp,32
  cmp rax,EFI_SUCCESS
  jne error

  mov rcx,[handles]
  mov rdx,EFI_DEVICE_PATH_PROTOCOL_GUID
  mov r8,FileSystemDevicePath
  sub rsp,32
  call qword [r14+EFI_HANDLE_PROTOCOL]
  add rsp,32
  cmp rax,EFI_SUCCESS
  jne error

  mov rdx,got_device_path
  call print

  pop rbp
  ret




include "std.s"

include "data.s"

handles_size dq 0
handles dq ?
FileSystemDevicePath dq ?

buffer_too_small_msg du 'Buffer too small',13,10,0


