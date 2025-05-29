	title 42s
	assume cs:C, ds:D, ss:S
	
S	segment stack
	dw	128 dup	(?)
S	ends

	cr = 0dh
	lf = 0ah

D	segment
arr		dw	?
pgph	dw	?
arrSize	dw	?
success	db	'Success$'
itr_1	db	'A[$'
itr_2	db	'] = $' 
err4a	db 	CR, LF, 'ERROR! 4aH$' 
errSize	db	cr, lf, 'Invalid size', cr, lf, '$'
msgSize	db 	'Enter size of the array [1 - 100] = $'
CRLF	db	cr, lf, '$'
errMem	db 	CR, LF, 'ERROR! Out of memory!$' 
errO	db	'ERROR! Overflow!', cr, lf, '$'
string	db	255, 0, 255 dup (?)
errmsg	db	0dh, 0ah,'Invalid character, only '
		db	'numbers can be used, the first character '
		db	'can be a "+" or "-" sign', cr, lf, '$'
msg1	db	cr, lf, 'arithmetic mean: ', '$'
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
	add		si, 2
	add bx, 1
	loop	aPr2
	ret
printArray		endp

start:
	mov ax, D 
	mov ds, ax
	mov bx, seg Z ; ds, es содержат номер параграфа начала psp
	mov ax, es
	sub bx, ax ;  если из начального адреса фиктивного сегмента z вычесть es,то получим размер программы в параграфах.
	mov ah, 4aH ; сокращаем выделенный блок памяти
	int 21h
	jnc a0 ; если программа заняла всю свободную часть до видеопамяти
	print err4a
	jmp ex
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
	mov cx, arrSize
	
	shl 	ax, 1
	add 	ax, 15
	mov 	cl, 4
	shr 	ax, cl ; Получаем количество параграфов в ax
	mov 	pgph, ax ; Перенеосим в pgph
		
	mov 	bx, pgph
	mov 	ah, 48h ; выделяем блок памяти
	int 	21h
	jnc 	ac ; Если память выделена
	print	errMem
	jmp 	ex
ac:	
	mov 	arr, ax ; сохраняем адрес выделенной памяти в arr
	mov 	cx, arrSize	; размер массива переносим в cx
	mov si, 0 ; обнуление указателя si
aIn: 
	push cx		; ввод элементов массива
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
	dec cx
outer_loop: ; сортировка пузырьком
	mov si, 0 
	push cx
inner_loop:
	mov ax, es:[si]	
	mov bx, es:[si+2]
	cmp ax, bx	; сравниваем текущий и следующий элемент
	js noswap ; если меньше, то не меняем элементы
	mov es:[si], bx
	mov es:[si+2], ax
noswap:
	add si, 2
	loop inner_loop
	pop cx
	loop outer_loop
m2:
	mov cx, arrSize
	xor si, si
	print CRLF
	call printArray
ex:		mov 	ah,	4ch
		int		21h			
C		ends		
		
Z		segment ; фиктивный сегмент, чтобы узнать размер программы в параграфах
Z		ends
		end		start