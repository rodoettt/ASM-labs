	model small, C
	.data
	cr = 0dh
	lf = 0ah 
	tab 	db 	09h, '$' 
	newl	db	cr, lf, '$'

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
	public	printMatrixA	
	
	
printMatrixA	 proc	near, matrix: word, matrix_size:word
	mov cx, matrix_size
	mov si, matrix
	push si
print_matrix:
	push cx
	mov cx, matrix_size
print_row:
	xor ax, ax
	mov ax,word ptr [si]
	call IntegerOut
	print tab
	inc si
	inc si
	loop print_row
	pop cx
	print newl
	loop print_matrix
	print newl
	pop si
	ret
printMatrixA endp

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