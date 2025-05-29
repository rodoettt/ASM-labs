	title 22new
	assume cs:C, ds:D, ss:S
	
S	segment stack
	dw	128 dup	(?)
S	ends

	cr = 0dh
	lf = 0ah

D	segment
arith		dw	?
null		dw	?
arr		dw	100 dup (?)
arrSize	dw	?
success	db	'Success$'
itr_1	db	'A[$'
itr_2	db	'] = $'  
errSize	db	cr, lf, 'Invalid size', cr, lf, '$'
msgSize	db 	'Enter size of the array [1 - 100] = $'
CRLF	db	cr, lf, '$'
errO	db	'ERROR! Overflow!', cr, lf, '$'
string	db	255, 0, 255 dup (?)
errmsg	db	0dh, 0ah,'Invalid character, only '
		db	'numbers can be used, the first character '
		db	'can be a "+" or "-" sign', cr, lf, '$'
msg1	db	cr, lf, 'Array A:', '$'
msg2	db	cr, lf, 'Array B: ', '$'


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
		mov 	arith, 0
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
	mov bx, 0
aPr2:	
	print itr_1
	mov ax, bx
	call IntegerOut
	print itr_2
	mov ax, arr[si]
	call IntegerOut
	print CRLF
next22:	
	add		si, 4 	; прибавляем 4, а не 2 байта для обращения к каждому элементу массива с четным индексом
prvrk:
	push bx
	mov bx, 2
	mov ax, arrSize
	imul bx
	pop bx
	cmp si, ax
	jl prvrk1
	mov si, 2		; после прохождения всех четных элементов, перемещаемся на 2 байт массива, чтобы проходиться по элементам с нечетными индексами
prvrk1:
	add bx, 1
	loop	aPr2
	ret
printArray		endp

start:
	mov ax, D 
	mov ds, ax
a0:
	print msgSize
	call IntegerIn
	mov arrSize, ax ; вводим размер массива
	cmp ax, 0 		; сравниваем с 0
	jg a1			; если больше 0, то перемещаемся на метку a1	
	print errSize	; если меньше, то выводим сообщение об ошибке и снова пытаемся ввести размер
	jmp a0
a1:
	cmp ax, 100		; сравниваем размер с 100
	jle a2			; если меньше 100, то перемещаемся на метку a2
	print errSize	; если больше, то выводим сообщение об ошибке и снова пытаемся ввести размер
	jmp a0
a2:
	print CRLF
	mov cx, arrSize	; переносим размер массива в cx, т.к. cx выступает счетчиком в цикле
	mov si, 0		; переносим 0 в si, т.к. массив в памяти расположен с нулевого адреса
	print msg1
	print CRLF
aIn:
	push cx
	push si
	print itr_1
	mov ax, arrSize
	sub ax, cx
	call IntegerOut
	print itr_2
	call IntegerIn
	print CRLF
	pop si
	pop cx
	mov arr[si], ax	; перемещаем введеное значение в адрес в массив
	add	si, 2		; добавляем два байта для обращения к следующему элементу массива
	loop aIn		; цикл ввода массива, при каждом круге cx уменьшается на 1, пока не станет 0
	
	mov si, 0		; после выхода из цикла снова обнуляем si для корректного обращения к элементом массива в дальнейшем
	mov cx, arrSize	; обновлеяем счетчик на размер массива
	print CRLF
	print msg2
	print CRLF
	call printArray	; выводим массив по заданию
	ex:		mov 	ah,	4ch
		int		21h			
C		ends
		end start