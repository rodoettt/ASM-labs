title	33
	assume	cs:c, ds:d, ss:s

s	segment	stack
	dw	128 dup ('ss')

s	ends

	cr = 0dh
	lf = 0ah

d	segment
crlf	db cr,lf,'$'
space	db ' $'
tab	db 09h, '$'

msgin	db 10, 13, 'input file:$'
msgout	db 10, 13, 'output file:$'
file	db 255, 0, 255 dup (?)
inhan	dw ?
outhan	dw ?
err_O	db 10, 13, 'file was not opened$'
err_c	db 10, 13, 'file was not created$'
buf	db 256 dup (?)
err_r	db 10, 13, 'reading error$'
err_w	db 10, 13, 'writing error$'
string	db 255, 0, 255 dup (?)
errmsg	db 'Invalid character, can be used'
	db 'numbers only, first character can be'
	db 'sign + or -', cr, lf, '$'
msg6	db 'Overflow detected!', cr, lf, '$'
negflag	dw ?
d	ends

print	macro	str
	push ax
	push dx
	mov ah, 9
	lea dx, str
	int 21h
	pop dx
	pop ax
	endm

c	segment

start:
	mov ax, d
	mov ds, ax ;  Загружаем сегмент данных
m2:	
	print msgin
	mov ah, 0ah
	lea dx, file
	int 21h ; При помощи прерывания 21h и функции 0Ah считываем строку (имя файла) в память по адресу file
	lea di, file + 2 ; Загрузим в di адрес, который находится на 2 байта выше начала file (длина файла)
	mov al, -1[di] ; записываем в al длину имени файла
	xor ah, ah
	add di, ax ; добавляем di к ax, перемещая указатель к концу имени файла, т.е. в di адрес куда нужно записать нулевой терминатор
	mov [di], ah ; в конце строки будет установлен нулевой символ (терминатор), чтобы имя файла воспринималось как строка
	mov ah, 3dh ; для открытия файла в режиме чтения
	lea dx, file + 2 ; загружается адрес строки с именем файла
	mov al, 2 ; режим открытия файла на чтение
	int 21h
	jnc m1 ; проверяем флаг переноса, установленный в рез. предыдущего прерывания, если файл открыт, то переходим на метку m1
	print err_o
	jmp m2

m1:	
	mov inhan, ax ; сохраняем дескриптор файла в переменную inhan

m3:	
	print msgout ; ввод имени выходного файла
	mov ah, 0ah
	lea dx, file
	int 21h ; При помощи прерывания 21h и функции 0Ah считываем строку (имя файла) в память по адресу file
	lea di, file+2 ; Загрузим в di адрес, который находится на 2 байта выше начала file (длина файла)
	mov al, -1[di]
	xor ah, ah
	add di, ax
	mov [di], ah
	mov ah, 3ch ; Отркрываем файл на запись
	lea dx, file + 2 ; Загружаем адрес строки с именем выходного файла в регистр dx
	xor cx, cx
	int 21h
	jnc m4
	print err_c
	jmp m3
m4:	print crlf
	mov outhan, ax ; Сохраняем дескриптор выходного файла

m7:	mov bx, inhan ; Переносим дескриптор входного файла в bx
	mov ah, 3fh ; Для чтения данных из открытого файла
	lea dx, buf ; Загружаем адрес буфера в dx
	mov cx,  1
	int 21h ; Читаес данные из файла
	jnc m5
	
	print err_r
m6:	mov ah, 3eh
	mov bx, inhan
	int 21h ; Закрываем файл, его дескриптор больше не действителен

	mov ah, 4ch
	int 21h

m5:	cmp ax, 0
	jz m6

	push cx
	push si
	xor si, si
	mov cx, ax
co1:	
	cmp buf[si], 224
	jae co2
	jmp co3
co2:	
	cmp buf[si], 255
	jbe co5
	jmp co3
co5:	
	sub buf[si], 32
co3:	
	add si, 1
	loop co1
co4:	
	pop si
	pop cx
	mov ah, 40h
	mov bx, outhan
	lea dx, buf
	int 21h ; Осуществляем запись в файл
	jnc m7
	print err_w
	jmp m6


c	ends
	end start
	