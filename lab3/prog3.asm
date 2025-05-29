assume	cs:c, ds:d, ss:s
s	segment	stack
	dw	128 dup (?)  
s	ends
d	segment
in_f 	db 	0dh, 0ah,'Input file: $'
out_f 	db 	0dh, 0ah, 'Output file: $'
in_?	db 	0dh, 0ah,'Input filename: $'
out_? 	db 	0dh, 0ah,'Output filename: $'
fname 	db 	255, 0, 255 dup (?)
inhan 	dw 	?
outhan 	dw 	?
lenbuf 	dw 	?
buf 	db 	256 dup (?)
er1 	db 	0dh, 0ah, 'File not open!$'
er2 	db 	0dh, 0ah,'File not create!$'
er3 	db 	0dh, 0ah,'Read error!$'
er4 	db 	0dh, 0ah,'Record error!$'
d	 ends
c	 segment

print 	macro 	STR
	mov 	ah, 9
	lea 	dx, STR
	int 	21h
	endm

begin:		mov	ax, d
		mov	ds, ax

; Исходный файл
m2: 		print 	in_?
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
		jnc 	m1

		print 	er1; ошибка открытия
		jmp 	m2

m1: 		mov 	inhan, ax; присвоение идентификатора файла

; Конечный файл
m3: 		print 	out_?
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
		jnc 	m4

		print 	er2; ошибка создания
		jmp 	m3

m4: 		mov 	outhan, ax
;Работа с исходным файлом
m7: 		mov 	bx, inhan
		mov 	ah, 3fh; чтение из файла
		lea 	dx, buf; адрес буфера для чтения данных
		mov 	cx, 256; число считываемых байт
		int 	21h
		jnc 	m8

		print 	er3; ошибка чтения
		jmp 	m6

m8:		cmp 	ax, 0; считано 0 байт
		jz 	m6
;Вывод содержимого исходного файла		
		mov 	lenbuf, ax; число прочитанных байт
		print 	in_f
		mov 	cx, lenbuf
		xor 	si, si
p1:		mov 	ah, 02h
		mov 	dl, buf[si]; посимвольный вывод
		int 	21h
		inc 	si
		loop 	p1
;Цикл замены символов		
		mov 	cx,lenbuf
 		xor 	si,si

C1:		cmp 	byte ptr buf[si], 160; нижняя граница 1 части
		jb  	end_change

		cmp 	byte ptr buf[si], 241; обработка ё
		je 	change2

		cmp 	byte ptr buf[si], 255; верхняя граница 2 части
		ja  	end_change

		cmp 	byte ptr buf[si], 224; нижняя граница 2 части
		jb  	change1?

		jmp 	change2
change1?:	cmp 	byte ptr buf[si], 175; верхняя граница 1 части
		ja  	end_change

		JMP 	change1

change2:	sub 	buf[si], 151; замена символа 2 части
		JMP 	end_change
		
change1:	sub 	buf[si], 95; замена символа 1 части
		
end_change:	inc 	si
		loop 	C1

;Вывод содержимого конечного файла
		print 	out_f
		mov 	cx, lenbuf
		xor 	si, si
p2:		mov 	ah, 02h
		mov 	dl, buf[si]
		int 	21h
		inc 	si
		loop 	p2
		jmp 	m5
;Закрытие файлов и завершение работы
m6: 		mov 	ah, 3eh
		mov 	bx, inhan
		int 	21h

		mov 	ah, 3eh
		mov 	bx, outhan
		int 	21h

		mov 	ah, 4ch
		int 	21h
; Работа с конечным файлом
m5: 		mov 	ah, 40h; запись в файл
		mov 	bx, outhan
		mov 	cx, lenbuf; число записываемых байт
		lea 	dx, buf; адрес буфера с данными
		int 	21h
		jc  	err
		jmp 	m7

err:		print 	er4
		jmp 	m6

c		ends
		end	begin
