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
	newl	db	cr, lf, '$' 
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
IntegerIn	proc			; процедура ввода
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

IntegerOut		proc 		; процедура вывода
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
	call IntegerIn			; вводим размер матрицы MxM
	cmp ax,0				; сравниваем с 0, если меньше, выводим ошибку и вводим еще раз
	jl not_in_range
	cmp ax,100				; сравниваем с 100, если больше, выводим ошибку и вводим еще раз
	jge not_in_range
	jmp welcome_end
not_in_range:
	print welcome_word_error
	jmp welcome
welcome_end:
	mov matrix_size,ax		; переносим размер матрицы из регистра ax в переменную matrix_size
; СОЗДАНИЕ МАТРИЦЫ
	mov cx, ax	
	lea si, matrix			; указываем адрес матрицы
	mov di, 1				; передаем 1 в регистр di
create_matrix:
	push cx					; кладем на стек размер матрицы
	mov cx, matrix_size		
create_row:
	cmp cx, di				; проверка для заполнения матрицы: если счетчик (cx) больше или равен di, элемент матрицы равен di
	jge provv
	mov byte ptr [si], 0	; если счетчик (cx) меньше di, то элемент матрицы равен 0
	jmp next_cell
provv:
	mov byte ptr [si], di
	jmp next_cell
next_cell:
	inc si					; для перехода к следующему элементу увеличиваем si на 1
	loop create_row
	pop cx					; после заполнения ряда вытаскиваем значение со стека в cx (размер матрциы) и создаем следующий ряд
	inc di
	loop create_matrix
	print	newl
	mov cx, matrix_size
	lea si, matrix
; ВЫВОД МАТРИЦЫ
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
	print newl
	loop print_matrix
	print newl

	ex:	mov	ah, 4ch
		int	21h	
Cod		ends
		end	code	