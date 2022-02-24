# have nasm create intel hex format.
# nasm -f ith rom_fffc00.asm -o rom_fffc00.hex


all: rom_fffc00.hex rom_fffc00.bin restart_jtag_server synthesize assemble reconfigure

rom: assemble reconf

hex: rom_fffc00.hex

rom_fffc00.bin: rom_fffc00.asm
	nasm -f bin rom_fffc00.asm -o rom_fffc00.bin

rom_fffff0.bin: rom_fffff0.asm
	nasm -f bin rom_fffff0.asm -o rom_fffff0.bin

rom_fffc60.bin:	rom_fffc60.asm
	nasm -f bin rom_fffc60.asm -o rom_fffc60.bin

rom_fffc00.hex:	rom_fffc00.bin rom_fffff0.bin rom_fffc60.bin
	../bin/bin2hex.py -r 4 -b 0x0,rom_fffc00.bin,0x60,rom_fffc60.bin,0x3f0,rom_fffff0.bin

rom_fffc00.rom:	rom_fffc00.hex
	intel2readmemh rom_fffc00.hex > rom_fffc00.rom || /bin/true

assemble: rom_fffc00.hex
	../bin/hex_mif.sh
	../bin/asm.sh

synthesize: rom_fffc00.hex
	../bin/map_fit.sh

flash: restart_jtag_server
	../bin/prog.sh flash

reconfigure: restart_jtag_server
	../bin/prog.sh reconfigure

reconf: reconfigure

restart_jtag_server:
	../bin/restart_jtag_server.sh &

clean:
	rm -f rom_fffc00 rom_fffc00.hex rom_fffc00.rom *.bin
	../bin/clean.sh

ndisasm: rom_fffc00.bin
	ndisasm rom_fffc00.bin | less

dis: ndisasm

