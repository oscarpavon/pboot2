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

SHADOW_SPACE = 32

entry $

  ;;sub     rsp,28h
  mov [EFI_SYSTEM_TABLE], rdx
  mov [EFI_BOOT_LOADER_HANDLE], rcx

  call print
  call print
  call print
  jmp $

print:
  mov rdi,[EFI_SYSTEM_TABLE]
  mov rcx,[rdi + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL]
  mov rax,[rcx + EFI_TEXT_STRING]

  mov rdx,string
  ;; Set up the shadow space. We just need to reserve 32 bytes
  ;; on the stack, which we do by manipulating the stack pointer:
  sub rsp,SHADOW_SPACE
  call rax
  add rsp,SHADOW_SPACE
  ret
  

string du 'Fuck C',13,10,0
EFI_SYSTEM_TABLE dq ?
EFI_BOOT_LOADER_HANDLE dq ?
EFI_LOADED_IMAGE_PROTOCOL_GUID dq 0x5b1b31a1, 0x9562, 0x11d2, 0x8e, 0x3f, 0x00, 0xa0, 0xc9, 0x69, 0x72, 0x3b
bootloader_image dq ?
