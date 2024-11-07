format pe64 efi
section '.text' code executable readable

;;Calling convertion rcx, rdx, r8, r9 
EFI_SIMPLE_TEXT_INPUT_PROTOCOL = 64
EFI_TEXT_STRING = 8


entry $

  ;;sub     rsp,28h
  mov [EFI_SYSTEM_TABLE], rdx

  call print
  call print
  call print
  jmp $

print:
  mov rdi,[EFI_SYSTEM_TABLE]
  mov rcx,[rdi + EFI_SIMPLE_TEXT_INPUT_PROTOCOL]
  mov rax,[rcx + EFI_TEXT_STRING]

  mov rdx,string
  ;; Set up the shadow space. We just need to reserve 32 bytes
  ;; on the stack, which we do by manipulating the stack pointer:
  sub rsp,32
  call rax
  add rsp,32
  ret
  

string du 'Fuck C',13,10,0
EFI_SYSTEM_TABLE dq ?
