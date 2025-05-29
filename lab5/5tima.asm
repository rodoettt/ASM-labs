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
        mov ds,ax ; ������������� ds �� ������� ������
open:       
		PRINT msg1 ;������� ���������
            
        mov ah,0ah ; ������ ��� �����
        lea dx,fname ; ���� ����� ����� � dx
        int 21h ; 
            
        lea di,fname+2; �������� � di �����, ������� ��������� �� 2 ����� ���� ������ file (����� �����)
        mov al,-1[di]; ����� �����
        xor ah,ah
        add di,ax; ��������� di � ax, ��������� ��������� � ����� ����� �����, �.�. � di ����� ���� ����� �������� ������� ����������
        mov [di],ah; ���������� 0 � ����� ������
            
        mov ah,3dh ; ��������� ���� ��� ������
        lea dx,fname+2
        xor al,al 
        int 21h
            
        jnc inh ; ��������� ���� ��������, ������������� � ���. ����������� ����������, ���� ���� ������, �� ��������� �� ����� inh
        PRINT er1; ������ ��������
        jmp open
            
inh:        
		mov inhan,ax; ��������� ���������� ����� � ���������� inhan
create:     
		PRINT msg2
            
        mov ah,0ah ; ������ ��� �����, ������� ����� �������
        lea dx,fname
        int 21h
            
        lea di,fname+2
        mov al,-1[di]
        xor ah,ah
        add di,ax
        mov [di],ah
            
        mov ah,3ch ;��������
        lea dx,fname+2
        xor cx,cx
        int 21h
            
        jnc outh
        PRINT er2; ������ ��������
		jmp create
outh:       
		mov outhan,ax ; ��������� ���������� ��������� ����� � ���������� outhan

spe:	    
		PRINT speed
		call IntegerIn ;������ ��������(����) ����� ����������� �������� 
		cmp ax, 0
		JZ 	spe ; ���� ����� 0, �� ������ ��������

		mov N, ax
		mov cs:x, ax ; �������� ���� �������� � �

		mov ax, 351ch; ����� ������ ����������
		int 21h
		mov word ptr cs:o1c, bx
		mov word ptr cs:o1c + 2, es; ��������� ����� ������� ����������� ����������

		mov ax, 251ch; ��������� ������ ������� ����������
		lea dx, time; ����� ������ �����������
		push ds
		push cs
		pop ds ; �������������� ds �� cs
		int 21h
		pop ds ;���������� ds
		PRINT entor


read:       
		mov bx,inhan  ;������
        mov ah,3fh
        lea dx,buf; ����� ������ ��� ������ ������
        mov cx,256; ����� ����������� ����
        int 21h
        jnc change
        PRINT er3; ������ ������

change:         
        cmp ax, 0; ������� 0 ����
		jz  exit    ;������� �� ��������� ���� ������ ����������
		mov lenbuf, ax; ����� ��������� ����
						;���� ������ ��������		
		mov cx, lenbuf
		push di
		xor  di,di
a1:	    
		cmp cs:x, 0 ;�������� 
		jg 	a1
		mov ah, 02h ;����� ��������� �� �����
		mov dl, '.'  
		int 21h

		mov ax, N
		add cs:x, ax ;���������� � ����� ����� ��� N ��� ���������� �����
  
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
		mov ah,40h ; ��� ������� ��� ������ � ����
        mov bx,outhan
        mov cx, lenbuf; ����� ������������ ����/ ����� ������
        lea dx,buf; ���������� ����� ������ � �������
        int 21h
        jnc bbb 
        PRINT er4
bbb:
		jmp read           

exit: 	
		push ds
		mov  dx, word ptr cs:o1c; ������ ������ ����������
		mov  ax, word ptr cs:o1c + 2
		mov  ds, ax

		mov 	ax, 251ch; ����������� ������� ����������� �� �����
		int 	21h
		pop 	ds 
          
        mov ah,3eh ; ��� ������� ��� �������� �������� �����
        mov bx,inhan ; ��������� ���������� � bx
        int 21h
        mov ah,3eh  ; ��� ������� ��� �������� ��������� �����
        mov bx,outhan ; ��������� ���������� � bx
        int 21h
        mov ah,4ch ; ��� ������� ��� �������� �����
        int 21h
                    
; ����� ���������� ����������
time:	   
		pushf
		call dword ptr cs:o1c; ����� ������� �����������
		sti; ��������� I ����� - ������� ���������� ���������
		dec cs:x
		iret
c ends
end start
