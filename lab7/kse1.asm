
	model small, C

	.code
	public	createMatrix
createMatrix proc	near, matrix: word, matrix_size:word 

	xor di,di
	xor bx, bx
	
	mov si, matrix
	mov cx, matrix_size
	push si
create_matrix:
	push cx
	mov cx, matrix_size
create_row:
	mov ax, matrix_size
	dec ax
	sub ax, bx
	cmp di,ax
	je diagonal
	mov word ptr [si],0
	jmp next_cell
diagonal:
	mov dx, di
	inc dx
	push di
	mov di, dx
	mov ax, dx
	inc di
	imul di
	mov word ptr [si], ax
	pop di
next_cell:
	add si, 2
	inc bx
	loop create_row
	pop cx
	xor bx,bx
	inc di
	loop create_matrix
	pop si
	ret
createMatrix endp


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
