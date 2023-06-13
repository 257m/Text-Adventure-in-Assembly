all: run

run:
	nasm -f elf64 main.s -o main.o
	ld -m elf_x86_64 main.o -o main
	./main