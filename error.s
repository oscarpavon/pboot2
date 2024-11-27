
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
