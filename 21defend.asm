	a dw ?
	b dw ?
	c dd ?

	;c = |(1,125*a^2 - a * b)/2|

	mov ax, d
	mov ds, ax
	xor dx, dx

	mov 	word ptr c, 0
	mov		word ptr c+2, 0
	mov	 	ax, a
	imul 	ax ;		 Получили a^2
	mov 	word ptr c, ax
	mov		word ptr c+2, dx ; Перемещаем a^2
	sar		word ptr c+2, 1
	rcr		word ptr c, 1
	sar		word ptr c+2, 1
	rcr		word ptr c, 1
	sar		word ptr c+2, 1
	rcr		word ptr c, 1 ; Делаем сдвиг вправо на 3 бита, тем самым умножая a^2 на 1/8
	mov		ax, a
	imul	ax
	add 	word ptr c, ax
	adc		word ptr c, dx ; Получили 1,125*a^2
	mov		ax, a
	mov		bx, b
	imul	bx ; 		Получили a * b
	sub		word ptr c, ax
	sbb		word ptr c+2, dx ; 1,125*а^2-a*b


	sar		word ptr c+2, 1
	rcr		word ptr c, 1 ; (1,125*а^2-a*b)/2

	cmp		word ptr c+2, 0 ; Сравним с 0
	jge		final	; Если больше или равно 0, то переходим к завершению, если меньше, то получаем противоположное значение инвертируя все биты и прибавляя единицу.
	not		word ptr c
	not		word ptr c+2
	add		word ptr c, 1
	adc		word ptr c+2,0
final:
	mov		ax,word ptr c
	mov		dx,word ptr c+2 


