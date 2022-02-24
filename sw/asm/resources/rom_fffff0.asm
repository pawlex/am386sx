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

;
%define START_LOCATION 0xFFF0
[BITS 16]
cpu 386
org START_LOCATION
;
jmp 0xF000:0xFC00
align 16
    
