	title 22new
	assume cs:C, ds:D, ss:S
	
S	segment stack
	dw	128 dup	(?)
S	ends

D	segment
	cr = 0dh
	lf = 0ah

arith	dw	?
null	dw	?
arr		dw	?
arrSize	dw	?
pgph	dw	?
success	db	'Success$'
itr_1	db	'A[$'
itr_2	db	'] = $'  
err4a	db 	cr, lf, 'ERROR! 4aH$'
errSize	db	cr, lf, 'Invalid size', cr, lf, '$'
msgSize	db 	'Enter size of the array [1 - 100] = $'
CRLF	db	cr, lf, '$'
errO	db	'ERROR! Overflow!', cr, lf, '$'
string	db	255, 0, 255 dup (?)
errmsg	db	0dh, 0ah,'Invalid character, only '
		db	'numbers can be used, the first character '
		db	'can be a "+" or "-" sign', cr, lf, '$'
errMem	db	cr, lf, 'ERROR! Out of memory!$'

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
	mov bx, 0
aPr2:	
	print itr_1
	mov ax, bx
	call IntegerOut
	print itr_2
	mov ax, es:[si]
	call IntegerOut
	print CRLF
next22:	
	add	si, 2
	add bx, 1
	loop	aPr2
	ret
printArray		endp

start:
	mov ax, D 
	mov ds, ax
	mov bx, seg z ; ds, es содержат номер параграфа начала psp
	mov ax, es
	sub bx, ax ;  если из начального адреса фиктивного сегмента z вычесть es,то получим размер программы в параграфах.
	mov ah, 4ah ; сокращаем выделенный блок памяти
	int	21h
	jnc	a0 ; если программа заняла всю свободную часть до видеопамяти
	print err4a
	jmp ex
a0:
	mov arith, 0
	print msgSize
	call IntegerIn
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
	mov arrSize, ax
	
	shl	ax, 1
	add	ax, 15
	mov cl, 4
	shr ax, cl ; Получаем количество параграфов в ax
	mov pgph, ax ; Перенеосим в pgph
	
	mov bx, pgph
	mov ah, 48h ; выделяем блок памяти
	int 21h
	jnc a3 ; Если память выделена
	print errMem
	jmp ex
a3:
	mov arr, ax ; сохраняем адрес выделенной памяти в arr
	mov cx, arrSize ; размер массива переносим в cx
	mov si, 0 ; обнуление указателя si
aIn:
	push cx
	push si
	print itr_1
	mov ax, arrSize
	sub ax, cx ; Вычисляем индекс текущего элемента массива
	call IntegerOut
	print itr_2
	call IntegerIn
	print CRLF
	pop si
	pop cx
	mov es:[si], ax ; Сохраняем введенное значение по адресу, на который указывает si
	add	si, 2 ; Переходим на след элемент
	loop aIn
	
	mov si, 0
	mov cx, arrSize
aPr:
	mov ax, es:[si]
	add arith, ax
	or ax, ax
	js next2 ; если значение отрицательное, то прыгаем к другой метке
	mov dx, si
next2:	
	add		si, 2
	loop	aPr
	mov ax, arith
	mov bx, arrSize
	push dx
	xor dx, dx
	idiv bx ; получаем среднее арифметическое
	pop si
	mov es:[si], ax ; Сохраняем среднее арифметическое в соответствующем месте в памяти
	mov ax, arr[si]
	mov cx, arrSize
	xor si, si
	print CRLF
	call printArray
ex:		mov 	ah,	4ch
		int		21h			
C		ends

Z	segment ; фиктивный сегмент, чтобы узнать размер программы в параграфах
Z	ends
		end start