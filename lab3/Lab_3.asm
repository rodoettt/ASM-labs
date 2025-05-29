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
	mov ds, ax
m2:	print msgin
	mov ah, 0ah
	lea dx, file
	int 21h
	lea di, file + 2
	mov al, -1[di]
	xor ah, ah
	add di, ax
	mov [di], ah
	mov ah, 3dh
	lea dx, file + 2
	mov al, 2
	int 21h
	jnc m1
	print err_o
	jmp m2

m1:	mov inhan, ax

m3:	print msgout
	mov ah, 0ah
	lea dx, file
	int 21h
	lea di, file+2
	mov al, -1[di]
	xor ah, ah
	add di, ax
	mov [di], ah
	mov ah, 3ch
	lea dx, file + 2
	xor cx, cx
	int 21h
	jnc m4
	print err_c
	jmp m3
m4:	print crlf
	mov outhan, ax

m7:	mov bx, inhan
	mov ah, 3fh
	lea dx, buf
	mov cx, 256
	int 21h
	jnc m5
	
	print err_r
m6:	mov ah, 3eh
	mov bx, inhan
	int 21h

	mov ah, 4ch
	int 21h

m5:	cmp ax, 0
	jz m6

	push cx
	push si
	xor si, si
	mov cx, ax
co1:	cmp buf[si], 192
	jae co2
	jmp co3
co2:	cmp buf[si], 223
	jbe co5
	jmp co3
co5:	sub buf[si], 127
co3:	add si, 1
	loop co1
co4:	pop si
	pop cx
	mov ah, 40h
	mov bx, outhan
	lea dx, buf
	int 21h
	jnc m7
	print err_w
	jmp m6


c	ends
	end start
	