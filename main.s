format pe64 efi
include "efi_constants.inc"


;[rsp+8*0] ; shadow space for parm one (volitile)
;[rsp+8*1] ; shadow space for parm two (volitile)
;[rsp+8*2] ; shadow space for parm three (volitile)
;[rsp+8*3] ; shadow space for parm four (volitile)
;[rsp+8*4] ; param five must be stored here
;[rsp+8*5] ; param six must be stored here
;;Calling convertion parameters rcx, rdx, r8, r9 
;;return value are in rax
;;need 32 bytes of shadow space
;; shadow space is dedicated memory for saving four registers, precisely: rcx, rdx, r8 and r9

section '.text' code executable readable

entry $
 
  push rbx;align stack to 16 bytes
  
  mov [EFI_SYSTEM_TABLE], rdx
  mov [EFI_BOOT_LOADER_HANDLE], rcx


  ;get loader image
  mov r11,[EFI_SYSTEM_TABLE]
  mov r12,[r11 + EFI_BOOT_SERVICES]
 ; mov r13, [r12 + EFI_OPEN_PROTOCOL]

  mov rcx, [EFI_BOOT_LOADER_HANDLE]
  mov rdx, EFI_LOADED_IMAGE_PROTOCOL_GUID
  mov r8, BootLoaderImage
  mov r9, [EFI_BOOT_LOADER_HANDLE]


  sub rsp,8*6

  mov rax, EFI_OPEN_PROTOCOL_BY_HANDLE_PROTOCOL
  mov qword [rsp+8*5],rax
  mov rax, 0
  mov qword [rsp+8*4],rax

  call qword [r12+EFI_OPEN_PROTOCOL]

  add rsp,8*6

  cmp rax, EFI_SUCCESS
  jne error

  mov rdx,open_protocol_ok
  call print

  ;get file system protocol
  mov r13, [BootLoaderImage]
  mov rcx, [r13 + DEVICE]
  mov rdx, EFI_SIMPLE_FILE_SYSTEM_PROTOCOL_GUID
  mov r8, FileSystemProtocol
  mov r9, [EFI_BOOT_LOADER_HANDLE]

  sub rsp,8*6

  mov rax, EFI_OPEN_PROTOCOL_BY_HANDLE_PROTOCOL
  mov qword [rsp+8*5],rax
  mov rax, 0
  mov qword [rsp+8*4],rax

  call qword [r12+EFI_OPEN_PROTOCOL]

  add rsp,8*6
 
  cmp rax, EFI_SUCCESS
  jne error

  ;open volume
  sub rsp, 8*4
  mov rax, [FileSystemProtocol]
  
  mov rcx, [FileSystemProtocol]
  mov rdx, RootDirectory
  call qword [rax+OPEN_VOLUME]

  add rsp, 8*4

  cmp rax, EFI_SUCCESS
  jne error

  ;open file 
  sub rsp, 8*5
  mov rax, [RootDirectory]
  mov rcx, [RootDirectory] 
  mov rdx, KernelFile
  mov r8, kernel_name
  mov r9, EFI_FILE_MODE_READ
  mov r13, EFI_FILE_READ_ONLY
  mov qword [rsp+8*4], r13

  call qword [rax+OPEN]
  add rsp, 8*5
   
  cmp rax, EFI_SUCCESS
  jne error_open_file
 
  ;get file size
  sub rsp, 8*4
  mov rax, [KernelFile]
  mov rcx, [KernelFile] 
  mov rdx, MAX_FILE_POSITION
  call qword [rax+SET_POSITION]
  add rsp, 8*4

  cmp rax, EFI_SUCCESS
  jne error


  sub rsp, 8*4
  mov rax, [KernelFile]
  mov rcx, [KernelFile] 
  mov rdx, KernelFileSize
  call qword [rcx+GET_POSITION]
  add rsp, 8*4

  cmp rax, EFI_SUCCESS
  jne error

  mov rax,[KernelFileSize]
  ;call print_decimal

  ;allocate memory for kernel file
 
  sub rsp,8*4
  mov r11,[EFI_SYSTEM_TABLE]
  mov r12,[r11 + EFI_BOOT_SERVICES]

  mov rcx,EFI_MEMORY_LOADER_DATA
  mov rdx, [KernelFileSize]
  mov r8, allocated_memory
  call qword [r12+EFI_ALLOCATE_POOL]
  add rsp,8*4

  cmp rax, EFI_SUCCESS
  jne error

  ;load kernel to memory

  sub rsp, 8*4
  mov rax, [KernelFile]
  mov rcx, [KernelFile] 
  mov rdx, 0;we start from the zero position
  call qword [rax+SET_POSITION]
  add rsp, 8*4
  cmp rax, EFI_SUCCESS
  jne error

  ;read kernel file to memory

  mov r14,0 
  read_kernel:
  mov rcx,[KernelFile]
  mov r13,[KernelFileSize]
  sub r13,r14
  mov [readed],r13;total to read
  mov rdx,readed
  mov r15,[allocated_memory]
  lea r8, [r15+r14]
  ;mov r8,allocated_memory
  sub rsp,4*8
  call qword [rcx+READ]
  add rsp,4*8
  cmp rax,EFI_SUCCESS
  jne error
  mov rax, [readed]
  mov rdx, [KernelFileSize]
  cmp rax,rdx
  jne print_not_readed

