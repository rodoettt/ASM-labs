	model small, C
	.data
	cr = 0dh 
	lf = 0ah 
	tab 	db 	09h, '$' 
	newl	db	cr, lf, '$'
	msg	db	cr, lf, 'Amount of positive elements:', '$'
	msg1	db	cr, lf, 'Amount of negative elements:', '$'

print	macro	STR
			push	ax
			push	dx
			mov		ah, 9
			lea		dx, STR
			int		21h
			pop		dx
			pop		ax
			endm	
		
	.code
	public	printStats	
	
	
printStats	 proc	near, matrix: word, matrix_size:word
	xor bx, bx
	mov dx, 1
	mov cx, matrix_size
	mov si, matrix
	push si
print_matrix:
	push cx
	mov cx, matrix_size
print_row:
	xor ax, ax
	mov ax,word ptr [si]
	cmp dx, cx
	jle dr
	cmp ax, 0
	jle dr
	inc bx
dr:		
	inc si
	inc si
	loop print_row
	add dx, 1
	pop cx
	loop print_matrix
	pop si
	print msg
	mov ax, bx
	call IntegerOut
	
; ////////////////////
	print newl
	xor bx, bx
	mov dx, 2
	mov cx, matrix_size
	mov si, matrix
	push si
print_matrixa:
	push cx
	mov cx, matrix_size
print_rowa:
	xor ax, ax
	mov ax,word ptr [si]
	cmp dx, cx
	jg dra
	cmp ax, 0
	jge dra
	inc bx
dra:		
	inc si
	inc si
	loop print_rowa
	add dx, 1
	pop cx
	loop print_matrixa
	pop si
	print msg1
	mov ax, bx
	call IntegerOut
	ret
printStats endp

IntegerOut		proc
		push	ax
		push	bx
		push	cx
		push	dx
		xor		cx, cx
		mov		bx, 10
		cmp		ax, 0
		jge		om
		neg		ax
		push	ax
		mov		ah, 2
		mov		dl, '-'
		int		21h
		pop		ax
om:		inc		cx
		xor		dx, dx
		div		bx
		push	dx
		or		ax, ax
		jnz		om
om1:	pop		dx
		add		dx, '0'
		mov		ah, 2
		int		21h
		loop	om1
		pop		dx
		pop		cx
		pop		bx
		pop		ax
		ret
IntegerOut		endp
end