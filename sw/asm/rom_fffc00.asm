use16
org 0x0
start:          ; 0x0, 0xFF_Fc00
    mov ax, 0xFFFF
    mov cs, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    ;
    xor ax,ax
    xor bx,bx
    xor cx,cx
    xor dx,dx
    ;
    out 0x80, al
    mov ax,[0]
    mov ax,[0]
    mov ax,[0]
    mov ax,[0]
    out 0x80, al
    ;
fill_with_nops:
    ;align must be a power of 2
    nop
    align 512
    nop
    align 256
    nop
    align 128
    nop
    align 64
    nop
    align 32
    nop
    align 16
reset_vector:
    jmp start
    align 16
;           ; 0x3FF, 0xFF_FFFF
