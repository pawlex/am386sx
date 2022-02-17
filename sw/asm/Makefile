all: rom_fffc00.hex rom_fffc00.bin restart_jtag_server synthesize assemble reconfigure

rom: assemble reconf

rom_fffc00.hex:	rom_fffc00.asm
	nasm -f ith rom_fffc00.asm -o rom_fffc00.hex

rom_fffc00.bin: rom_fffc00.asm
	nasm -f bin rom_fffc00.asm -o rom_fffc00.bin

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
	rm -f rom_fffc00 rom_fffc00.hex rom_fffc00.rom rom_fffc00.bin
	../bin/clean.sh

ndisasm: rom_fffc00.bin
	ndisasm rom_fffc00.bin | less

dis: ndisasm

