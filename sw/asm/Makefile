all: rom_fffc00.hex rom_fffc00.bin

rom_fffc00.hex:	rom_fffc00.asm
	nasm -f ith rom_fffc00.asm -o rom_fffc00.hex

rom_fffc00.bin: rom_fffc00.asm
	nasm -f bin rom_fffc00.asm -o rom_fffc00.bin

rom_fffc00.rom:	rom_fffc00.hex
	intel2readmemh rom_fffc00.hex > rom_fffc00.rom || /bin/true

altera: rom_fffc00.hex
	../bin/restart_jtag_server.sh &
	../bin/hex_mif.sh
	../bin/asm.sh

flash: altera
	../bin/prog.sh flash

reconfigure: altera
	../bin/prog.sh reconfigure

reconf: reconfigure

clean:
	rm -f rom_fffc00 rom_fffc00.hex rom_fffc00.rom rom_fffc00.bin

ndisasm: rom_fffc00.bin
	ndisasm rom_fffc00.bin | less

dis: ndisasm
