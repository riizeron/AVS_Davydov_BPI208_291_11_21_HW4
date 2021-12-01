# makefile for task.asm
task: main.o input.o inrnd.o output.o real.o delete.o
	gcc -g -o task main.o input.o inrnd.o output.o real.o delete.o -no-pie
main.o: main.asm macros.mac
	nasm -f elf64 -g -F dwarf main.asm -l main.lst
input.o: input.asm
	nasm -f elf64 -g -F dwarf input.asm -l input.lst
inrnd.o: inrnd.asm
	nasm -f elf64 -g -F dwarf inrnd.asm -l inrnd.lst
output.o: output.asm
	nasm -f elf64 -g -F dwarf output.asm -l output.lst
real.o: real.asm
	nasm -f elf64 -g -F dwarf real.asm -l real.lst
delete.o: delete.asm
	nasm -f elf64 -g -F dwarf delete.asm -l delete.lst