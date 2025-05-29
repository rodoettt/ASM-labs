title		Prim
		assume	cs:C, ds:D, ss:S

;описываем сегмент стека
S		segment	stack
		dw	128 dup (?)	;резервируем 128 слов с 								;неопределенным содержимым
S		ends	;закончили описание сегмента стека

;определяем символы возврата каретки и перевода строки
	cr = 0dh
	lf = 0ah

;описываем сегмент данных
D		segment
;резервируем место под переменные
N		dw	?	;размер массива
T		dw	?	;вспомогательная переменная
A		dw	100 dup (?)	; обрабатываемый массив
 
;размещаем тексты сообщений программы
CRLF	db	cr,lf,'$'	;последовательность символов для 						;перевода курсора в начало следующей 					;строки
SPACE	db	'  $'		;последовательность пробелов для 						;разделения чисел в строке
MSG1	db	'Razmer?: $'
MSG2	db	'Massive?:', cr, lf, '$'
MSG3	db	'Proizv lev razn: $'
MSG4	db	'Kol-vo zamen: $'
MSG5	db	'Itog massive:', cr, lf, '$'

;описываем данные процедуры ввода числа
string	db	255, 0, 255 dup (?)
errmsg	db	'Nedopust simv, mozno ispolz'
		db	'tolko cifr, perv simv mozhet bit'
		db	'znakom + ili -', cr, lf,'$'
negflag	dw	?
D		ends	;закончили описание сегмента данных

;описываем макрокоманду вывода текстовой строки
PRINT	macro	STR
		push	ax
		push	dx
		mov	ah, 9
		lea	dx, STR
		int	21h
		pop	dx
		pop	ax
		endm

;описываем сегмент кодов команд
C		segment
;описываем процедуру ввода целого числа в регистр ax
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
im2:		 cmp	byte ptr [si], '+'
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
		sub	byte ptr [si], '0'
		add	al, [si]
		adc	ah,0
		inc	si
		jmp	im1
ierr:		print	errmsg
		jmp	im
iex1:		cmp	negflag, 0
		je	iex
		neg	ax
iex:		pop	si
		pop	dx
		pop	bx
		ret
IntegerIn	endp
 
;описываем процедуру вывода целого числа из регистра ax
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
om1:		pop	dx
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
 
;основная программа
start:					;точка входа в программу
		mov	ax, D		;в ds заносим адрес сегмента данных
		mov	ds, ax

;вводим размер массива
		print	MSG1	;выводим приглашение к вводу  						;размера массива
		call	IntegerIn	;вызываем процедуру ввода числа
		mov	N, ax		;помещаем его в переменную N
		print	CRLF	;переводим курсор в начало следующей 					;строки

;цикл ввода массива
		print	MSG2	;выводим приглашение к вводу 							;массива
		mov	cx, N		;кладем в cx количество повторений 					;цикла
		lea	si, A 		;заносим в si смещение до начала 						;массива
m:		call	IntegerIn	;вызываем процедуру ввода числа
		mov	[si], ax	;введенное число из ax помещаем в 						;элемент массива, адресуемый si
		print	CRLF	;переводим курсор в начало следующей 					;строки
		add	si, 2		;формируем в si смещение до 							;следующего элемента массива
		loop	m 		;уменьшаем cx на 1 и, если он не равен 					;0, уходим на метку m

;цикл подсчета произведения левых разностей элементов ;массива
		mov	cx, N 	;формируем в cx количество 							;повторений цикла
		dec	cx
		lea	si, A+2 	;заносим в si смещение до второго 						;элемента массива
		mov	ax, 1 		;заносим в ax начальное значение 						;произведения
m1:		mov	bx, [si] 	;помещаем в bx значение очередного 					;элемента массива
		sub	bx, -2[si] 	;вычитаем из него значение 							;предыдущего элемента
		imul	bx 		;домножаем накопленное произведение 					;на полученную левую разность
		add	si, 2 		;формируем в si смещение до 							;следующего элемента массива
		loop	m1 		;уменьшаем cx на 1 и, если он не равен 					;0, уходим на метку m1

;выводим полученное произведение левых разностей
		print	MSG3	;оформляем вывод
		call	IntegerOut	;вызываем процедуру вывода целого 						;числа из ax
		print	CRLF	;переводим курсор в начало следующей 					;строки

; Цикл замены соседних элементов массива
        mov     cx, N          ; Загружаем размер массива в cx
        shr     cx, 1          ; Делим количество элементов на 2
        lea     si, A          ; Загружаем в si смещение до начала массива

m3:     mov     ax, [si]       ; Загружаем в ax значение текущего элемента
        mov     dx, [si+2]     ; Загружаем в dx значение следующего элемента
        mov     [si], dx       ; Меняем местами: записываем в текущий элемент значение следующего
        mov     [si+2], ax     ; Записываем в следующий элемент значение текущего
        add     si, 4          ; Переходим к следующей паре элементов
        loop    m3             ; Уменьшаем cx и продолжаем цикл, если cx не 0

 
;выводим количество замен и получившийся массив
		mov	ax, bx 	;помещаем счетчик замен в ax
		print	MSG4	;оформляем вывод
		call	IntegerOut	;вызываем процедуру вывода целого 						;числа из ax
		print	CRLF	;переводим курсор в начало следующей 					;строки

;цикл вывода массива
		print	MSG5	;оформляем вывод
		mov	cx, N 	;кладем в cx количество повторений 					;цикла
		lea	si, A		;заносим в si смещение до начала 						;массива
m4:		mov	ax, [si] 	;помещаем значение очередного 						;элемента массива в ax
		call	IntegerOut	;вызываем процедуру вывода целого 	
					;числа из ax
		print	SPACE	;выводим пробелы между числами
		add	si, 2 		;формируем в si смещение до 							;следующего элемента массива
		loop	m4		;уменьшаем cx на 1 и, если он не равен 					;0, уходим на метку m4

;завершаем выполнение программы
		mov	ah, 4ch
		int	21h
C		ends	;закончили описание сегмента кодов команд

		end	start	;закончили программу с указанием точки входа в 				;нее
