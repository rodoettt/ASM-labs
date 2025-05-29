title lab_4_2
	assume cs:c, ds:d, ss:s 
	
s 	segment stack
	dw 128 dup ('ss')
s 	ends

	cr = 0dh 
	lf = 0ah

d 	segment

	MSG_IN	db 10,13,'Input file name: $'
	MSG_OUT	db 10,13,'Output file name: $'
	FILE 	db 255,0, 255 dup (?)
	HANDLE 	dw ?
	HANDLE_	dw ?
	ERR_O 	db 10,13,'File was not opened$'
	ERR_C 	db 10,13,'File was not created$'
	ERR_R 	db 10,13,'Reading error$'
	ERR_W 	db 10,13,'Writing error$'
	tab 	db 	09h, '$' 
	space   db  " $"
	
	newl	db	cr, lf, '$' 
	string 	db 255, 0, 255 dup (?)
	errmsg	db	'Недопустимый символ, можно использовать'
			db	'только цифры, первый символ может быть'
			db 	'знаком + или - ', cr, lf, '$'
	negflag dw	?
d 	ends 

PRINT macro STR
			push	ax
			push	dx
			mov		ah, 9
			lea		dx, STR
			int		21h
			pop		dx
			pop		ax
		endm
		


c 	segment


start: 	
		mov 	bx, seg z
		mov 	ax,es
		sub 	bx,ax  
		mov 	ah,4ah 
		int 	21h
		jnc 	mm1
		
		mov 	cx,d
		mov 	ds,cx
		mov 	ah,9
		lea 	dx,ERR_O
		int 	21h
		mov 	ah,4ch
		int 	21h
		
mm1:
		mov		ax, 4096
		mov		bx, ax
		mov		ah, 48h
		int		21h
		jnc 	mm2
		test    bx,bx
		jnz		mm3
		mov 	cx,d
		mov 	ds,cx
		mov 	ah,9
		lea 	dx,ERR_C
		int 	21h
		mov 	ah,4ch
		int 	21h
mm3:	mov		ah, 48h
		int		21h
		
mm2:	mov		es, ax
		mov 	ax,d 
		mov 	ds,ax 
m2: 	lea 	dx,MSG_IN 
		mov 	ah,9 
		int 	21h 
		mov 	ah,0ah 
		lea 	dx,FILE 
		int		21h 
		lea 	di,FILE+2 
		mov 	al,-1[di] 
		xor 	ah,ah 
		add 	di,ax 
		mov 	[di],ah 
		mov 	ah,3dh 
		lea 	dx,FILE+2 
		xor 	al,al 
		int 	21h 
		jnc 	m1 
		lea 	dx,ERR_O 
		mov 	ah,9 
		int 	21h 
		jmp 	m2 
m1: 	mov 	HANDLE,ax 
m3: 	lea 	dx,MSG_OUT 
		mov 	ah,9 
		int 	21h 
		mov 	ah,0ah 
		lea 	dx,FILE 
		int 	21h 
		lea 	di,FILE+2 
		mov 	al,-1[di] 
		xor 	ah,ah 
		add 	di,ax 
		mov 	[di],ah 
		mov 	ah,3ch 
		lea 	dx,FILE+2 
		xor 	cx,cx 
		int 	21h 
		jnc 	m4 
		lea 	dx,ERR_C 
		mov 	ah,9 
		int 	21h 
		jmp 	m3 
m4: 	mov 	HANDLE_,ax 
m7: 	mov 	bx,HANDLE 
		push	ds
		push	es
		pop		ds
		xor		dx,dx
		mov 	ah,3fh  
		mov 	cx,256 
		int 	21h
		pop		ds
		jnc 	m5 
		lea 	dx,ERR_R 
		mov 	ah,9 
		int 	21h 
m6: 	mov 	ah,3eh 
		mov 	bx,HANDLE 
		int 	21h 
		mov 	ah,3eh 
		mov 	bx,HANDLE_ 
		int 	21h
		mov		ah, 49h
		int		21h
		mov 	ah,4ch 
		int 	21h 
m5: 	cmp 	ax,0 
		jz 		m6
		
		xor 	si, si
		mov 	cx,ax
co1: 
		cmp 	byte ptr es:[si],224
		jae		co2 
		jmp 	co3 
co2: 	cmp 	byte ptr es:[si], 255
		jbe		co5
		jmp 	co3
co5:	sub 	byte ptr es:[si], 159
co3: 	add 	si,1 
		loop 	co1 
co4: 	pop 	si 
		pop 	cx 
		
		mov		cx, ax
		mov 	ah,40h 
		mov 	bx,HANDLE_
		push	ds
		push 	es
		pop		ds
		xor 	dx,dx 
		int 	21h
		pop		ds
		jnc 	m7 	
		lea 	dx,ERR_W 
		mov 	ah,9 
		int 	21h 
		jmp 	m6 

c 	ends 
z segment 
z ends
end start