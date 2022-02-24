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
    mov ax, 0
    mov ds, ax
    xor ax, ax      ; error bits
    mov bx, 0x0     ; current address
    mov dx, 0x5555  ; pattern
    loop:
    mov [bx+00], dx
    mov [bx+02], dx
    mov [bx+04], dx
    mov [bx+06], dx
    mov [bx+08], dx
    mov [bx+10], dx
    mov [bx+12], dx
    mov [bx+14], dx
    ;
    mov cx, [bx+00]
    xor cx, dx
    add ax, cx
    mov cx, [bx+02]
    xor cx, dx
    add ax, cx
    mov cx, [bx+04]
    xor cx, dx
    add ax, cx
    mov cx, [bx+06]
    xor cx, dx
    add ax, cx
    mov cx, [bx+08]
    xor cx, dx
    add ax, cx
    mov cx, [bx+10]
    xor cx, dx
    add ax, cx
    mov cx, [bx+12]
    xor cx, dx
    add ax, cx
    mov cx, [bx+14]
    xor cx, dx
    add ax, cx
    ;
    cmp ax, 0
    jne dead_loop
    add bx, 16
    ror dx, 1
    cmp bx, 0x0
    jne loop
    mov cx, ds
    inc cx
    mov ds, cx
    jmp loop
    ;
    ;
    dead_loop:
    align 32
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
