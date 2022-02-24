; The original 8086 only had 20 address lines which means they could only access
; up to 1MB of externaly mapped memory (ram&rom).  CPU used banking (segmentation) 
; to access beyond 2^16 bits (64K), which is why we have CS,DC,ES,FS,GS,SS registers.
;
; x86 CPU's start up in REAL MODE and the CPU does a strange but clever thing...
; Set *S register to 0xF000 (0x0F_xxxx)
; Set all address bits high except the last 4.  In this case, it's 24, so 0xFF_FFF0
; Fetch first instruction. **Normally this is nothing more than a jump-table.
;
; The implications here is the chipset designer must alias the 2 rom areas together for
; both reset fetch and execution from rom to work correctly, as the first non-relative 
; instruction will assume rom is mapped to the top 1MB of memory.


; 1KB (0x400) of boot rom.  0x0 - 0xC00
; 32K (0x8000) of sram. 0x0 - 0x7fff

use16
org 0x0
start:          ; 0xFF_FC00 | 0x0F_FC00
    ;
    xor ax, ax
    mov ds, ax
    mov ax, 0xF000
    mov ss, ax
    mov sp, 0x7FF0
    xor bx,bx
    xor cx,cx
    xor dx,dx
    ;
    mov ax, 0xdead
    push ax
    align 8
    pop dx
    align 8
    ;
    mov [bx+0], ax
    align 8
    mov [bx+2], ax
    align 8
    mov cx, [bx+0]
    align 8
    mov cx, [bx+2]
    align 2
    jmp $
    ; 
nops:
    ; align fills un-aligned area with nops ( 0x90 ).  Must be a power of 2.
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
reset_vector:   ; 0xFF_FFF0 | 0xF0_FFF0
    jmp 0xF000:0xFC00
    align 16

























    ;jmp fill_with_nops
    ;jmp start
    ;jmp $

    ;mov ax, 0xF000
    ;mov cs, ax
    ;jmp fill_with_nops
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
