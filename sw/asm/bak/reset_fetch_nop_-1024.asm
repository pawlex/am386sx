use16
org 0x0
start:          ; 0x0, 0xFF_Fc00
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
