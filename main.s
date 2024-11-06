format pe64 efi
section '.text' code executable readable

entry $
                sub     rsp,28h
                mov     rcx,[rdx + 64]
                mov     rax,[rcx + 8]
                mov     rdx,string
                call    rax
                jmp     $

string du 'Hello, World!',13,10,0
