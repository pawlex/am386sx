use16
org 0x0
start:          ; 0x0, 0xFF_Fc00
    ;
    ;out dx, ax
    ;mov dx, 0x80
    ;; deadbeef
    ;mov ax, 0xdead
    ;out dx, ax
    ;mov ax, 0xbeef
    ;out dx, ax
    ;; 0x0000
    ;xor ax, ax
    ;out dx, ax
    ;; CS
    ;mov ax, cs
    ;out dx, ax
    ;; 0x0000
    ;xor ax, ax
    ;out dx, ax
    ;;jmp start
    ;;
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
    ;mov ax, 0xF000
    ;mov cs, ax
    ;jmp fill_with_nops
    jmp 0xF000:0xFC00
    ;jmp fill_with_nops
    ;jmp start
    ;jmp $
    align 16
;           ; 0x3FF, 0xFF_FFFF