read_continue:
  add r14,[readed]
  cmp r14,[KernelFileSize]
  je continue
  jl read_kernel


  continue:
 
  ;close kernel file after reading
  add rsp,32
  mov r15, [KernelFile]
  mov rcx,[KernelFile]
  call qword [r15+CLOSE]
  sub rsp,32
  cmp rax,EFI_SUCCESS
  jne error
 
  ;close root directory
  add rsp,32
  mov r15, [RootDirectory]
  mov rcx,[RootDirectory]
  call qword [r15+CLOSE]
  sub rsp,32
  cmp rax,EFI_SUCCESS
  jne error
  
  
  mov rdx,[allocated_memory]
  ;call print

  mov rax,[KernelFileSize]
  call print_decimal

 
  mov rdx,error_msg
  call print
  mov rdx,error_msg
  call print

  mov rdi,[number]
  call print_hex

  mov rdi,0xFF
  call print_hex

  mov rdx,error_msg
  call print
  

  ;mov rdi,KernelFileSize
  ;call print_hex


  ;call print_decimal


  jmp $

  ;create device memory path
  lea rax,[memory_device_path]
  mov rdx, allocated_memory
  mov qword [rax+OFFSET_START_ADDRESS],rdx
  mov rcx,[KernelFileSize]
  lea rdx,[allocated_memory+rcx]
  mov qword [rax+OFFSET_END_ADDRESS],rdx

  ;image load
  mov r11,[EFI_SYSTEM_TABLE]
  mov r12,[r11 + EFI_BOOT_SERVICES]

  mov rcx,0;false
  mov rdx, [EFI_BOOT_LOADER_HANDLE] 
  
  ;mov r13, [BootLoaderImage]
  ;mov r8, [r13 + FILE_PATH]
  mov r8,memory_device_path


  mov r9,allocated_memory


  sub rsp,8*6
  mov rax, KernelImageHandle
  mov qword [rsp + 8*5], rax
  mov rax, [KernelFileSize]
  mov qword [rsp + 8*4], rax
  call qword [r12+EFI_IMAGE_LOAD]
  add rsp,8*6

  cmp rax, EFI_SUCCESS
  jne error

  mov rdx,all_ok_msg
  call print

  
main_loop:

  jmp $


print_not_readed:
  mov rdx,kernel_not_readed_msg
  call print
  jmp continue

error_open_file:
  mov rdx, error_open_file_msg
  call print
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
  
;rdx string
print:
  enter 32,0

  mov r15,[EFI_SYSTEM_TABLE]
  mov rcx,[r15 + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL]

  call qword [rcx + EFI_TEXT_STRING]
  
  leave
  
  ret



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
		sub rdx,2
		mov word [rdx],bx
		shr rdi,4
		add rax,1
		cmp rax,rsi
		jl nibble

	mov rdx,hex_buffer
	call print

	ret
  ;mov word ax,[char]
  ;mov rdx,[allocated_memory]
  ;mov word [rdx],ax
  ;mov word [rdx+2],ax

include "data.s"
