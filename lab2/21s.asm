title	Prim
assume cs:C, ds:D, ss:S

S	segment stack
	dw 128 dup (?)
S	ends

D	segment
	cr = 0dh
	lf = 0ah

a	dw	?
b	dw	?
x	dw	?
temp1	dw 	?
temp2	dw	?
temp3	dw	?
temp4	dw	?

STR1	db	'Enter a:', 0ah, '$'
STR2	db	0ah,'Enter b:', 0ah, '$'
STR3	db	0ah,'Enter c:', 0ah, '$'



string	db	255, 0, 255 dup (?)
errmsg1	db	'Unavailable symbol, you can use'
		db	'only digits, first symbol can be'
		db	'+ or -', cr, lf,'$'
errmsg2 db	'Overflow detected!'
		db	'Please, try again', cr, lf, '$'
errmsg3 db	'Division by zero!', cr, lf, '$'
MSG6	db		lf, 'Result: ', cr, lf,'$'
CRLF	db	cr, lf, '$'
negflag	dw	?
D		ends

print	macro	str
	push ax
	push dx
	mov ah,9
	lea dx,str
	int 21h
	pop dx
	pop ax
	endm

C	segment 
integerin	proc
im:	
	push bx
	push dx
	push si
	mov ah, 0ah
	lea dx, string
	int 21h
	xor ax, ax
	lea si, string+2
	mov negflag, ax
	cmp byte ptr [si], '-'
	jne im2
	not negflag
	inc si
	jmp im1
im2:	
	cmp byte ptr [si], '+'
	jne im1
	inc si
im1:	
	cmp byte ptr [si], cr
	je iex1
	cmp byte ptr [si], '0'
	jb ierr
	cmp byte ptr [si], '9'
	ja ierr
	mov bx, 10
	imul bx
	sub byte ptr [si], '0'
	add al, [si]
	adc ah, 0
	inc si
	jmp im1
ierr:	
	print errmsg1
	jmp im
iex1:	
	cmp negflag, 0
	je iex
	neg ax
iex:	
	pop si
	pop dx
	pop bx
	ret
integerin	endp

integerout proc
    push ax
    push bx
    push cx
    push dx
    xor cx, cx
    mov bx, 10
    cmp ax, 0
    jge om
    neg ax
    push ax
    mov ah, 2
    mov dl, '-'
    int 21h
    pop ax
om:
    inc cx
    xor dx, dx
    idiv bx
    push dx
    or ax, ax
    jnz om
om1:
    pop dx
    add dx, '0'
    mov ah, 2
    int 21h
    loop om1
    pop dx
    pop cx
    pop bx
    pop ax
    ret
integerout endp

Check proc
    jno k
	print CRLF
    print errmsg2
    jmp ex
k:  ret

calculation proc
m1:
	mov ax, a
	imul ax
	call Check
	mov bx, 5
	imul bx
	mov cx, ax
	mov ax, b
	imul ax
	call Check
	mov bx, b
	imul bx
	mov bx, 7
	imul bx
	call Check
	add ax, cx
	jz ze1
	push ax ; 5a^2+7b^3
m2:
	mov ax, a
	imul ax
	mov bx, a
	imul bx
	call Check
	mov cx, ax
	mov ax, b
	imul ax
	imul ax
	call Check
	imul cx ; a^3*b^4
	push ax
m3:
	mov ax, a
	imul ax
	imul ax
	call Check
	mov bx, 5
	imul bx
	mov bx, ax
	mov ax, x
	mov cx, 4
	imul cx
	mov cx, ax
	mov ax, bx
	idiv cx
m4:
	pop bx
	add ax, bx
	pop cx
	xor dx, dx
	idiv cx
	call Check
	push ax ; 1 part
m5:
	mov ax, a
	imul ax
	mov bx, a
	imul bx
	mov cx, ax
	mov ax, b
	imul ax
	imul ax
	mov bx, b
	imul bx
	imul cx
	mov bx, 4
	imul bx
	add ax, bx ; 4*a^3*b^5+4
	push ax 
	jmp m6
ze1:
	jmp err1
m6:
	mov ax, b
	imul ax
	imul ax
	mov bx, 3
	imul bx
	sub ax, bx
	jz ze1
	mov bx, 0
	cmp ax, bx
	jg m7
	mov bx, -1
	imul bx

m7:
	mov bx, ax
	pop ax
	idiv bx
	mov bx, ax
	pop ax
	imul bx
	
	ret
calculation endp

start:
		mov ax,D
		mov ds,ax
		xor ax, ax
		print STR1
		call integerin
		mov a,ax
		call integerout
		print STR2
		call integerin
		mov b, ax
		call integerout
		print STR3
		call integerin
		mov x, ax
		call integerout
		mov ax, x
		or ax, ax
		jz err1
		xor ax, ax

		call calculation
		; результат
		print MSG6
		call integerout
		jnz ex	

err1:
		mov ah,09
		print CRLF
		print errmsg3

ex:
		mov ah, 4ch
		int 21h
		
C		ends	;закончили описание сегмента кодов команд

		end	start	;закончили программу с указанием точки входа в нее