
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
  mov rdx, [max_size]
  call qword [rcx+SET_POSITION]
  add rsp, 8*4
  
  push rax
  mov rdx,setted_max_file
  call print
  pop rax

  cmp rax, EFI_SUCCESS
  jne error

  pop rcx;file
  pop rdx;out size

  push rcx

  sub rsp, 8*4
  call qword [rcx+GET_POSITION]
  add rsp, 8*4
  
  push rax
  mov rdx,got_file_size
  call print
  pop rax

  cmp rax, EFI_SUCCESS
  jne error

  pop rcx

  ;restore file position
  sub rsp, 8*4

  mov rdx, 0;we start from the zero position
  call qword [rcx+SET_POSITION]

  add rsp, 8*4

  cmp rax, EFI_SUCCESS
  jne error

  mov rdx,all_ok_msg
  call print

  pop rbp
  ret

read_simple:
  push rbp

  mov rcx,[KernelFile];first parameter

  mov r13,[KernelFileSize]
  mov [readed],r13;total to read
  
  mov rdx,readed;second parameter
  
  mov r8,[allocated_memory]

  sub rsp,32
  call qword [rcx+READ]
  add rsp,32

  cmp rax,EFI_SUCCESS
  jne error

  pop rbp
  ret

read_to_memory:
  mov r14,0 
  read_kernel:
  mov rcx,[KernelFile];first parameter

  mov r13,[KernelFileSize]
  sub r13,r14
  mov [readed],r13;total to read

  mov rdx,readed;second parameter

  mov r15,[allocated_memory]
  lea r8, [r15+r14];third parameter

  sub rsp,4*8
  call qword [rcx+READ]
  add rsp,4*8

  cmp rax,EFI_SUCCESS
  jne error
  
  ;compare read with file size
  mov rax, [readed]
  mov rdx, [KernelFileSize]
  cmp rax,rdx
  jne print_not_readed

read_continue:
  mov rdx,file_loaded_to_memory
  call print

  add r14,[readed]
  cmp r14,[KernelFileSize]
  je continue
  jl read_kernel
