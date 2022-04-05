;=====================================================================
;
; Author:      Abel Niwiñski
; Date:        2022.01.14
; Description: Turtle 6.20
;
;    int turtle(char *dest_bitmap,
;				char *commands,
;				unsigned int commands_size);
;=====================================================================

section .data

section	.text
global  turtle

turtle:
	push ebp ; Save the old base pointer value.
	mov	ebp, esp ; Set the new base pointer value.

	sub esp, 13 ; Make room for 5 local variables, 3 are one byte, 2 are 2-byte, 1 is 4-byte, two additional bytes just in case

	mov edx, [ebp+12]
	
	mov	BYTE [ebp-1], 5;y coordinate 
	mov WORD [ebp-3], 5 ;x coordinate, because it can be up to 500
	mov DWORD [ebp-7], 00FFFFFFH;colour - white
	mov BYTE [ebp-8], 0 ;dir - up
	mov BYTE [ebp-9], 1 ;pen state - off
	mov WORD [ebp-11], 0 ;distance 
	mov WORD [ebp-13], 0 ;initialize the last variable

	mov ecx, 0 ;counter and offset in address
	

program_loop:
	cmp ecx, [ebp+16]
	;cmp ecx, 10;for testing, delete it later
	je exit
	movzx eax, BYTE [edx+ecx]
	shr eax, 6

	cmp eax, 0
	je move
	cmp eax, 1
	je pen_state
	cmp eax, 2
	je set_position
	cmp eax, 3
	je set_direction

exit:
	mov eax, 0
	mov esp, ebp ; Deallocate local variables
	pop ebp
	ret

;=============================================================================




;============================================
move:
	movzx ebx, BYTE[edx+ecx]
	shl ebx, 4
	inc ecx
	movzx eax, BYTE[edx+ecx]
	shr eax, 4
	add eax, ebx
	mov WORD[ebp-11], ax ;Load distance

	mov edx,[ebp+8]
	movzx eax, WORD[edx+10] ;File offset to pixel array
	add edx, eax ;edx now has address of pixel[0,0]
	;+3 to pixel [1,0] (which is the first x away from 0)
	;+1800 to pixel [0,1] (which is the first y away from 0)


	;Set direction
	cmp BYTE[ebp-8],0
	je up
	cmp BYTE[ebp-8],1
	je left
	cmp BYTE[ebp-8],2
	je down
	cmp BYTE[ebp-8],3
	je right

	mov eax, -5
	jmp exit ; quit if there is a problem
;============================================
up:

	movzx eax, BYTE[ebp-1]
	mov WORD[ebp-13], ax ;save old y-postion

	add ax, WORD [ebp-11] ;new position	ax = y BYTE[ebp-1] + distance WORD[ebp-11]
		
	mov esi, eax ; save new postion in esi

	cmp eax, 50
	jle con1
	mov ebx, esi
	sub ebx, 50
	movzx eax, WORD[ebp-11]
	sub eax, ebx
	mov WORD[ebp-11], ax ;new distance
	mov BYTE [ebp-1], 49 ;new position as edge
	mov al, [ebp-1]

con1:
	mov [ebp-1], al ;save new postion
	movzx eax, WORD[ebp-13]

	cmp BYTE [ebp-9], 1
	je done ;Jump if pen is off
	mov eax, 3
	movzx ebx, WORD[ebp-3]
	imul eax, ebx; [0+x,0]
	add edx, eax
	mov eax, 1800
	movzx ebx, WORD[ebp-13]
	imul eax,ebx
	add edx, eax
	movzx esi, BYTE[ebp-11]

movement_up:
	cmp esi, 0
	je done
	mov ebx, DWORD [ebp-7]

	mov BYTE [edx+0], bl
	mov BYTE [edx+1], bh
	shr ebx, 16
	mov BYTE [edx+2], bl

	add edx, 1800
	dec esi
	jmp movement_up
