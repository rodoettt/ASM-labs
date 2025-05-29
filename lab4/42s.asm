title lab_4_2
	assume cs:c, ds:d, ss:s 
	
s 	segment stack
	dw 128 dup ('ss')
s 	ends

	cr = 0dh 
	lf = 0ah

d 	segment

	MSG_IN	db 10,13,'Input file name: $'
	MSG_OUT	db 10,13,'Output file name: $'
	FILE 	db 255,0, 255 dup (?)
	HANDLE 	dw ?
	HANDLE_	dw ?
	ERR_O 	db 10,13,'File was not opened$'
	ERR_C 	db 10,13,'File was not created$'
	ERR_R 	db 10,13,'Reading error$'
	ERR_W 	db 10,13,'Writing error$'
	tab 	db 	09h, '$' 
	space   db  " $"
	
	newl	db	cr, lf, '$' 
	string 	db 255, 0, 255 dup (?)
	errmsg	db	'Недопустимый символ, можно использовать'
			db	'только цифры, первый символ может быть'
			db 	'знаком + или - ', cr, lf, '$'
	negflag dw	?
d 	ends 

PRINT macro STR
			push	ax
			push	dx
			mov		ah, 9
			lea		dx, STR
			int		21h
			pop		dx
			pop		ax
		endm
		


c 	segment


start: 	
		mov 	bx, seg z ; ds, es содержат номер параграфа начала psp
		mov 	ax,es
		sub 	bx,ax  ; если из начального адреса фиктивного сегмента z вычесть es,то получим размер программы в параграфах.
		mov 	ah,4ah ; сокращаем выделенный блок памяти
		int 	21h
		jnc 	mm1 ; если программа заняла всю свободную часть до видеопамяти
		
		mov 	cx,d
		mov 	ds,cx ; принудительно устанавливаем ds на сегмент данных, т.к. изначально установлен на начало psp программы
		mov 	ah,9
		lea 	dx,ERR_O 
		int 	21h
		mov 	ah,4ch ; завершение выполнения программы, управление переходит ОС
		int 	21h
		
mm1:
		mov		ax, 4096 ; количество байтов
		mov		bx, ax
		mov		ah, 48h ; выделяем блок памяти размером 4096 байтов
		int		21h
		jnc 	mm2 ; Выделила ли система блок памяти
		test    bx,bx ; Максимальный размер блока памяти, который она может выделить
		jnz		mm3
		mov 	cx,d 
		mov 	ds,cx ; принудительно устанавливаем ds на сегмент данных, т.к. изначально установлен на начало psp программы
		mov 	ah,9
		lea 	dx,ERR_C 
		int 	21h
		mov 	ah,4ch ; ; завершение выполнения программы, управление переходит ОС
		int 	21h
mm3:	mov		ah, 48h ; Выделяем возможную память
		int		21h
		
mm2:	mov		es, ax ; Устанавливаем сегмент es на выделенную память
		mov 	ax,d 
		mov 	ds,ax ;
m2: 	lea 	dx,MSG_IN 
		mov 	ah,9 
		int 	21h 
		mov 	ah,0ah ; ввод строки
		lea 	dx,FILE ; адрес файла в dx
		int		21h 
		lea 	di,FILE+2 ; загрузим в di адрес, который находится на 2 байта выше начала file (длина файла)
		mov 	al,-1[di] ; перемещаем длину файла в al
		xor 	ah,ah 
		add 	di,ax ; добавляем di к ax, перемещая указатель к концу имени файла, т.е. в di адрес куда нужно записать нулевой терминатор
		mov 	[di],ah 
		mov 	ah,3dh ; открываем файл для чтения
		lea 	dx,FILE+2 ; загружается адрес строки с именем файла
		xor 	al,al 
		int 	21h 
		jnc 	m1 ; проверяем флаг переноса, установленный в рез. предыдущего прерывания, если файл открыт, то переходим на метку m1
		lea 	dx,ERR_O 
		mov 	ah,9 
		int 	21h 
		jmp 	m2 
m1: 	mov 	HANDLE,ax ; ; сохраняем дескриптор файла в переменную handle 
m3: 	lea 	dx,MSG_OUT 
		mov 	ah,9 
		int 	21h 
		mov 	ah,0ah 
		lea 	dx,FILE 
		int 	21h 
		lea 	di,FILE+2 
		mov 	al,-1[di] 
		xor 	ah,ah 
		add 	di,ax 
		mov 	[di],ah 
		mov 	ah,3ch ; Отркрываем файл на запись
		lea 	dx,FILE+2 ; Загружаем адрес строки с именем выходного файла в регистр dx
		xor 	cx,cx 
		int 	21h 
		jnc 	m4 
		lea 	dx,ERR_C 
		mov 	ah,9 
		int 	21h 
		jmp 	m3 
m4: 	mov 	HANDLE_,ax ; Сохраняем дескриптор выходного файла
m7: 	mov 	bx,HANDLE ; Переносим дескриптор входного файла в bx
		push	ds
		push	es
		pop		ds ; ds установили туда же, куда указывает es
		xor		dx,dx ; обнуляем dx, так как смещение нулевое
		mov 	ah,3fh  ; Для чтения данных из открытого файла
		mov 	cx, 4096 
		int 	21h
		pop		ds ; возвращаем ds на свой сегмент данных
		jnc 	m5 
		lea 	dx,ERR_R 
		mov 	ah,9 
		int 	21h 
m6: 	mov 	ah,3eh ; закрытие входного файла
		mov 	bx,HANDLE 
		int 	21h 
		mov 	ah,3eh ; закрытие выходного файла
		mov 	bx,HANDLE_ 
		int 	21h
		mov		ah, 49h ; освобождение памяти
		int		21h
		mov 	ah,4ch 
		int 	21h 
m5: 	cmp 	ax,0 
		jz 		m6
		
		xor 	si, si
		mov 	cx,ax
co1: 
		cmp 	byte ptr es:[si], 224
		jae		co2 
		jmp 	co3 
co2: 	cmp 	byte ptr es:[si], 255
		jbe		co5
		jmp 	co3
co5:	sub 	byte ptr es:[si], 32
co3: 	add 	si,1 
		loop 	co1 
co4: 	pop 	si 
		pop 	cx 
		
		mov		cx, ax
		mov 	ah,40h ; Код функции для записи в файл
		mov 	bx,HANDLE_
		push	ds
		push 	es
		pop		ds
		xor 	dx,dx 
		int 	21h ; Осуществляем запись в файл
		pop		ds
		jnc 	m7 	
		lea 	dx,ERR_W
		mov 	ah,9 
		int 	21h 
		jmp 	m6 

c 	ends 
z segment ; фиктивный сегмент, чтобы узнать размер программы в параграфах
z ends
end start