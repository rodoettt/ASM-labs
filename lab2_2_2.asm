	title lab_2_2
	assume cs:C, ds:D, ss:S
	
S	segment stack
	dw	128 dup	(?)
S	ends

	cr = 0dh
	lf = 0ah

D	segment
sum		dw	?
proizv		dw	?
null		dw	?
arr		dw	100 dup (?)
arrSize	dw	?
success	db	'Success$'
itr_1	db	'A[$'
itr_2	db	'] = $'  
errSize	db	cr, lf, 'Invalid size', cr, lf, '$'
msgSize	db 	'Enter size of the array [1 - 100] = $'
newl	db	cr, lf, '$'
errOFW	db	'ERROR! Overflow!', cr, lf, '$'
string	db	255, 0, 255 dup (?)
errmsg	db	0dh, 0ah,'Invalid character, only '
		db	'numbers can be used, the first character '
		db	'can be a "+" or "-" sign', cr, lf, '$'
msg1	db	cr, lf, 'Multiplication "+": ', '$'
msg2	db	cr, lf, 'Addition "-": ', '$'
msg3	db	cr, lf, 'Counter "0": ', '$'

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
		mov 	sum, 0
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

start:	mov		ax, D
		mov 	ds, ax
		mov		null, 0
		mov		proizv, 1
		mov		sum, 0
cp0:	print	msgSize
		call 	IntegerIn
		cmp		ax, 0
		jg		cp1
		print	errSize
		jmp		cp0
		
cp1:	cmp		ax, 100
		jle		cp2
		print	errSize
		jmp		cp0

cp2:	print	newl
		mov		arrSize, ax
		mov 	cx, arrSize
		mov		si, 0
aIn:	push 	cx
		push	si		
		print	itr_1
		mov 	ax, arrSize
		sub 	ax, cx
		call	IntegerOut
		print	itr_2
		call	IntegerIn
		print	newl
		pop		si
		pop		cx
		mov 	arr[si], ax
		add		si, 2
		loop	aIn
		
		;arr proc
		mov		si, 0
		mov 	cx, arrSize
		
aPr:	mov		ax, arr[si]
		cmp 	ax, 0
		jg		proizved
		cmp 	ax, 0
		jl		sumel
		cmp 	ax, 0
		je 		nullel
		jmp		next2

proizved:	
		mov		dx, proizv
		imul	dx
		jno		no
		print	errOFW
		mov 	ah,	4ch
		int		21h	
no:		mov		proizv, ax
		jmp		next2
sumel:	add		sum, ax
		jmp		next2
nullel:	add		null, 1
		

next2:	add		si, 2
		loop	aPr
		mov 	ax, proizv
		print	msg1
		;print	newl
		call	IntegerOut
		print	newl
		mov 	ax, sum
		print	msg2
		call	IntegerOut
		print	newl
		mov 	ax, null
		print	msg3
		call	IntegerOut
		print	newl
			
ex:		mov 	ah,	4ch
		int		21h			
C		ends
		end start