
input_loop:

  call get_key
  
  mov ax,[input_key]
  cmp rax,KEY_CODE_LEFT
  je left_pressed
  cmp rax,KEY_CODE_DOWN
  je down_pressed
  cmp rax,KEY_CODE_UP
  je up_pressed
  cmp rax,KEY_CODE_RIGHT
  je right_pressed


  jmp input_loop


right_pressed:
  call clear
  jmp boot

left_pressed:
  mov rdx,left_pressed_msg
  call print
  jmp input_loop

up_pressed:
  mov al,[boot_entry]
  cmp al,1;entries start at 1
  jg decrement_current_entry
  
  jmp input_loop

down_pressed:
  mov dl,[entries_count]
  mov al,[boot_entry]
  cmp al,dl
  jl increment_current_entry
  
  jmp input_loop


increment_current_entry:
  inc al
  mov [boot_entry],al
  call update_menu
  jmp input_loop

decrement_current_entry:
  dec al
  mov [boot_entry],al
  call update_menu
  jmp input_loop
  

get_key:
  push rbp

  mov r15,[EFI_SYSTEM_TABLE]
  mov rcx,[r15+EFI_INPUT_PROTOCOL]
  
  mov rdx,input_key
  sub rsp,32
  call qword [rcx+EFI_READ_KEY_STROKE]
  add rsp,32


  pop rbp
  ret

left_pressed_msg du "left pressed",13,10,0
