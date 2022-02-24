use32
memtest:

    %DEFINE START_ADDRESS 0x100000      ; 1MB
    %DEFINE END_ADDRESS   0x800000      ; 8MB
    %DEFINE DATA_PATTERN  0x5555AAAA
    %DEFINE WORD_SIZE     0x4
    %DEFINE CACHE_LINE    0x40

    ; EAX - address
    ; EBX - pattern (expected)
    ; ECX - read data

    ; EDX
    ; ESI
    ; EDI

    ; ESP
    ; EBP
    ; ES
    ; FS
    ; GS
    ; SS

    MOV EDX, 0
    MOV ESI, 0
    MOV EDI, 0
    MOV ESP, 0
    MOV EBP, 0
    MOV ES, DX
    MOV FS, DX
    MOV GS, DX
    ;MOV SS, DX     ; DONT CHANGE SS even if not using stack operations.
    
    
    ;;;;;;;;; WRITE

    write:
    mov eax, START_ADDRESS
    mov ebx, DATA_PATTERN ; 0x5's
    mov ecx, DATA_PATTERN ;
    ror ecx, 1            ; 0xA's
    write_loop:
    mov [eax+00], ebx          ; *address = pattern
    mov [eax+04], ecx          ; *address = pattern
    mov [eax+08], ebx          ; *address = pattern
    mov [eax+12], ecx          ; *address = pattern
    ;    
    mov [eax+16], ebx          ; *address = pattern
    mov [eax+20], ecx          ; *address = pattern
    mov [eax+24], ebx          ; *address = pattern
    mov [eax+28], ecx          ; *address = pattern
    ;
    mov [eax+32], ebx          ; *address = pattern
    mov [eax+36], ecx          ; *address = pattern
    mov [eax+40], ebx          ; *address = pattern
    mov [eax+44], ecx          ; *address = pattern
    ;    
    mov [eax+48], ebx          ; *address = pattern
    mov [eax+52], ecx          ; *address = pattern
    mov [eax+56], ebx          ; *address = pattern
    mov [eax+60], ecx          ; *address = pattern
    ;
    ;
    add eax, CACHE_LINE     ; address += 64
    cmp eax, END_ADDRESS    ; if address => end_address
    jge read                ; goto READ
    jmp write_loop          ; continue write loop


    ;;;;;;;;; READ

    read:
    mov eax, START_ADDRESS
    ;ECX
    ;ESP
    ;EBP
    read_loop:
    ;
    MOV EDX, [EAX+00]
    ADD EDX, [EAX+04] ; 0x5 + 0xA should eq. 0xF

    MOV ESI, [EAX+08]
    ADD ESI, [EAX+12]

    MOV EDI, [EAX+16]
    ADD EDI, [EAX+20]
    
    MOV EBX, [EAX+24]
    ADD EBX, [EAX+28]

    XOR EDX, ESI    ; 0xF ^ 0xF = 0
    XOR EDI, EBX
    XOR EDI, EDX    ; 0x0 ^ 0x0 = 0
    JNZ hang    
    ;
    MOV EDX, [EAX+32]
    ADD EDX, [EAX+36]

    MOV ESI, [EAX+40]
    ADD ESI, [EAX+44]

    MOV EDI, [EAX+48]
    ADD EDI, [EAX+52]
    
    MOV EBX, [EAX+56]
    ADD EBX, [EAX+60]
    ;
    XOR EDX, ESI
    XOR EDI, EBX
    XOR EDI, EDX
    JNZ hang
    ;
    add eax, CACHE_LINE
    cmp eax, END_ADDRESS
    jge write
    jmp read_loop

    hang:
    align 8
    ; CPU has 4 stage pipeline.  Padd with NOPS to avoid seeing EBFE on data bus.
    nop
    nop
    nop
    nop
    nop
    nop
    jmp $
