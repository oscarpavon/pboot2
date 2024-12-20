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
  
  mov rdx,welcome
  call print

  mov r14,[EFI_SYSTEM_TABLE]
  mov r13,[r14 + EFI_BOOT_SERVICES]
  mov [boot_services],r13

  mov rdx,boot_services_configured
  call print

  mov r14,[boot_services]
  mov r13,[r14+EFI_OPEN_PROTOCOL]
  mov [open_protocol],r13

  mov rdx, open_protocol_configured
  call print

  mov rdx,64
  mov r8,kernel_name_memory
  call allocate_memory

  mov al,[show_menu]
  cmp al,1
  je menu
  
  call clear
  call print_menu ;call print menu to parse kernel name and arguments
  call clear
  
boot:

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
  
  mov rbx,kernel_test
  mov r14,[kernel_name_memory]
  ;call copy_memory

  ;open file 
  mov rdx, KernelFile
  ;mov r8, [kernel_name_memory]
  mov r8, kernel_test
  call open_file

  
  ;get file size
  ;mov rcx,[KernelFile]
  ;mov rdx, KernelFileSize
  ;call get_file_size
  mov [KernelFileSize],16483328


  ;allocate memory for kernel file
  
  mov rdx,[KernelFileSize]
  mov r8, allocated_memory
  call allocate_memory

  ;load kernel to memory

  ;read kernel file to memory

  ;jmp read_to_memory

  call read_simple

  mov rdx,all_ok_msg
  call print
 
  continue:

  ;call close_file 

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
  mov rbx,kernel_parameters_test
  call string_len

  mov [arguments_char_count],eax

  ;allocate memory for arguments
  mov edx, [arguments_char_count]
  mov r8, arguments_memory
  call allocate_memory
  
  ;kernel arguments
  ;mov rbx,[kernel_arguments]
  ;lea r14,[kernel_parameters_buffer]
  ;call copy_memory


  
  mov rbx,kernel_parameters_test
  mov r14,[arguments_memory]
  call copy_memory

  mov r15,[KernelLoadedImage]
  mov eax,[arguments_char_count]
  mov dword [r15+ARGUMENTS_SIZE], eax
  mov rax,[arguments_memory]
  mov qword [r15+ARGUMENTS], rax
  
  mov rdx,kernel_arguments_configured
  call print


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

main_loop:

  jmp $


include "menu.s" 
include "error.s"

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

;rdx count
;r8 out_memory
allocate_memory:
  push rbp

  mov r12,[boot_services]

  sub rsp,8*4

  mov rcx,EFI_MEMORY_LOADER_DATA
  call qword [r12+EFI_ALLOCATE_POOL]

  add rsp,8*4

  cmp rax, EFI_SUCCESS
  jne error

  mov rdx,memory_allocated_msg
  call print

  pop rbp
  ret

include "file.s"
include "std.s"

include "console.s"

section '.data' data readable writeable
include "data.s"



