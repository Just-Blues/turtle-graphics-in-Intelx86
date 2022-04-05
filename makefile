CC=g++
ASMBIN=nasm

all : asm cc link
asm : 
	$(ASMBIN) -o func.o -f elf -g -l turtle.lst turtle.asm
cc :
	$(CC) -m32 -c -g -O0 main.cpp &> errors.txt
link :
	$(CC) -m32 -g -o project main.o func.o
clean :
	rm *.o
	rm project
	rm errors.txt	
	rm turtle.lst
