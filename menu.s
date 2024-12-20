
include "input.s"

menu:
  
  call clear

  call print_menu

  jmp input_loop

  
print_menu:
mov byte [entries_count],0
push rbp
lea r10,[entries]
xor rcx,rcx ;global char counter
xor rdi,rdi ;entry number
xor rsi,rsi ;menu char counter
xor r12,r12 ;entry name control
find_entry:
  mov rsi,rcx
  find_one_entry:
  add rcx,2
  lea r10,[entries]
  lea r9,[r10+rcx]
  cmp word [r9],0
  jne find_one_entry
  je check_entry

end_entries:

  pop rbp

  ret
  

check_entry:
  mov r11,rsi
  add r11,2;plus end zero
  lea r10,[entries]
  lea r13,[r10+r11]
  cmp byte [r13],0xFF;end entries const
  je end_entries
  cmp r12,0
  je print_entry
  cmp r12,1
  je set_kernel_name
  cmp r12,2
  je set_arguments
  
  ;not here
  jmp find_entry

;rax value to set
;rdx value
can_set_value:
  cmp dil, [boot_entry]
  je set_value 
  ret
set_value:
  mov r11,rsi
  add r11,2;plus end zero
  lea r10,[entries]
  lea rbx,[r10+r11]
  mov [rax],rbx
  ret

set_kernel_name:
  mov rax,kernel_name
  call can_set_value

  inc r12
  jmp find_entry

set_arguments:
  xor r12,r12;reset entry menu name counter
  mov rax, kernel_arguments
  call can_set_value

  jmp find_entry
  

print_entry:
  mov al,[entries_count]
  inc al
  mov [entries_count],al
  inc r12;entry name control
  inc dil;selected entry counter
  mov r11,rsi
  add r11,2;plus end zero
  lea r10,[entries]
  lea rdx,[r10+r11]
  call print_in_menu
  cmp dil, [boot_entry]
  je print_selected_entry_sign
continue_print_entry:
  mov rdx,new_line
  call print_in_menu
  jmp find_entry

print_selected_entry_sign:
  mov rdx,selected_entry_sign
  call print_in_menu
  jmp continue_print_entry


update_menu:
  push rbp
  call clear
  call print_menu
  pop rbp
  ret

