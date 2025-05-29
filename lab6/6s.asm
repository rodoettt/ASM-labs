assume	cs:c, ds:d, ss:s
sizebuf = 18 
s	segment	stack
	dw	128 dup (?)  
s	ends
d	segment
cr = 0dh
lf = 0ah
in_?	db 	0dh, 0ah,'Input filename: $'
out_? 	db 	0dh, 0ah,'Output filename: $'
Delay? 	db 	0dh, 0ah, 'Enter delay: $'
fname 	db 	255, 0, 255 dup (?)
inhan 	dw 	?
outhan 	dw 	?
currlen dw 	?
buf 	dw 	?
tact 	dw 	?
mflag 	dw 	?
er_mem 	db 	0dh, 0ah, 'ERROR! Out of memory!$'
er_op	db 	0dh, 0ah, 'File not open!$'
er_cre 	db 	0dh, 0ah,'File not create!$'
er_re 	db 	0dh, 0ah,'Read error!$'
er_wr 	db 	0dh, 0ah,'Record error!$'
er_4ah 	db 	0dh, 0ah, 'ERROR! 4ah$'
errof 	db 	0dh, 0ah, 'ERROR!  Overfull$'
success db 	0dh, 0ah, 'Successful!$'
endline db 	0dh, 0ah, '$'
curradd db   	0dh, 0ah, 'Current address: $'

string	db	255, 0, 255 dup (?)
errmsg	db	0dh, 0ah,'Invalid character, only '
	db	'numbers can be used, the first character '
	db	'can be a "+" or "-" sign', cr, lf,'$'
negflag	dw	?
d	 ends
c	 segment

delay 	dw   	?
old1c	dw   	?

print 	macro 	STR
	push 	ax
	push 	dx
	mov 	ah, 9
	lea 	dx, STR
	int 	21h
	pop 	dx
	pop 	ax
	endm

IntegerIn	proc
im:		push	bx
		push	dx
		push	si
		mov	ah, 0ah
		lea	dx, string
		int	21h
		xor	ax, ax
		lea	si, string+2
		mov	negflag, ax
		cmp	byte ptr [si], '-'
		jne	im2
		not	negflag
		inc	si	
		jmp	im1
im2:		cmp	byte ptr [si], '+'
		jne	im1
		inc	si
im1:		cmp	byte ptr [si], cr
		je	iex1
		cmp	byte ptr [si], '0'
		jb	ierr
		cmp	byte ptr [si], '9'
		ja	ierr
		mov	bx, 10
		mul	bx
		jo 	overfull
		sub	byte ptr [si], '0'
		add	al, [si]
		jo 	overfull
		adc	ah,0
		jc 	overfull
		inc	si
		jmp	im1
overfull: 	mov 	ah,9
		lea	dx,errof
		int 	21h
		mov 	ah,4ch
		int 	21h	
ierr:		mov 	ah,9
		lea	dx,errmsg
		int 	21h
		jmp	im
iex1:		cmp	negflag, 0
		je	iex2
		cmp 	ax, 32768
		ja 	overfull
		neg	ax
		jmp 	iex
iex2: 		cmp 	ax, 32767
		ja 	overfull
		jmp 	iex
iex:		pop	si
		pop	dx
		pop	bx
		ret
IntegerIn	endp

IntegerOut		proc
		push	ax
		push	bx
		push	cx
		push	dx
		xor	cx, cx
		mov	bx, 10
		cmp	ax, 0
		jge	om
		neg	ax
		push	ax
		mov	ah, 2
		mov	dl, '-'
		int	21h
		pop	ax
om:		inc	cx
		xor	dx, dx
		div	bx
		push	dx
		or	ax, ax
		jnz	om
om1:	        pop	dx
		add	dx, '0'
		mov	ah, 2
		int	21h
		loop	om1
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		ret
IntegerOut		endp

begin:		mov	ax, d
		mov	ds, ax

		mov 	bx, seg z
   		mov 	ax, es
 		sub 	bx, ax
    		mov 	ah, 4ah
    		int 	21h
    		jnc 	open
    		print 	er_4ah
    		JMP 	bad_exit

; Исходный файл
open: 		print 	in_?
		mov 	ah, 0ah; ввод имени файла
		lea 	dx, fname
		int 	21h

		lea 	di, fname+2; адрес начала строки
		mov 	al, -1[di]; размер строки
		mov 	ah, 0
		add 	di, ax; переход на конец строки
		mov 	[di], ah; добавление 0 в конец строки

                mov 	ah, 3dh; открытие файла
		lea 	dx, fname+2
		mov 	al, 0; для чтения
		int 	21h
		jnc 	handle1

		print 	er_op; ошибка открытия
		jmp 	open

handle1:	mov 	inhan, ax; присвоение идентификатора файла

; Конечный файл
create:		print 	out_?
		mov 	ah, 0ah
		lea 	dx, fname
		int 	21h

		lea 	di, fname+2
		mov 	al, -1[di]
		mov 	ah, 0
                add 	di, ax
		mov 	[di], ah

		mov 	ah, 3ch; создание файла
		lea 	dx, fname+2
		xor 	cx, cx
		int 	21h
		jnc 	handle2

		print 	er_cre; ошибка создания
		jmp 	create