;============================================	
left:
	movzx eax, WORD[ebp-3]

	mov WORD[ebp-13], ax ;save old y-postion

	sub	ax, WORD [ebp-11] ;new position ax = y BYTE[ebp-1] - distance WORD[ebp-11]

	mov esi, eax ; save new postion in esi
	mov [ebp-3], ax ;even if there is overflow, it will be overwritten

	cmp eax, 599

	jl con2 ;if there is no overflow, continue

	movzx ebx, WORD[ebp-13]
	inc ebx
	mov WORD[ebp-11], bx ;new distance
	mov WORD [ebp-3], 0 ;new position as edge
	movzx eax, WORD [ebp-3]

con2:
	cmp BYTE [ebp-9], 1
	je done ;Jump if pen is off

	mov eax, 3
	movzx ebx, WORD[ebp-13]
	imul eax, ebx 
	add edx, eax
	mov eax, 1800
	movzx ebx, BYTE[ebp-1]
	imul eax,ebx
	add edx, eax
	movzx esi, BYTE[ebp-11]

movement_left:
	cmp esi,0
	je done
	mov ebx, DWORD [ebp-7]

	mov BYTE [edx+0], bl
	mov BYTE [edx+1], bh
	shr ebx, 16
	mov BYTE [edx+2], bl
	sub edx, 3

	dec esi
	jmp movement_left
;============================================
down:

	movzx eax, BYTE[ebp-1]

	mov WORD[ebp-13], ax ;save old y-postion

	sub	ax, WORD [ebp-11] ;new position ax = y BYTE[ebp-1] - distance WORD[ebp-11]

	mov esi, eax ; save new postion in esi
	mov [ebp-1], al ;even if there is overflow, it will be overwritten

	cmp eax, 49

	jl con3 ;if there is no overflow, continue

	movzx ebx, BYTE[ebp-13]
	inc ebx
	mov WORD[ebp-11], bx ;new distance
	mov BYTE [ebp-1], 0 ;new position as edge
	movzx eax, BYTE [ebp-1]

con3:
	cmp BYTE [ebp-9], 1
	je done ;Jump if pen is off

	mov eax, 3
	movzx ebx, WORD[ebp-3]
	imul eax, ebx 
	add edx, eax
	mov eax, 1800
	movzx ebx, WORD[ebp-13]
	imul eax,ebx
	add edx, eax
	movzx esi, BYTE[ebp-11]
	
movement_down:
	cmp esi,0
	je done
	mov ebx, DWORD [ebp-7]

	mov BYTE [edx+0], bl
	mov BYTE [edx+1], bh
	shr ebx, 16
	mov BYTE [edx+2], bl
	sub edx, 1800


	dec esi
	jmp movement_down
;============================================
right:
	movzx eax, WORD[ebp-3]
	mov WORD[ebp-13], ax ;save old y-postion

	add ax, WORD [ebp-11] ;new position	ax = y BYTE[ebp-1] + distance WORD[ebp-11]

	mov esi, eax ; save new postion in esi

	cmp eax, 600
	jle con4
	mov ebx, esi
	sub ebx, 600
	movzx eax, WORD[ebp-11]
	sub eax, ebx
	mov WORD[ebp-11], ax ;new distance
	mov WORD [ebp-3], 599 ;new position as edge		

con4:
	mov [ebp-3], ax ;save new postion

	movzx eax, WORD[ebp-13]

	cmp BYTE [ebp-9], 1
	je done ;Jump if pen is off
	mov eax, 3
	movzx ebx, WORD[ebp-13]
	imul eax, ebx
	add edx, eax
	mov eax, 1800
	movzx ebx, BYTE[ebp-1]
	imul eax,ebx
	add edx, eax
	movzx esi, BYTE[ebp-11]

movement_right:
	cmp esi, 0
	je done
	mov ebx, DWORD [ebp-7]

	mov BYTE [edx+0], bl
	mov BYTE [edx+1], bh
	shr ebx, 16
	mov BYTE [edx+2], bl
	add edx, 3
	dec esi
	jmp movement_right
