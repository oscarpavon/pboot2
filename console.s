
;rdx string
print_in_menu:
  push rbx
  
  mov r15,[EFI_SYSTEM_TABLE]
  mov rcx,[r15 + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL];rcx need to be Simple Text Output

  sub rsp,32
  call qword [rcx + EFI_TEXT_STRING]
  add rsp,32

  pop rbx
  ret

;rdx string
print:
  push rbx

  mov rax,DEBUG
  cmp rax,0
  je .not_print

  mov r15,[EFI_SYSTEM_TABLE]
  mov rcx,[r15 + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL];rcx need to be Simple Text Output

  sub rsp,32
  call qword [rcx + EFI_TEXT_STRING]
  add rsp,32

.not_print:
  pop rbx

  ret


clear:
  push rbp

  mov r15,[EFI_SYSTEM_TABLE]
  mov rcx,[r15 + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL];rcx need to be Simple Text Output

  sub rsp,32
  call qword [rcx + EFI_CLEAR]
  add rsp,32

  pop rbp

  ret
