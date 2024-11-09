format pe64 efi
section '.text' code executable readable

;;Calling convertion parameters rcx, rdx, r8, r9 
;;return value are in rax
;;need 32 bytes of shadow space
;; shadow space is dedicated memory for saving four registers, precisely: rcx, rdx, r8 and r9
EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL = 64
EFI_TEXT_STRING = 8

EFI_TABLE_HEADER = 24
EFI_SUCCESS = 0
;Boot Services
EFI_OPEN_PROTOCOL = EFI_TABLE_HEADER + (33*8)
EFI_OPEN_PROTOCOL_BY_HANDLE_PROTOCOL = 0x00000001

EFI_BOOT_SERVICES = 88

EFI_MEMORY_LOADER_DATA = 2

SHADOW_SPACE = 32

EFI_ALLOCATE_POOL = 5 * 8

entry $

  ;;sub     rsp,28h
  mov [EFI_SYSTEM_TABLE], rdx
  mov [EFI_BOOT_LOADER_HANDLE], rcx

  mov rdx,string
  call print

  mov r11,[EFI_SYSTEM_TABLE]
  mov r12,[r11 + EFI_BOOT_SERVICES]
  mov r13, [r12 + EFI_ALLOCATE_POOL]

  mov rax,30
  mov rcx,EFI_MEMORY_LOADER_DATA
  mov rdx,4;bytes to allocate
  lea r8, [allocated_memory]

  sub rsp, SHADOW_SPACE
  call r13
  add rsp, SHADOW_SPACE
  cmp rax, EFI_SUCCESS
  jne error


  mov rdx,memory_allocated_msg
  call print

  
back:

  mov rdx,string
  call print
  jmp $

error:
  mov rdx, error_memory_msg
  call print
  jmp back
  


print:
  mov rdi,[EFI_SYSTEM_TABLE]
  mov rcx,[rdi + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL]
  mov rax,[rcx + EFI_TEXT_STRING]

  ;; Set up the shadow space. We just need to reserve 32 bytes
  ;; on the stack, which we do by manipulating the stack pointer:
  sub rsp,SHADOW_SPACE
  call rax
  add rsp,SHADOW_SPACE
  ret
 

open_protocol:
  
  mov r11,[EFI_SYSTEM_TABLE]
  mov r12,[r11 + EFI_BOOT_SERVICES]
  mov r13, [r12 + EFI_OPEN_PROTOCOL]

  mov rcx, EFI_BOOT_LOADER_HANDLE
  lea rdx, [EFI_LOADED_IMAGE_PROTOCOL_GUID]
  lea r8, [bootloader_image]
  mov r9, EFI_BOOT_LOADER_HANDLE



  sub rsp,SHADOW_SPACE

  mov rax, EFI_OPEN_PROTOCOL_BY_HANDLE_PROTOCOL
  push rax
  mov rax, 0
  push rax

  call r13

  add rsp,SHADOW_SPACE

  ;cmp rax, EFI_SUCCESS
  ;jne error

allocated_memory dq ?
string du 'Fuck C',13,10,0
error_msg du 'Error open loaded image',13,10,0
error_memory_msg du 'Error allocating pool',13,10,0
memory_allocated_msg du 'Allocated pool',13,10,0
EFI_SYSTEM_TABLE dq ?
EFI_BOOT_LOADER_HANDLE dq ?
EFI_LOADED_IMAGE_PROTOCOL_GUID dq 0x5b1b31a1, 0x9562, 0x11d2, 0x8e, 0x3f, 0x00, 0xa0, 0xc9, 0x69, 0x72, 0x3b
bootloader_image dq ?