handle2:	mov 	outhan, ax

; Выделение памяти под буфер
		mov 	bx, 2
		mov 	ah, 48h
		int 	21h
		jnc 	continue

		print 	er_mem
		JMP 	bad_exit

continue:	mov 	buf, ax; адрес выделенного блока памяти

del?:		print 	delay?
		call 	IntegerIn
		cmp 	ax, 0
		JZ 	del?

		mov 	tact, ax
		mov 	cs:delay, ax

		push 	es
		mov 	ax, 351ch; взять вектор прерывания
  		int 	21h
  		mov 	word ptr cs:old1c, bx
  		mov 	word ptr cs:old1c + 2, es; сохраняем адрес старого обработчика прерываний
  		pop 	es

  		mov 	mflag, 1

copy:  		print 	curradd
    		mov     ax, cs
    		call    IntegerOut
    		cmp     mflag, 0
    		jnz     m9
    		mov     ax, cs
    		sub     ax, c
    		add     ax, s
    		push    ax

m9:		push    cs
    		mov     bx, seg z
    		mov     ax, s
    		sub     bx, ax
    		mov     ah, 48h
    		int     21h
    		jnc     m10
    		jmp     exit

m10:		mov     es, ax
    		mov     cl, 3
    		shl     bx, cl

    		mov     cx, bx
    		xor     bp, bp

m11:   		mov     ax, [bp]
    		mov     es:[bp], ax
    		add     bp, 2
    		loop    m11

    		mov     ax, es
    		add     ax, c
    		sub     ax, s
    		lea     si, m12
    		pushf
    		push    ax
    		push    si
    		iret

m12:  		mov     cs:delay, 0
    		mov     ax, cs
    		sub     ax, c
    		add     ax, d
    		mov     ds, ax
    		mov     ax, cs
    		sub     ax, c
    		add     ax, s
    		mov     ss, ax 		

  		mov 	ax, 251ch; установка нового вектора прерывания
  		lea 	dx, tim; адрес нового обработчика
  		push 	ds
  		push 	cs
  		pop 	ds
  		int 	21h
  		pop 	ds

  		pop     es
   		mov     ax, es:delay
   		add     cs:delay, ax

    		cmp     mflag, 0
    		jnz     read
    		pop     es
    		mov     ah, 49h
    		int     21h

;Работа с исходным файлом
read: 		mov 	bx, inhan
		mov 	ah, 3fh; чтение из файла
		mov 	cx, sizebuf; число считываемых байт
		mov 	si, buf; адрес буфера для чтения данных
		push 	ds
		mov 	ds, si
		mov 	dx, 0
		
		int 	21h
		pop 	ds
		jnc 	change

		print 	er_re; ошибка чтения
		jmp 	bad_exit

change:		cmp 	ax, 0; считано 0 байт
		je 	exit
		mov 	currlen, ax; число считанных байт
		
;Цикл замены символов	
		push 	es	
		mov 	cx, currlen
		mov 	es, buf
 		xor 	si, si

C1:		cmp 	cs:delay, 0
  		jg 	C1
  		
  		mov 	ax, tact
  		add 	cs:delay, ax
for1:       
	    cmp 	byte ptr es:[si],224
		jae		co2 
		jmp 	co3 
co2: 	cmp 	byte ptr es:[si], 255
		jbe		co5
		jmp 	co3
co5:	sub 	byte ptr es:[si], 32 
co3: 		inc 	si 
		loop 	C1
		pop	es
		JMP write


; Работа с конечным файлом
write: 		mov 	ah, 40h; запись в файл
		mov 	bx, outhan
		push 	ds
		mov 	cx, currlen; число записываемых байт
		mov 	si, buf; адрес буфера c данными
		mov 	ds, si
		mov 	dx, 0
		int 	21h
		pop 	ds
		jc  	err

		mov 	mflag, 0
		jmp 	copy

; Освобождение памяти, закрытие файлов и завершение работы
exit: 		print 	success
		lea     si, exit1
    		push    ss
    		pushf
    		push    cs
    		push    si
    		iret

exit1: 		mov     ax, d
    		mov     ds, ax
    		mov     ax, s
    		mov     ss, ax
    		pop     es
   		mov     ah, 49h
    		int     21h

    		push    es
    		mov     es, buf
    		mov     ah, 49h
    		int     21h
    		pop     es

		push 	ds
  		mov 	dx, word ptr cs:old1c; старый ветктор прерывания
  		mov 	ax, word ptr cs:old1c + 2
  		mov 	ds, ax

  		mov 	ax, 251ch; возвращение старого обработчика на место
  		int 	21h
  		pop 	ds

bad_exit:	mov 	ah, 3eh
		mov 	bx, inhan
		int 	21h

		mov 	ah, 3eh
		mov 	bx, outhan
		int 	21h

		mov 	ah, 4ch
		int 	21h

; Новый обработчик прерываний
tim:		pushf
  		call 	dword ptr cs:old1c; вызов старого обработчика
  		sti; поднятие I флага - внешние прерывания разрешены
  		dec 	cs:delay
  		iret

err:		print 	er_wr; Ошибка записи
		jmp 	bad_exit

c		ends
z 		segment
z		ends
		end	begin