	title lab2_3
	assume cs:cod, ds:d, ss:s
s	segment stack
		dw 128 dup(?)
s	ends
	
	cr = 0dh ;cr присваиваем значение кода символа
		 ;возврата каретки (клавиши <Enter>)
	lf = 0ah ;lf присваиваем значение кода символа
		 ;перевода строки

d	segment
	arrayA		dw	100 dup (100	dup(?))
	arrayB		dw	100 dup (100	dup(?))
	arrayT		dw 	100 dup(?)
    N		    dw 0
	rows		dw ?
	columns		dw ?
	space   db  " $"
	msgA	db 	'Matrix A: $'
	msgB	db	'Array B: $'
	msgRows	db 	'Enter rows of matrix A: ', cr, lf, '$'
	msgColumns	db 	'Enter columns of matrix A: ', cr, lf, '$'
	msgEl	db 	' element: ', cr, lf, '$'
	errSize	db 	'Error size ', cr, lf, '$'
	errOF 	db 	'Error overflow ', cr, lf, '$'
	tab 	db 	09h, '$' 
	

	newl	db	cr, lf, '$' 
	string 	db 255, 0, 255 dup (?)
	errmsg	db	'Недопустимый символ, можно использовать'
			db	'только цифры, первый символ может быть'
			db 	'знаком + или - ', cr, lf, '$'
	negflag dw	?
d	ends
PRINT	macro	STR
				push	ax
				push	dx
				mov		ah, 9
				lea		dx, STR
				int		21h
				pop		dx
				pop		ax
				endm

cod	segment
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

code:
 	mov ax,d
	mov ds,ax
	
r1:
    print   msgRows
    call    IntegerIn
    cmp     ax, 0
    jg      r2
    print   errSize
    jmp     r1
r2:
    cmp     ax, 101
    jl      r3
    print   errSize
    jmp     r1

r3:
    mov     rows, ax
    mov     cx, ax
    xor     si, si
	
c1:
    print   msgColumns
    call    IntegerIn
    cmp     ax, 0
    jg      c2
    print   errSize
    jmp     c1
c2:
    cmp     ax, 101
    jl      c3
    print   errSize
    jmp     c1

c3:
    mov     columns, ax
    mov     cx, ax
    xor     si, si
	
;input arrA
		print	newl
		xor		bx, bx
		mov 	cx, rows
a:		push 	cx
		
		xor		si, si
		mov 	cx, columns
a1:		
		call	IntegerIn
		print	newl
		mov		arrayA[bx + si], ax
		add		si, 2
		loop	a1
		pop		cx
		add		bx, 100*2
		loop	a

		;output arrA
		print	msgA
		print	newl
		xor		bx, bx
		mov 	cx, rows
ao:		push 	cx
		xor		si, si
		mov 	cx, columns
ao1:	mov		ax, arrayA[bx + si]
		call	IntegerOut
		print	tab	
		add		si, 2
		loop	ao1
		print	newl
		pop		cx
		add		bx, 100*2
		loop	ao
		print	newl
		
		;algoritm
		mov     cx, columns
		mov		di, 0
		mov		bx, cx
		add		bx, bx
		add		di, bx
		xor		si, si
PRB:	push 	si
		sub		di, 2
		push 	di
		push 	cx
		mov		cx, rows
PRI:	mov		ax, arrayA[si]
		mov		arrayB[di], ax
		add		si, 2*100
		add		di, 2*100
		loop	PRI
		pop		cx
		pop 	di
		pop 	si
		add		si, 2
		loop	PRB

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
		print	msgB
		print	newl
		xor		bx, bx
		mov 	cx, rows
bo:		push 	cx
		xor		si, si
		mov 	cx, columns
bo1:	mov		ax, arrayB[bx + si]
		call	IntegerOut
		print	tab	
		add		si, 2
		loop	bo1
		print	newl
		pop		cx
		add		bx, 100*2
		loop	bo
		print	newl
		
ex:		mov		ah, 4ch
		int		21h	
		
Cod		ends
		end	code	