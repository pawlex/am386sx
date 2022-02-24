[BITS 16]       ; We need 16-bit intructions for Real mode

[ORG 0xFFC00]    ; ROM LIVES AT 0x0F_FC00 and 0xFF_FC00

        cli                     ; Disable interrupts, we want to be alone

        xor ax, ax
        mov bx, ax
        mov cx, ax
        mov dx, ax
        mov ax, 0xF000
        mov ds, ax              ; Set DS-register to 0xF000 - used by lgdt

        lgdt [gdt_desc]         ; Load the GDT descriptor

        mov eax, cr0            ; Copy the contents of CR0 into EAX
        or eax, 1               ; Set bit 0
        mov cr0, eax            ; Copy the contents of EAX into CR0

        jmp dword 0x8:clear_pipe

[BITS 32]                       ; We now need 32-bit instructions
clear_pipe:
        mov ax, 0x10            ; Save data segment identifyer
        mov ds, ax              ; Move a valid data segment into the data segment register
        mov ss, ax              ; Move a valid data segment into the stack segment register
        mov esp, 0xF7FF0        ; STACK LIVES IN SRAM 0xfF_F000 - 0xfF_F7FF

exit_point:
        jmp 0x8:0xFFC60         ; next portion in ROM
trap:
        align 2
        jmp $                ; Loop, self-jump


gdt:                    ; Address for the GDT

gdt_null:               ; Null Segment
        dw 0
        dw 0
        db 0
        db 0
        db 0
        db 0

gdt_code:               ; Code segment, read/execute, nonconforming
        dw 0FFFFh
        dw 0
        db 0
        db 10011010b
        db 11001111b
        db 0

gdt_data:               ; Data segment, read/write, expand down
        dw 0FFFFh
        dw 0
        db 0
        db 10010010b
        db 11001111b
        db 0

gdt_end:                ; Used to calculate the size of the GDT



gdt_desc:                       ; The GDT descriptor
        dw gdt_end - gdt - 1    ; Limit (size)
        dd gdt                  ; Address of the GDT

payload:
align 16
