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

EFI_MEMORY_LOADER_DATA = 1

SHADOW_SPACE = 32

EFI_ALLOCATE_POOL = EFI_TABLE_HEADER + (5 * 8)

EFI_IMAGE_LOAD = EFI_ALLOCATE_POOL + (17 * 8)
EFI_IMAGE_START = EFI_ALLOCATE_POOL + (18 * 8)

DEVICE = 24
FILE_PATH = 32

OPEN_VOLUME = 8

OPEN = 8
READ = 32
GET_POSITION = 48
SET_POSITION = 56
MAX_FILE_POSITION = 0xFFFFFFFFFFFFFFFF

EFI_FILE_READ_ONLY = 0x1
EFI_FILE_MODE_READ = 0x1



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

  call qword [rax+OPEN]
  add rsp, 8*5
   
  cmp rax, EFI_SUCCESS
  jne error_open_file
 
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

  mov rdx, string
  call print
  ;allocate memory for kernel file
 
  sub rsp,8*4
  mov r11,[EFI_SYSTEM_TABLE]
  mov r12,[r11 + EFI_BOOT_SERVICES]

  mov rcx,EFI_MEMORY_LOADER_DATA
  mov rdx, KernelFileSize
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

 
  mov r15, 0
  read_loop:
  mov r12, KernelFileSize
  sub r12, r15
  sub rsp, 8*4
  mov rax, [KernelFile]
  mov rcx, [KernelFile]
  mov rdx, r12
  lea r8, [allocated_memory+r15]
  call qword [rax+READ]
  add rsp, 8*4
  cmp rax, EFI_SUCCESS
  jne error
  add r15,r12
  cmp r15,KernelFileSize
  jl read_loop


  mov rdx,allocated_memory 
  call print

  mov r11,[EFI_SYSTEM_TABLE]
  mov r12,[r11 + EFI_BOOT_SERVICES]

  mov rcx,0;false
  mov rdx, [EFI_BOOT_LOADER_HANDLE] 
  mov r13, [BootLoaderImage]
  mov r8, [r13 + FILE_PATH]

  mov r9, allocated_memory
  
  sub rsp,8*6
  mov rax, KernelImage
  mov qword [rsp + 8*5], rax
  mov rax, KernelFileSize
  mov qword [rsp + 8*4], rax
  ;call qword [r12+EFI_IMAGE_LOAD]
  add rsp,8*6

  cmp rax, EFI_SUCCESS
  ;jne error

  mov rdx,all_ok_msg
  call print

  
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
  

;rdx string
print:
  enter 32,0

  mov rdi,[EFI_SYSTEM_TABLE]
  mov rcx,[rdi + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL]
  mov rax,[rcx + EFI_TEXT_STRING]

  call qword [rcx + EFI_TEXT_STRING]
  
  leave
  
  ret


allocated_memory dq ?
string du 'Fuck C',13,10,0
all_ok_msg du 'All OK',13,10,0

kernel_name du 'kernel.txt',0
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
KernelImage dq ?
FileSystemProtocol dq ?
RootDirectory dq ?
KernelFile dq ?
KernelFileSize dq ?
size dq 16483328
size2 dq 10

