format pe64 efi
section '.text' code executable readable

;;Calling convertion rcx, rdx, r8, r9 
EFI_SIMPLE_TEXT_INPUT_PROTOCOL = 64
EFI_TEXT_STRING = 8


entry $

  ;;sub     rsp,28h
  mov rcx,[rdx + EFI_SIMPLE_TEXT_INPUT_PROTOCOL]
  mov rax,[rcx + EFI_TEXT_STRING]

  mov rdx,string
  ;; Set up the shadow space. We just need to reserve 32 bytes
  ;; on the stack, which we do by manipulating the stack pointer:
  sub rsp, 32
  call rax
  jmp $

string du 'Fuck C',13,10,0