;============================================
done:
	mov eax, esi
	inc ecx;Iterate
	mov edx, [ebp+12];load address of commands
	jmp program_loop
	;jmp exit


;============================================
pen_state:
	movzx ebx, BYTE[edx+ecx]

	mov DWORD[ebp-7], 000000000h

	sub ebx, 64
	and ebx, 16
	shr ebx, 4
	mov [ebp-9], bl
	cmp ebx, 0
	jne finish;Don't analyze colour if pen is off

	mov eax, 0
	movzx ax, BYTE[edx+ecx]
	sub ax, 64
	mov bl,8
	div bl

	cmp ah, 0
	mov DWORD[ebp-7], 00000000h ;Black
	je finish
	cmp ah, 1
	mov DWORD[ebp-7], 00FF00FFh ;Purple
	je finish
	cmp ah, 2
	mov DWORD[ebp-7], 0000FFFFh ;Cyan
	je finish
	cmp ah, 3
	mov DWORD[ebp-7], 00FFFF00h ;Yellow
	je finish
	cmp ah, 4
	mov DWORD[ebp-7], 000000FFh ;Blue
	je finish
	cmp ah, 5
	mov DWORD[ebp-7], 0000FF00h ;Green
	je finish
	cmp ah, 6
	mov DWORD[ebp-7], 00FF0000h ;Red
	je finish
	cmp ah, 7
	mov DWORD[ebp-7], 00FFFFFFh ;White
	je finish

	mov eax, -3
	jmp exit; quit if there is problem

finish:
	add ecx, 2;Iterate
	jmp program_loop
	;jmp exit


;============================================
set_position:
	mov eax, 0
	movzx ebx, BYTE[edx+ecx]
	sub ebx, 128
	cmp ebx, 50
	jl set_x
	mov bl, 49
set_x:
	mov [ebp-1], bl ;load one BYTE
	add ecx, 2 ;Iterate
	movzx eax, BYTE [edx+ecx]
	shl eax, 2
	inc ecx
	movzx ebx, BYTE[edx+ecx]
	shr ebx, 6
	add eax, ebx
	cmp eax, 600
	jl end_set
	mov eax, 599

end_set:
	inc ecx ;Iterate
	mov WORD [ebp-3], ax
	jmp program_loop
	;jmp exit

;============================================
set_direction:
;(3 - right, 2 - down, 1 - left, 0 - up)
	movzx ebx, BYTE [edx+ecx]
	shr ebx, 2
	sub ebx, 48
	cmp ebx, 4
	jl continue
	sub ebx, 4
	cmp ebx, 4
	jl continue
	sub ebx, 4
	cmp ebx, 4
	jl continue

	mov eax, -1
	jmp exit ;quit if there is a problem

continue:
	cmp ebx, 0
	je end_direction
	cmp ebx, 1
	je end_direction
	cmp ebx, 2
	je end_direction
	cmp ebx, 3
	je end_direction

	mov eax, -2
	jmp exit ;quit if there is a problem

end_direction:	
	mov [ebp-8], bl;store it in local variable
	add ecx, 2;Iterate
	jmp program_loop
	;jmp exit


;============================================
; THE STACK
;============================================
;
; larger addresses
;
;  |	       .......             |   
;  ---------------------------------
;  | unsigned int commands_size    | EBP+16
;  ---------------------------------
;  | char *commands                | EBP+12
;  ---------------------------------
;  | char *dest_bitmap			   | EBP+8
;  ---------------------------------
;  | return address                | EBP+4
;  ---------------------------------
;  | saved ebp                     | EBP, ESP
;  ---------------------------------
;  | ... here local variables      | EBP-x
;  |     when needed               |
;
; \/                              \/
; \/ the stack grows in this      \/
; \/ direction                    \/
;
; lower addresses
;
;
;============================================
