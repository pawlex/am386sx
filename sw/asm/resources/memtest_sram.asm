use32
memtest:

    %DEFINE START_ADDRESS 0xF0000
    %DEFINE END_ADDRESS   0x1000
    %DEFINE DATA_PATTERN  0x55555555
    %DEFINE WORD_SIZE     0x4

    ; EAX - address
    ; EBX - pattern (expected)
    ; ECX - read data


    write:
    mov eax, START_ADDRESS
    mov ebx, DATA_PATTERN
    write_loop:
    mov [eax], ebx          ; *address = pattern
    add eax, WORD_SIZE      ; address += 4
    cmp eax, END_ADDRESS    ; if address => end_address
    jge read                ; goto READ
    ror ebx, 1              ; else pattern << 1 ; 5's become A's
    jmp write_loop          ; continue write loop

    read:
    mov eax, START_ADDRESS
    mov ebx, DATA_PATTERN
    read_loop:
    mov ecx, [eax]
    cmp ecx, ebx
    jnz hang
    add eax, WORD_SIZE
    cmp eax, END_ADDRESS
    jge write
    ror ebx, 1
    jmp read_loop

    hang:
    align 2
    jmp $
