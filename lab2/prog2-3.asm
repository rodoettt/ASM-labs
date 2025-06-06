	title lab2_2_3
	assume cs:cod, ds:d, ss:s
s	segment stack
		dw 128 dup(?)
s	ends
	
	

d	segment
	matrix db 10000 dup(?)  ; Adjust the size as needed
	matrix_size dw ?
	cr = 0dh ;cr присваиваем значение кода символа
		 ;возврата каретки (клавиши <Enter>)
	lf = 0ah ;lf присваиваем значение кода символа
		 ;перевода строки
	errSize	db 	'Error size ', cr, lf, '$'
	errOF 	db 	'Error overflow ', cr, lf, '$'
	tab 	db 	09h, '$' 
	welcome_word db 'Enter a size of matrix (1-99)' ,cr,lf, '$'
	welcome_word_error db 'You entered the wrong number!',cr,lf,'$'
	CRLF	db	cr, lf, '$' 
	string 	db 255, 0, 255 dup (?)
	errmsg	db	'Invalid character, you can use only numbers, '
			db	'first char must be only "+" or "-"'
			db 	cr, lf, '$'
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
		jmp		ex
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
	xor ax,ax
welcome:
	print welcome_word
	call IntegerIn
	cmp ax,0
	jl not_in_range
	cmp ax,100
	jge not_in_range
	jmp welcome_end
not_in_range:
	print welcome_word_error
	jmp welcome
welcome_end:
	print CRLF
	mov matrix_size,ax
; Создание и вывод матрицы
	mov cx, ax
	xor di,di
	xor bx, bx
	lea si, matrix
create_matrix:
	push cx
	mov cx, matrix_size
create_row:
	mov ax, matrix_size
	dec ax
	sub ax, bx
	cmp di,ax
	je diagonal
	mov byte ptr [si],0
	jmp next_cell
diagonal:
	mov dx, di
	inc dx
	push di
	mov di, dx
	mov ax, dx
	inc di
	imul di
	mov byte ptr [si], ax
	pop di
next_cell:
	inc si
	inc bx
	loop create_row
	pop cx
	xor bx,bx
	inc di
	loop create_matrix

	print	CRLF

	mov cx, matrix_size
	lea si, matrix
; Вывод матрицы
print_matrix:
	push cx
	mov cx, matrix_size
print_row:
	xor ax, ax
	mov al,byte ptr [si]
	call IntegerOut
	print tab
	inc si
	loop print_row
	pop cx
	print CRLF
	loop print_matrix
	print CRLF

	ex:	mov	ah, 4ch
		int	21h	
Cod		ends
		end	code	