format pe64 efi

include "config.s"

include "const.s"

;Calling convertion parameters rcx, rdx, r8, r9 
;[rsp+8*4] ; param five must be stored here
;[rsp+8*5] ; param six must be stored here
;return value are in rax
;need 32 bytes of shadow space
;shadow space is dedicated memory for saving four registers, precisely: rcx, rdx, r8 and r9

section '.text' code executable readable

entry $
 
  push rbx;align stack to 16 bytes
  
  mov [EFI_SYSTEM_TABLE], rdx
  mov [EFI_BOOT_LOADER_HANDLE], rcx

  
  mov r14,[EFI_SYSTEM_TABLE]
  mov r13,[r14 + EFI_BOOT_SERVICES]
  mov [boot_services],r13

  mov r14,[boot_services]
  mov r13,[r14+EFI_OPEN_PROTOCOL]
  mov [open_protocol],r13


  mov al,[show_menu]
  cmp al,1
  je menu
  
  call clear
  call print_menu ;call print menu to parse kernel name and arguments
  call clear

boot:

  ;print entry data
  mov rdx,[kernel_name]
  call print
  mov rdx,new_line
  call print
  mov rdx,[kernel_arguments]
  call print
  mov rdx,new_line
  call print


  ;get loader image
  mov rcx, [EFI_BOOT_LOADER_HANDLE]
  mov rdx, EFI_LOADED_IMAGE_PROTOCOL_GUID
  mov r8, BootLoaderImage
  mov r9, [EFI_BOOT_LOADER_HANDLE]

  sub rsp,8*6

  mov qword [rsp+8*5],EFI_OPEN_PROTOCOL_BY_HANDLE_PROTOCOL
  mov qword [rsp+8*4],0
  call [open_protocol]

  add rsp,8*6

  cmp rax, EFI_SUCCESS
  jne error

  mov rdx,got_loaded_image
  call print


  call get_device_path

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
  mov rcx, [RootDirectory] 
  mov rdx, KernelFile
  mov r8, [kernel_name]
  mov r9, EFI_FILE_MODE_READ
  mov r13, EFI_FILE_READ_ONLY
  mov qword [rsp+8*4], r13

  call qword [rcx+OPEN]
  add rsp, 8*6
   
  cmp rax, EFI_SUCCESS
  jne error_open_file

  mov rdx,file_opened
  call print
 
  ;get file size
  sub rsp, 8*4
  mov rcx, [KernelFile] 
  mov rdx, MAX_FILE_POSITION
  call qword [rcx+SET_POSITION]
  add rsp, 8*4

  cmp rax, EFI_SUCCESS
  jne error

  mov rdx,setted_max_file
  call print


  sub rsp, 8*4
  mov rcx, [KernelFile] 
  mov rdx, KernelFileSize
  call qword [rcx+GET_POSITION]
  add rsp, 8*4

  cmp rax, EFI_SUCCESS
  jne error

  mov rdx,got_file_size
  call print

  ;allocate memory for kernel file
 
  mov r12,[boot_services]

  sub rsp,8*4

  mov rcx,EFI_MEMORY_LOADER_DATA
  mov rdx, [KernelFileSize]
  mov r8, allocated_memory
  call qword [r12+EFI_ALLOCATE_POOL]

  add rsp,8*4

  cmp rax, EFI_SUCCESS
  jne error

  mov rdx,memory_allocated_msg
  call print

  ;load kernel to memory

  sub rsp, 8*4

  mov rcx, [KernelFile] 
  mov rdx, 0;we start from the zero position
  call qword [rcx+SET_POSITION]

  add rsp, 8*4

  cmp rax, EFI_SUCCESS
  jne error

  ;read kernel file to memory

  mov r14,0 
  read_kernel:
  mov rcx,[KernelFile];first parameter

  mov r13,[KernelFileSize]
  sub r13,r14
  mov [readed],r13;total to read

  mov rdx,readed;second parameter

  mov r15,[allocated_memory]
  lea r8, [r15+r14];third parameter

  sub rsp,4*8
  call qword [rcx+READ]
  add rsp,4*8

  cmp rax,EFI_SUCCESS
  jne error
  
  ;compare read with file size
  mov rax, [readed]
  mov rdx, [KernelFileSize]
  cmp rax,rdx
  jne print_not_readed

