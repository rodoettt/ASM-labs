title	Prim
assume cs:C, ds:D, ss:S

S	segment stack
	dw 128 dup (?)
S	ends

D	segment
	cr = 0dh
	lf = 0ah

x	dw	?
y	dw	?
z	dw	?
temp1	dw 	?
temp2	dw	?
temp3	dw	?
temp4	dw	?

STR1	db	'Enter x:', 0ah, '$'
STR2	db	0ah,'Enter y:', 0ah, '$'
STR3	db	0ah,'Enter z:', 0ah, '$'



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
om1:21ю
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
	mov ax, X 
	imul ax
	call Check
	imul ax
	call Check
	mov bx, X 
	imul bx
	call Check
	mov bx, 2
	imul bx
		
m2:
	mov cx, ax
	mov ax, Y
	imul ax
	call Check
	mov bx, Y 
	imul bx
	call Check
	mov bx, 10
	imul bx
; проблема в делении
	call Check
	xor dx, dx
	idiv cx
	push ax
	or ax, ax
	jnz m3
	mov ah, 4ch
	int 21h

m3:
	mov ax, Y
	imul ax
	call Check
	mov bx, Y 
	imul bx
	mov bx, X 
	imul bx
	call Check
	imul bx
	call Check
	mov bx, 3
	imul bx
	push ax
	call Check
	mov dx, ax
	mov ax, Z 
	mov bx, 6
	imul bx
	call Check
	mov cx, 0
	cmp ax, cx
	jge m4
	neg ax

m4:
	pop dx
	sub dx, ax
	mov ax, dx
	mov bx, 0
	cmp ax, bx
	jge m5
	mov bx, -1
	imul bx
	pop cx
	idiv cx
	imul bx
	jmp m6
m5:
	xor dx, dx
	pop cx
	idiv cx
	
m6:
	call Check
	push ax
	mov ax, X 
	imul ax
	call Check
	imul ax
	mov cx, X 
	imul cx
	call Check
	mov cx, 3
	imul cx
	xor bx, bx
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
		mov x,ax
		call integerout
		print STR2
		call integerin
		mov y, ax
		call integerout
		print STR3
		call integerin
		mov z, ax
		call integerout
		mov ax, x
		or ax, ax
		jz err1
		mov ax, y
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

		end	start	;закончили программу с указанием точки в    ухода в нее