    title laba5
    
    assume cs:c, ds:d, ss:s
s   segment stack
dw 128 dup (?)
s ends

d segment
    msg1 db 10,13,'Input file name:$'
    msg2 db 10,13,'Output file name:$'
    fname db 255,0, 255 dup (?)
    inhan dw ?
    outhan dw ?
    er1 db 10,13,'File does not open$'
    er2 db 10,13,'File does not create$'
    buf db 256 dup (?)
    er3 db 10,13,'Error read file$'
    er4 db 10,13,'Error record file$'
    
    negflag	dw	?
    string	db	255, 0, 255 dup (?)
    errof 	db 	0dh, 0ah, 'ERROR!  Overfull$'
    errmsg	db	0dh, 0ah,'Invalid character, only '
	        db	'numbers can be used, the first character '
	        db	'can be a "+" or "-" sign', cr, lf,'$'
    entor db 	0dh, 0ah, '$'
    lenbuf 	dw 	?
    N   dw ?
    speed db 0dh, 0ah, 'Enter speed: $'
    success db 	0dh, 0ah, 'Successful!$'
d ends

c segment
        cr = 0dh        
        lf = 0ah
    
PRINT 	macro STR
	push 	ax
        push    dx
	mov 	ah, 09h
	lea 	dx, STR
	int 	21h
        pop     dx
	pop 	ax
endm
IntegerIn	proc
im:		
		push	bx
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
im2:		
		cmp	byte ptr [si], '+'
		jne	im1
		inc	si
im1:		
		cmp	byte ptr [si], cr
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
overfull: 	
		mov 	ah,9
		lea	dx,errof
		int 	21h
		mov 	ah,4ch
		int 	21h	
ierr:		
		mov 	ah,9
		lea	dx,errmsg
		int 	21h
		jmp	im
iex1:		
		cmp	negflag, 0
		je	iex2
		cmp 	ax, 32768
		ja 	overfull
		neg	ax
		jmp 	iex
iex2: 		
		cmp 	ax, 32767
		ja 	overfull
		jmp 	iex
iex:		
		pop	si
		pop	dx
		pop	bx
		ret
IntegerIn	endp


            x 	    dw   ?
            o1c		dw   ?
            
start:      
		mov ax,d
        mov ds,ax ; устанавливаем ds на сегмент данных
open:       
		PRINT msg1 ;выводим сообщение
            
        mov ah,0ah ; вводим имя файла
        lea dx,fname ; адре имени файла в dx
        int 21h ; 
            
        lea di,fname+2; загрузим в di адрес, который находится на 2 байта выше начала file (длина файла)
        mov al,-1[di]; длина файла
        xor ah,ah
        add di,ax; добавляем di к ax, перемещая указатель к концу имени файла, т.е. в di адрес куда нужно записать нулевой терминатор
        mov [di],ah; добавление 0 в конец строки
            
        mov ah,3dh ; открываем файл для чтения
        lea dx,fname+2
        xor al,al 
        int 21h
            
        jnc inh ; проверяем флаг переноса, установленный в рез. предыдущего прерывания, если файл открыт, то переходим на метку inh
        PRINT er1; ошибка открытия
        jmp open
            
inh:        
		mov inhan,ax; сохраняем дескриптор файла в переменную inhan
create:     
		PRINT msg2
            
        mov ah,0ah ; вводим имя файла, который хотим создать
        lea dx,fname
        int 21h
            
        lea di,fname+2
        mov al,-1[di]
        xor ah,ah
        add di,ax
        mov [di],ah
            
        mov ah,3ch ;создание
        lea dx,fname+2
        xor cx,cx
        int 21h
            
        jnc outh
        PRINT er2; ошибка создания
		jmp create
outh:       
		mov outhan,ax ; сохраняем дескриптор выходного файла в переменную outhan

spe:	    
		PRINT speed
		call IntegerIn ;вводим скорость(тики) между обработками символов 
		cmp ax, 0
		JZ 	spe ; если равна 0, то вводим повторно

		mov N, ax
		mov cs:x, ax ; помещаем нашу задержку в Х

		mov ax, 351ch; взять вектор прерывания
		int 21h
		mov word ptr cs:o1c, bx
		mov word ptr cs:o1c + 2, es; сохраняем адрес старого обработчика прерываний

		mov ax, 251ch; установка нового вектора прерывания
		lea dx, time; адрес нового обработчика
		push ds
		push cs
		pop ds ; перенаправляем ds на cs
		int 21h
		pop ds ;возвращаем ds
		PRINT entor


read:       
		mov bx,inhan  ;чтение
        mov ah,3fh
        lea dx,buf; адрес буфера для чтения данных
        mov cx,256; число считываемых байт
        int 21h
        jnc change
        PRINT er3; ошибка чтения

change:         
        cmp ax, 0; считано 0 байт
		jz  exit    ;выходим из программы если нечего записывать
		mov lenbuf, ax; число считанных байт
						;Цикл замены символов		
		mov cx, lenbuf
		push di
		xor  di,di
a1:	    
		cmp cs:x, 0 ;задержка 
		jg 	a1
		mov ah, 02h ;вывод звездочки на экран
		mov dl, '.'  
		int 21h

		mov ax, N
		add cs:x, ax ;прибавляем к нашим тикам еще N для следующего круга
  
for1:       
		cmp 	buf[di], 192
		jae		co2 
		jmp 	co3 
co2: 	
		cmp 	buf[di], 223
		jbe		co5
		jmp 	co3
co5:	
		sub 	buf[di], 95 
co3: 		
		inc 	di 
		loop 	a1
		pop		di
           
            
write:      
		mov ah,40h ; Код функции для записи в файл
        mov bx,outhan
        mov cx, lenbuf; число записываемых байт/ длина буфера
        lea dx,buf; записываем адрес буфера с данными
        int 21h
        jnc bbb 
        PRINT er4
bbb:
		jmp read           

exit: 	
		push ds
		mov  dx, word ptr cs:o1c; старый вектор прерывания
		mov  ax, word ptr cs:o1c + 2
		mov  ds, ax

		mov 	ax, 251ch; возвращение старого обработчика на место
		int 	21h
		pop 	ds 
          
        mov ah,3eh ; Код функции для закрытия входного файла
        mov bx,inhan ; переносим дескриптор в bx
        int 21h
        mov ah,3eh  ; Код функции для закрытия выходного файла
        mov bx,outhan ; переносим дескриптор в bx
        int 21h
        mov ah,4ch ; Код функции для закрытия файла
        int 21h
                    
; Новый обработчик прерываний
time:	   
		pushf
		call dword ptr cs:o1c; вызов старого обработчика
		sti; установка I флага - внешние прерывания разрешены
		dec cs:x
		iret
c ends
end start
