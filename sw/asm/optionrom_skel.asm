; Option ROM Header
USE16
ORG 0x0000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MY_DRIVE        EQU 0x80
;
MAX_SPT         EQU 63
MAX_HPC         EQU 16
MAX_CYL         EQU 1024
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

rom_header:
        DW 0xAA55             ; Boot signature (0x55AA)
        DB 0x08               ; Option ROM size in 512-byte units (8 x 512 = 4096 bytes, or 4KiB)
        JMP OPTION_ROM_SCAN_ENTRY

OPTION_ROM_SCAN_ENTRY:
        PUSHA
        CALL INSTALL_INT_13_HANDLER
        POPA
        RETF ; RETURN BACK TO BIOS (far)

INSTALL_INT_13_HANDLER:
        XOR AX, AX             ; Clear AX
        MOV DS, AX             ; Set DS to 0

        ; Copy current INT13 Handler to INT40
        ; TODO:  Only copy of 0x40*4+2 != CS
        MOV [0x13*4], AX
        MOV AX, [0x40*4]

        MOV [0x13*4+2], AX
        MOV AX, [0x40*4+2]

        ; Install custom INT 13h handler
        MOV WORD [0x13*4], INT13_ENTRY
        MOV WORD [0x13*4+2], CS

        ; INSTALL FIXED DISK TABLE @ 0x41 ??
        MOV WORD [0x104], MY_FIXED_DISK_TABLE
        MOV WORD [0x106], CS

        ; Increase number of drives in the BDA
        INC BYTE [0x475]
        RET

INT13_ENTRY:
        CMP DL,MY_DRIVE
        JE .ourDevice
        ;; Use stack manipulation to perform a long-jump to the previous INT13
        ;; This is needed because modifying any registers will cause a failure
        SUB SP,8                        ; -8
        PUSH GS                         ; -10
        ADD SP,10                       ; 0
        PUSH 0x0                        ; -2
        POP GS                          ; 0
        PUSH WORD [GS:0x40*4+2] ; -2
        PUSH WORD [GS:0x40*4]           ; -4
        SUB SP,6                        ; -10
        POP GS                          ; -8
        ADD SP,4                        ; -4
        RETF ; FAR JUMP                 ; RET OLDINT13+2:OLDINT13

        ;PUSH WORD 0xF000               ; QEMU
        ;PUSH WORD 0xE3FE               ; QEMU
        ;RETF
        .ourDevice:
        CMP AH, 0x00 ; RESET
        JE INT13_00_00
        CMP AH, 0x0D ; ALT RESET
        JE INT13_00_00
        CMP AH, 0x02 ; READ
        JE INT13_00_02
        CMP AH, 0x03 ; WRITE
        JE INT13_00_03
        CMP AH, 0x08 ; DEVICE INFO
        JE INT13_00_08
        CMP AH, 0x15 ; READ DASD TYPE
        JE INT13_00_15
        ;
        ; UNHANDLED WITH SUCCESS
        ;
        CMP AH,0x01 ; STATUS
        JE INT13_00_EXIT_UNHANDLED_SUCCESS
        CMP AH,0x04 ; VERIFY SECTOR
        JE INT13_00_EXIT_UNHANDLED_SUCCESS
        CMP AH,0x05 ; FORMAT SECTOR
        JE INT13_00_EXIT_UNHANDLED_SUCCESS
        CMP AH,0x09 ; INIT DBT
        JE INT13_00_EXIT_UNHANDLED_SUCCESS
        CMP AH,0x0C ; SEEK
        JE INT13_00_EXIT_UNHANDLED_SUCCESS
        CMP AH,0x10 ; TEST READY
        JE INT13_00_EXIT_UNHANDLED_SUCCESS
        CMP AH,0x11 ; RE-CAL
        JE INT13_00_EXIT_UNHANDLED_SUCCESS
        CMP AH,0x12 ; CONTROLLER DIAG
        JE INT13_00_EXIT_UNHANDLED_SUCCESS
        CMP AH,0x13 ; DRIVE DIAG
        JE INT13_00_EXIT_UNHANDLED_SUCCESS
        CMP AH,0x14 ; INTERNAL DIAG
        JE INT13_00_EXIT_UNHANDLED_SUCCESS
        CMP AH,0x16 ; DISK CHANGE
        JE INT13_00_EXIT_UNHANDLED_SUCCESS
        CMP AH,0x19 ; PARK
        JE INT13_00_EXIT_UNHANDLED_SUCCESS
        ;
        ; ELSE UNHANDLED WITH ERROR
        ;
        JMP INT13_00_EXIT_UNHANDLED_UNSUPPORTED

INT13_00_EXIT_UNHANDLED_UNSUPPORTED:
        MOV AH,1
        STC
        IRET
INT13_00_EXIT_UNHANDLED_SUCCESS:
        MOV AH,0
        CLC
        IRET
INT13_00_00:
        CLC
        MOV AH,0
        IRET
INT13_00_02:
        CLC
        MOV AH,0
        XOR CX,CX
        MOV CL,AL
        IRET
INT13_00_03:
        STC
        MOV AH,3
        IRET

;; GET CURRENT DRIVE PARAMETERS
INT13_00_08:
        XOR AX,AX
        XOR BX,BX
        MOV CX,0x3F3F
        MOV DX,0x0F01
        CLC
        IRET

;; READ DISK TYPE / DASD
INT13_00_15:
        MOV AX,0x0300
        MOV DX,0xFC00
        CLC
        IRET

; FIXED DISK TABLE FOR 32MiB SPI
MY_FIXED_DISK_TABLE:
        DW 0x0041       ; NUMBER OF SECTORS
        DB MAX_HPC      ; NUMBER OF HEADS
        DW 0x0000       ; RES
        DW 0x0000       ; WR.PRECOMP
        DB 0x00         ; RES
        DB 0x40         ; DRIVE CONTROL BYTE
        DB 0x00         ; RES
        DW 0x00         ; RES
        DW 0x41         ; LANDING ZONE CYL
        DB MAX_SPT      ; SECTORS PER TRACK
        DB 0x00         ; RES
;;
;
; Calculate checksum (sum of all bytes must be zero)
times 4093-($-$$) db 0    ; Pad the rest of the 512-byte block with zeros
dw 0xAA55                ; Boot sector signature
checksum:
    db 0x00               ; Placeholder for checksum (to be calculated manually)
;; EOF
