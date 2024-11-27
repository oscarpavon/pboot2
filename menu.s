msg du "end entries",13,10,0
new_line du 13,10,0
selected_entry_sign du '*',0

include "input.s"

menu:
  
  call clear

  jmp input_loop

  

lea r14,[entries]
xor rcx,rcx
xor rdi,rdi ;entry number
xor rsi,rsi
xor r12,r12
find_entry:
  push r14
  mov rsi,rcx
  find_one_entry:
  add rcx,2
  lea rdx,[r14+rcx]
  cmp word [rdx],0
  jne find_one_entry
  je check_if_entry_name

end_entries:
  mov rdx,msg
  call print
  

  jmp $

check_if_entry_name:
  mov r11,rsi
  add r11,2;plus end zero
  lea r13,[r14+r11]
  cmp byte [r13],0xFF
  je end_entries
  cmp r12,0
  je print_entry
  cmp r12,2
  je entry_name_control_set_zero
  inc r12

  jmp find_entry

entry_name_control_set_zero:
  xor r12,r12
  jmp find_entry
  

print_entry:
  inc r12;entry name control
  inc dil;selected entry counter
  mov r11,rsi
  add r11,2;plus end zero
  push rcx;print override rcx
  lea rdx,[r14+r11]
  call print_in_menu
  cmp dil, [boot_entry]
  je print_selected_entry_sign
continue_print_entry:
  mov rdx,new_line
  call print_in_menu
  pop rcx
  jmp find_entry

print_selected_entry_sign:
  mov rdx,selected_entry_sign
  call print_in_menu
  jmp continue_print_entry

