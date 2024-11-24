msg du "end entries",13,10,0
menu:

  lea r15,[entries+1]

mov r14,r15
push r14;r14 it's used in print
mov rdx,r14
call print_in_menu ;print first entry
pop r14
xor rcx,rcx
find_entry:
  push r14
  add rcx,2
  lea rdx,[r14+rcx]
  cmp word [rdx],0
  jne find_entry
  je print_entry

end_entries:
  mov rdx,msg
  call print

  jmp $

print_entry:
  mov r11,rcx
  add r11,2
  lea r13,[r14+r11]
  cmp byte [r13],0xFF
  je end_entries
  push rcx
  lea rdx,[r14+r11]
  call print_in_menu
  pop rcx
  jmp find_entry


