
;rdx string
print_in_menu:
  push rcx
  
  mov r15,[EFI_SYSTEM_TABLE]
  mov rcx,[r15 + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL];rcx need to be Simple Text Output

  sub rsp,32
  call qword [rcx + EFI_TEXT_STRING]
  add rsp,32

  pop rcx
  ret

;rdx string
print:
  push rbp

  mov rax,DEBUG
  cmp rax,0
  je .not_print

  mov r15,[EFI_SYSTEM_TABLE]
  mov rcx,[r15 + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL];rcx need to be Simple Text Output

  sub rsp,32
  call qword [rcx + EFI_TEXT_STRING]
  add rsp,32

.not_print:
  pop rbp

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

print_menu_debug:
  push rcx
  mov rdx,parsed_entry
  call print
  pop rcx
  ret

