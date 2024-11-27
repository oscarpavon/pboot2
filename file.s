
;rdx out File
;r8 name
open_file: 
  push rbp

  sub rsp, 6*8

  mov r12, [RootDirectory] 
  mov rcx, [RootDirectory] 
  mov r9, EFI_FILE_MODE_READ
  mov qword [rsp+8*4], EFI_FILE_READ_ONLY

  call qword [r12+OPEN]
  add rsp, 6*8

  mov rdx,all_ok_msg
  call print
   
  cmp rax, EFI_SUCCESS
  jne error_open_file

  mov rdx,file_opened
  call print

  pop rbp

  ret

;rdx file
;rdx out file size
get_file_size:
  push rbp
  push rdx;save out file size
  push rcx;save file

  sub rsp, 8*4
  mov rdx, MAX_FILE_POSITION
  call qword [rcx+SET_POSITION]
  add rsp, 8*4

  cmp rax, EFI_SUCCESS
  jne error

  mov rdx,setted_max_file
  call print

  pop rcx;file
  pop rdx;out size

  sub rsp, 8*4
  call qword [rcx+GET_POSITION]
  add rsp, 8*4

  cmp rax, EFI_SUCCESS
  jne error

  mov rdx,got_file_size
  call print


  pop rbp
  ret

