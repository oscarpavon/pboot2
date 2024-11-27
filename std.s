
;eax number
print_decimal:
	mov rcx,16;max digits count
divide:
	xor edx,edx
	mov ebx,10
	div ebx
	add edx,'0'
	mov word [decimal_buffer+rcx],dx
	sub rcx,2
	cmp eax,9
	jg divide
	add eax,'0'
	mov word [decimal_buffer+rcx],ax
  mov rdx,decimal_buffer
  call print
  ret

;rdi value
;rsi amount of bits 
;rdx destination buffer
;rax amount of bytes written to output buffer
print_hex:
	mov rsi,64
	lea rdx,[hex_buffer]
	xor rax,rax
	shr rsi,2 ;divide by 4
	add rdx,rsi
	nibble:
		lea r9,[hex_table]
		mov bl,dil
		and bl,0x0f
		add r9b,bl
		mov bl,[r9]
		sub rdx,1
		mov byte [rdx],bl
		shr rdi,4
		add rax,1
		cmp rax,rsi
		jl nibble

  xor rcx,rcx
  xor rbx,rbx
  ascci_to_unicode:
    xor dx,dx
    lea rax,[hex_buffer+rcx]
    mov byte dl,[rax]
    lea r15,[hex_buffer_unicode]  
    mov word [r15+rbx],dx
    add rbx,2
    add rcx,1
    cmp rcx,16
    jl ascci_to_unicode


	mov rdx,hex_buffer_unicode
	call print

	ret

;rbx string
string_len:
	mov rcx,0
	count_char:
	inc rcx
	add rbx,2
	mov word ax,[rbx]
	cmp ax,0
	jne count_char 
	
	mov rax,rcx
	ret

;rbx string
;r14 memory
copy_memory:
	.char:
	mov word ax,[rbx]
	cmp ax,13
	je end_copy
	cmp ax,10
	je end_copy
	mov word [r14],ax
	add rbx,2
	add r14,2
	cmp ax,0
	jne .char
	

end_copy:
	mov word [r14],0
	add r14,2
	mov word [r14],0
	mov word [r14+2],0

	ret