read_continue:
  mov rdx,file_loaded_to_memory
  call print

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

  ;image load
  mov r12,[boot_services]

  mov rcx,0;false
  mov rdx, [EFI_BOOT_LOADER_HANDLE] 
  
  mov r8, [FileSystemDevicePath]

  mov r9,[allocated_memory]

  sub rsp,8*6

  mov qword [rsp + 8*5], KernelImageHandle
  mov rax, [KernelFileSize]
  mov qword [rsp + 8*4], rax
  call qword [r12+EFI_IMAGE_LOAD]

  add rsp,8*6

  cmp rax, EFI_SUCCESS
  jne error

  mov rdx,image_loaded
  call print

  
  ;get loaded kernel image

  mov rcx, [KernelImageHandle]
  mov rdx, EFI_LOADED_IMAGE_PROTOCOL_GUID
  mov r8, KernelLoadedImage
  mov r9, [KernelImageHandle]

  sub rsp,8*6

  mov qword [rsp+8*5],EFI_OPEN_PROTOCOL_BY_HANDLE_PROTOCOL
  mov qword [rsp+8*4],0
  call [open_protocol]

  add rsp,8*6

  cmp rax, EFI_SUCCESS
  jne error

  mov rdx,got_loaded_kernel_image
  call print


  ;get arguments unicode char count
  mov rbx,[kernel_arguments]
  call string_len

  mov [arguments_char_count],eax

  ;allocate memory for arguments

  mov r12,[boot_services]

  sub rsp,8*4

  mov rcx,EFI_MEMORY_LOADER_DATA
  mov edx, [arguments_char_count]
  mov r8, arguments_memory
  call qword [r12+EFI_ALLOCATE_POOL]

  add rsp,8*4

  cmp rax, EFI_SUCCESS
  jne error

  mov rdx,memory_allocated_msg
  call print

  mov rcx,0
  copy_char:
  mov rax, [arguments_memory]
  lea rax,[rax+rcx]
  mov rbx,[kernel_arguments]
  lea rbx,[rbx+rcx]

  mov word dx,[rbx]

  mov word [rax], dx
  add rcx,2
  cmp ecx,[arguments_char_count]
  jl copy_char

  ;put end zero
  add rax,2
  mov word [rax],0

  ;print arguments
  mov rdx,[arguments_memory]
  call print
  mov rdx,13
  call print
  mov rdx,10
  call print

  mov r15,[KernelLoadedImage]
  mov eax,[arguments_char_count]
  mov dword [r15+ARGUMENTS_SIZE], eax
  mov rax,[arguments_memory]
  mov qword [r15+ARGUMENTS], rax
  

  ;start image
  mov r12,[boot_services]

  mov rcx, [KernelImageHandle]
  mov rdx,0
  mov r8,0

  sub rsp,32
  call qword [r12 + EFI_IMAGE_START]
  add rsp,32

  cmp rax,EFI_SUCCESS
  jne error


  mov rdx,all_ok_msg
  call print


include "menu.s" 

main_loop:

  jmp main_loop



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
  
  mov r14,[boot_services]
  
  ;get file system protocol
  mov rcx,[handles]
  mov rdx,EFI_SIMPLE_FILE_SYSTEM_PROTOCOL_GUID
  mov r8,FileSystemProtocol

  sub rsp,32
  call qword [r14+EFI_HANDLE_PROTOCOL]
  add rsp,32

  cmp rax,EFI_SUCCESS
  jne error

  ;get device path protocol
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

get_handles:
  push rbp

  mov r14,[boot_services]
 
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

include "std.s"

include "console.s"

include "data.s"



