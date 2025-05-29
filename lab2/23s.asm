	title 23new
	assume cs:C, ds:D, ss:S
	
S	segment stack
	dw	128 dup	(?)
S	ends

	cr = 0dh
	lf = 0ah

D	segment
arr		dw	100 dup (?)
arrSize	dw	?
success	db	'Success$'
itr_1	db	'A[$'
itr_2	db	'] = $'
msgA	db 	'Matrix A: $'
msgB	db 	'Matrix B: $'
tab 	db 	09h, '$'  
errSize	db	cr, lf, 'Invalid size', cr, lf, '$'
msgSize	db 	'Enter size of the matrix [MxM] = $'
CRLF	db	cr, lf, '$'
errO	db	'ERROR! Overflow!', cr, lf, '$'
string	db	255, 0, 255 dup (?)
errmsg	db	0dh, 0ah,'Invalid character, only '
		db	'numbers can be used, the first character '
		db	'can be a "+" or "-" sign', cr, lf, '$'

negflag	dw	?

D 	ends

PRINT	macro	STR
		push	ax
		push	dx
		mov		ah, 9
		lea		dx, STR
		int		21h
		pop		dx
		pop		ax
		endm


C	segment

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
ierr:	PRINT	errmsg
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

printArray		proc
init:
	print msgA
	print CRLF
outer_loop:
	print crlf
	push cx
	mov cx, arrSize
inner_loop:
	mov ax, arr[si]
	call IntegerOut
	print tab
	add si, 2
	loop inner_loop
	pop cx
	loop outer_loop
	print CRLF
	ret
printArray		endp

printArray2		proc
init1:
	print msgB
	print CRLF
outer_loop1:
	print CRLF
	push cx
	mov cx, arrSize
	mov ax, cx
	imul ax
	mov bx, 2
	imul bx
	sub ax, cx
	sub ax, cx
	mov si, ax
	pop cx
	mov ax, arrSize
	sub ax, cx
	push cx
	mov cx, arrSize
	imul bx
	add si, ax
	xor ax, ax
inner_loop1:
	mov ax, arr[si]
	call IntegerOut
	print tab
	mov bx, 2
	mov ax, arrSize
	imul bx
	sub si, ax
	xor ax, ax
	loop inner_loop1
	pop cx
	loop outer_loop1
	ret
	
printArray2 	endp
start:
	mov ax, D 
	mov ds, ax
a0:
	print msgSize
	call IntegerIn
	mov arrSize, ax
	cmp ax, 0
	jg a1
	print errSize
	jmp a0
a1:
	cmp ax, 100
	jle a2
	print errSize
	jmp a0	
a2:
	print CRLF
	mov ax, arrSize
	imul ax
	mov cx, ax
	inc ax
	mov si, 0
aIn:
	push cx
	push si
	print itr_1
	mov ax, arrSize
	imul ax
	inc ax
	sub ax, cx
	call IntegerOut
	print itr_2
	call IntegerIn
	print CRLF
	pop si
	pop cx
	mov arr[si], ax
	add	si, 2
	loop aIn
aOut:
	mov cx, arrSize
	xor si, si
	print CRLF
	call printArray
	mov cx, arrSize
	xor si, si
	print CRLF
	call printArray2
ex:		mov 	ah,	4ch
		int		21h			
C		ends
		end start