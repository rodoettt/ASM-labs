	model small, C
	.data
	itr_1	db	'A[$'
	itr_2	db	'] = $'
	cr = 0dh
	lf = 0ah 
	newl	db	cr, lf, '$'
	negflag	dw	?
	string	db	255, 0, 255 dup (?)
	errmsg	db	0dh, 0ah,'Invalid character, only '
		db	'numbers can be used, the first character '
		db	'can be a "+" or "-" sign', cr, lf, '$'
		
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
	public	createMatrix
createMatrix proc	near, matrix: word, matrix_size:word 

	print newl
	mov si, matrix
	push si
	mov ax, matrix_size
	imul ax
	mov cx, ax
	inc ax
aIn:
	push cx
	push si
	print itr_1
	mov ax, matrix_size
	imul ax
	inc ax
	sub ax, cx
	call IntegerOut
	print itr_2
	call IntegerIn
	print newl
	pop si
	pop cx
	mov word ptr [si], ax
	add	si, 2
	loop aIn
	pop si
	print newl
	ret
createMatrix endp

IntegerIn	proc
im:		push	bx
		push	dx
		push	si
		mov		ah, 0ah
		lea		dx, string
		int		21h
		xor		ax, ax
		lea		si, string+2
		mov		negflag, ax
		cmp		byte ptr [si], '-'
		jne		im2
		not		negflag
		inc		si	
		jmp		im1
im2:	cmp		byte ptr [si], '+'
		jne		im1
		inc		si
im1:	cmp		byte ptr [si], cr
		je		iex1
		cmp		byte ptr [si], '0'
		jb		ierr
		cmp		byte ptr [si], '9'
		ja		ierr
		mov		bx, 10
		mul		bx
		sub		byte ptr [si], '0'
		add		al, [si]
		adc		ah,0
		inc		si
		jmp		im1
ierr:	print	errmsg
		jmp		im
iex1:	cmp		negflag, 0
		je		iex
		neg		ax
iex:	pop		si
		pop		dx
		pop		bx
		ret
IntegerIn	endp

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