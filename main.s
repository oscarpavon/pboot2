format pe64 efi
section '.text' code executable readable


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
EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL = 64
EFI_TEXT_STRING = 8

EFI_TABLE_HEADER = 24
EFI_SUCCESS = 0
;Boot Services
EFI_OPEN_PROTOCOL = EFI_TABLE_HEADER + (32*8)
EFI_OPEN_PROTOCOL_BY_HANDLE_PROTOCOL = 0x00000001

EFI_BOOT_SERVICES = 96

EFI_MEMORY_LOADER_DATA = 2

SHADOW_SPACE = 32

EFI_ALLOCATE_POOL = EFI_TABLE_HEADER + (5 * 8)

DEVICE = 24

OPEN_VOLUME = 8

OPEN_FILE = 8

EFI_FILE_READ_ONLY = 0x1
EFI_FILE_MODE_READ = 0x1

entry $
 
  push rbx;align stack to 16 bytes

  mov [EFI_SYSTEM_TABLE], rdx
  mov [EFI_BOOT_LOADER_HANDLE], rcx
  

  call allocate_pool

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

  mov rdx,open_protocol_ok
  call print

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

  ;open volume
  sub rsp, 8*4
  mov rax, [FileSystemProtocol]
  
  mov rcx, [FileSystemProtocol]
  mov rdx, RootDirectory
  call qword [rax+OPEN_VOLUME]

  add rsp, 8*4

  cmp rax, EFI_SUCCESS
  jne error

  ;open file 
  sub rsp, 8*5
  mov rax, [RootDirectory]
  mov rcx, [RootDirectory] 
  mov rdx, KernelFile
  mov r8, kernel_name
  mov r9, EFI_FILE_MODE_READ
  mov r13, EFI_FILE_READ_ONLY
  mov qword [rsp+8*4], r13

  call qword [rax+OPEN_FILE]
  add rsp, 8*5
   
  cmp rax, EFI_SUCCESS
  jne error_open_file

  
main_loop:

  jmp $

error_open_file:
  mov rdx, error_open_file_msg
  call print
  jmp main_loop

error:
  mov rdx, error_memory_msg
  call print
  jmp main_loop
  


print:
  ;push rbp
  ;mov rbp, rsp
  ;sub rsp,32
  enter 32,0

  mov rdi,[EFI_SYSTEM_TABLE]
  mov rcx,[rdi + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL]
  mov rax,[rcx + EFI_TEXT_STRING]

  ;; Set up the shadow space. We just need to reserve 32 bytes
  ;; on the stack, which we do by manipulating the stack pointer:
  call rax
  
  ;mov rsp,rbp
  ;pop rbp
  leave
  
  ret

allocate_pool:
  ;push rbp
  ;mov rbp,rsp
  ;sub rsp,32
  enter 32,0

  mov r11,[EFI_SYSTEM_TABLE]
  mov r12,[r11 + EFI_BOOT_SERVICES]
  mov r13, [r12 + EFI_ALLOCATE_POOL]

  mov rcx,EFI_MEMORY_LOADER_DATA
  mov rdx,4;bytes to allocate
  mov r8, allocated_memory

  call r13
  cmp rax, EFI_SUCCESS
  jne error

 ; mov rsp, rbp
 ; pop rbp

  mov rdx,memory_allocated_msg
  call print

  leave
 

  ret


open_protocol:
  
  ret

allocated_memory dq ?
string du 'Fuck C',13,10,0

kernel_name du 'vmlinuz',0
error_msg du 'Error open loaded image',13,10,0
error_memory_msg du 'Error allocating pool',13,10,0
memory_allocated_msg du 'Allocated pool',13,10,0
open_protocol_ok du 'Open protocol OK',13,10,0
error_open_file_msg du 'Error open file',13,10,0
EFI_SYSTEM_TABLE dq ?
EFI_BOOT_LOADER_HANDLE dq ?
EFI_LOADED_IMAGE_PROTOCOL_GUID dd 0x5B1B31A1
                                dw 0x9562,0x11d2
                                db 0x8E,0x3F,0x00,0xA0,0xC9,0x69,0x72,0x3B

EFI_SIMPLE_FILE_SYSTEM_PROTOCOL_GUID dd 0x0964e5b22
                                      dw 0x6459, 0x11d2
                                      db 0x8e, 0x39, 0x00, 0xa0, 0xc9, 0x69, 0x72, 0x3b 

BootLoaderImage dq ?
FileSystemProtocol dq ?
RootDirectory dq ?
KernelFile dq ?
