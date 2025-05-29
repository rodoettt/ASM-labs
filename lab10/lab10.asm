.386P
.model flat, stdcall
option casemap : none

include	c:\masm32\include\user32.inc
include	c:\masm32\include\kernel32.inc
include	c:\masm32\include\gdi32.inc
include	c:\masm32\include\Shell32.inc
includelib c:\masm32\lib\user32.lib
includelib c:\masm32\lib\kernel32.lib
includelib c:\masm32\lib\gdi32.lib
includelib	c:\masm32\lib\Shell32.lib

IDM_SETRANGE	  equ 9
IDM_QUIT	  equ 11

IDC_min_X	  equ 400
IDC_max_X	  equ 401

BTN_BUILD	  equ 100h
IDD_DIALOG	  equ 300
MYMENU		  equ 999

GENERIC_WRITE	  equ 040000000h
FILE_SHARE_WRITE  equ 2
CREATE_ALWAYS     equ 2
STYLE             equ CS_HREDRAW+CS_VREDRAW+CS_GLOBALCLASS
BS_DEFPUSHBUTTON  equ 1h
BS_AUTOCHECKBOX   equ 00000003h	
STYLBTN           equ WS_CHILD+BS_DEFPUSHBUTTON+WS_VISIBLE
STYLCHKB          equ WS_CHILD+WS_VISIBLE+BS_AUTOCHECKBOX
BM_GETCHECK       equ 00F0h
;Компоненты цветов.
RED                 equ 50
GREEN               equ 50
BLUE                equ 255
RGBW                equ (RED or (GREEN shl 8)) or (BLUE shl 16)
RGBT                equ 255 ;Красный.
;-----------------------
MSGSTRUCT  STRUC	
           MSHWND     DD ? ;Идентификатор окна, получающего сообщение.
           MSMESSAGE  DD ? ;Идентификатор сообщения.
           MSWPARAM   DD ? ;Доп. информация о сообщении.
           MSLPARAM   DD ? ;Доп. информация о сообщении.
           MSTIME     DD ? ;Время посылки сообщения.
           MSPT       DD ? ;Положение курсора во время посылки сообщения.
MSGSTRUCT ENDS	
;-----------------------
WNDCLASS  STRUC	
           CLSSTYLE     DD ? ;Стиль окна.
           CLWNDPROC    DD ? ;Указатель на процедуру окна.
           CLSCBCLSEX   DD ? ;Информация о доп. байтах для данной структуры.
           CLSCBWNDEX   DD ? ;Информация о доп. байтах для окна.
           CLSHINST     DD ? ;Дескриптор приложения.
           CLSHICON     DD ? ;Идентификатор иконки окна.
           CLSHCURSOR   DD ? ;Идентификатор курсора окна.
           CLBKGROUND   DD ? ;Идентификатор кисти окна.
           CLMENNAME    DD ? ;Имя-идентификатор меню.
           CLNAME       DD ? ;Специфицирует имя класса окон.
WNDCLASS  ENDS 
;-----------------------
PAINTSTR  STRUC
    hdc     DWORD 0 
    fErase  DWORD 0
    left    DWORD 0
    top     DWORD 0
    right   DWORD 0
    bottom  DWORD 0
    fRes    DWORD 0
    fIncUp  DWORD 0
    Reserv DB 32 dup(0)
PAINTSTR  ENDS
;-----------------------
RECT STRUC 
        L   DWORD ?  ;X - левого верхнего угла.
        T   DWORD ?  ;Y - левого верхнего угла.
        R   DWORD ?  ;Х - правого нижнего угла.
        B   DWORD ?  ;Y - правого нижнего угла.
RECT ENDS
;-----------------------
START_COORD	struct
	X	DWORD ?
	Y	DWORD ?
START_COORD	ends
;----------------------------------

IDI_APPLICATION     equ 32512
IDC_ARROW           equ 32512
WS_OVERLAPPED	    equ 000000000h
WS_CAPTION	    equ 000C00000h
WS_SYSMENU	    equ 000080000h
WS_THICKFRAME	    equ 000040000h
WS_MINIMIZEBOX	    equ 000020000h
WS_MAXIMIZEBOX	    equ 000010000h
WS_OVERLAPPEDWINDOW equ WS_OVERLAPPED OR WS_CAPTION OR WS_SYSMENU OR WS_THICKFRAME OR WS_MINIMIZEBOX OR WS_MAXIMIZEBOX
SW_SHOWNORMAL	    equ 1
MB_ICONERROR	    equ	00000010h
WS_CHILD	    equ 040000000h
CS_HREDRAW          equ 0002h
CS_VREDRAW          equ 0001h
CS_GLOBALCLASS      equ 4000h 
WM_INITDIALOG       equ 0110h
WM_COMMAND          equ 0111h
WM_DESTROY          equ 0002h
WM_CREATE           equ 0001h
WM_GETMINMAXINFO    equ 0024h
WM_PAINT            equ 000Fh
WS_VISIBLE          equ 010000000h
IDOK                equ 1
IDCANCEL            equ 2

.data
;строки
	RangeStr   db	'Границы по x : от',0
	RangeStr1  db	'до ',0
	lRangeStr  db	'-4',0
	rRangeStr  db	'4',0
	Ystr	   db	'y',0
	Xstr	   db	'x',0
	RLessLERR  db	'Правая граница не должна быть меньше либо равна левой!',0
	rRangeErr  db	'Правая граница не должна выходить за пределы окна!',0
	lRangeErr  db	'Левая граница не должна выходить за пределы окна!',0
	
;для вычислений сопроцессора
	lRange	   dd 	-4
	rRange     dd 	4
	maxX       dd 	?
	minX       dd	?
	FlagErr    dd	0
        status     dd   0
	
	y          dd	0.0
	x          dd	0.0
	a			dd	0.0234
	buf1       dd	0.0
	buf2	   dd	0.0
	bufe	   dd	0.0
	buf3	   dd	0.0
	epart	   dd	0.0
	numpart	   dd	0
	flag	   db	0
	
	scalex	   dd	0.0
	scaley	   dd	0.0
	coeff      dd	0.02
	step       dd	0.01
	xCor       dd	0 ;целая координата x
	yCor       dd	0 ;целая координата y
	flg        dd	0
	
	ncycl	   dd	?
	one	   db	'1',0
	vert	   db	'|',0
	horiz      db	'--',0
;структуры	
	NEWHWND     DD 0
	MSG         MSGSTRUCT <?>
	WC          WNDCLASS <?>
	PNT         PAINTSTR <?>
	start_coord START_COORD <?>
     
;данные для приложения и окна
	HINST       DD 0 ;Здесь хранится дескриптор приложения.
	TITLENAME   DB 'График кусочно-заданной функции',0
	CLASSNAME   DB 'CLASS32',0
	hDC	    DWORD 0 ;контекст устройства
;данные для рисования    
	Pen	    DWORD 0
	PenGreen    DWORD 0
	if_draw     db 0
     
;надписи на элементах окна
	CPBUT_BUILD DB 'Построить',0
	CPBUT_CLEAR DB 'Очистить',0
	CLSBUTN     DB 'BUTTON',0  
     
;идентификаторы кнопок
	hBtnBuild   DWORD 0
	hBtnClear   DWORD 0
;строки в сообщениях
	CAP         DB 'Сообщение',0
	CAP_ERR     db 'Ошибка!',0
;координаты.
	XT	    dd 0
	YT	    dd 0
	_width	    DWORD ?
	_height	    DWORD ?
	RCT	    RECT <?>


.code
START: 
	;Получить дескриптор приложения.
	invoke 	GetModuleHandleA, 0
	mov   	[HINST], eax
	;заполняем структуру класса окна
	mov 	[WC.CLSSTYLE],STYLE
	mov   	[WC.CLWNDPROC], offset WNDPROC
	mov   	[WC.CLSCBCLSEX], 0
	mov   	[WC.CLSCBWNDEX], 0
	mov   	eax, [HINST]
	mov   	[WC.CLSHINST], eax
	;пиктограмма окна
	invoke 	LoadIconA, 0, IDI_APPLICATION
	mov    	[WC.CLSHICON], eax
	;курсор окна
	invoke 	LoadCursorA, 0, IDC_ARROW
	mov	[WC.CLSHCURSOR], eax
	mov    	[WC.CLBKGROUND], 5h ;Цвет окна
	mov    	DWORD ptr [WC.CLMENNAME], MYMENU
	mov	DWORD ptr [WC.CLNAME], offset  CLASSNAME
	invoke	RegisterClassA, offset WC 
	;Создать окно зарегистрированного класса.
	invoke	CreateWindowExA, 0, offset CLASSNAME, offset TITLENAME, WS_OVERLAPPEDWINDOW, 100, 100, 800, 500, 0, 0, [HINST], 0
	;Проверка на ошибку.
	cmp    	eax,0
	JZ	_ERR
	mov   	[NEWHWND], eax ;Дескриптор окна.  
	invoke	ShowWindow,  [NEWHWND], SW_SHOWNORMAL ;Показать созданное окно
	invoke	UpdateWindow, [NEWHWND]  ;Команда перерисовать видимую
					 ;часть окна, асинхронное сообщение WM_PAINT.
;Цикл обработки сообщений 
MSG_LOOP:
	invoke 	GetMessageA, offset MSG, 0, 0, 0
	cmp  	eax, 0
	je   	END_LOOP
	invoke 	TranslateMessage, offset MSG
	invoke 	DispatchMessageA, offset MSG
	jmp  	MSG_LOOP 
END_LOOP: 
    invoke	ExitProcess, [MSG.MSWPARAM]
_ERR:
	jmp	END_LOOP

DlgProc	proc	uses ebx edi esi hdlg:DWORD, mes:DWORD, wparam:DWORD, lparam:DWORD
	
	mov	eax, mes
	
	cmp	ax, WM_INITDIALOG
	je	wminitdialog
	
	cmp	ax,WM_COMMAND
	jne	exit_false
		
	mov	ebx, wparam ;идентификатор элемента управления
	
	cmp	bx, IDOK	
	je	idok
	
	cmp	bx, IDCANCEL
	je	wmidcancel

	jmp	exit_false

wminitdialog:
	invoke	SetDlgItemInt, hdlg, IDC_min_X, lRange, 1;0
	invoke	SetDlgItemInt, hdlg, IDC_max_X, rRange, 1;0
	jmp	exit_true

idok:
	;получить параментры из диалога
	invoke	GetDlgItemInt, hdlg, IDC_min_X, 0, 1
	mov	lRange, eax
	invoke	GetDlgItemText, hdlg, IDC_min_X, offset lRangeStr, 4
	
	invoke	GetDlgItemInt, hdlg, IDC_max_X, 0, 1
	mov	rRange, eax
	invoke	GetDlgItemText, hdlg, IDC_max_X, offset rRangeStr, 4
	
	;проверка введенных значений
k1:	mov	eax, maxX
	cmp	eax, rRange
	jg	k2
	mov	FlagErr, 1
	invoke	MessageBoxA, hdlg, offset rRangeErr, offset CAP_ERR, MB_ICONERROR
	jmp	k4
k2:	mov	eax, minX
	cmp	lRange, eax
	jnl	k3
	mov	FlagErr, 1
	invoke	MessageBoxA, hdlg, offset lRangeErr, offset CAP_ERR, MB_ICONERROR
	jmp	k4
k3:	mov	eax, lRange
	cmp	rRange, eax
	jg	ok_range
	mov	FlagErr, 1
	invoke	MessageBoxA, hdlg, offset RLessLERR, offset CAP, MB_ICONERROR
	
k4:	;параметры по умолчанию
	mov	lRange, -2
	mov 	[lRangeStr], '-'
	mov	[lRangeStr+1], '2'
        mov	[lRangeStr+1], 0
	
	mov	rRange, 2
	mov 	[rRangeStr], '2'
	mov	[rRangeStr+1], 0
	
ok_range:	
	invoke	EndDialog, hdlg, 0
	jmp	exit_true
	
wmidcancel:
	mov	FlagErr, 0
	invoke	EndDialog, hdlg, 0
	jmp	exit_true

exit_false:
	mov	eax,0
	ret

exit_true:
	mov	eax,1
	ret

DlgProc	endp


WNDPROC PROC	uses ebx edi esi hWnd:DWORD,Msg:DWORD,wParam:DWORD, lParam:DWORD
        mov	eax, Msg
        cmp	eax, WM_DESTROY
        je	WMDESTROY
        cmp	eax, WM_CREATE
        je	WMCREATE
        cmp	eax, WM_GETMINMAXINFO
        je	WMGETMINMAXINFO
        cmp	eax, WM_PAINT
        je	WMPAINT
        cmp	eax,WM_COMMAND
        je	WMCOMMAND
        jmp	DEFWNDPROC
        
WMGETMINMAXINFO:
	mov 	ebx, lParam
	mov 	eax, 600
	mov 	[ebx + 24 + 0], eax
	mov 	eax, 400
	mov 	[ebx + 24 + 4], eax

	jmp	FINISH

WMPAINT:
	mov	flg, 0
	
	invoke	GetWindowRect, hWnd, offset RCT

	invoke 	BeginPaint, hWnd, offset PNT
	mov 	hDC, eax ;сохранить контекст (дескриптор)
	invoke	SetBkMode, hDC, 0
;вывести текст
	invoke 	CreatePen, 1, 4, 2
	mov 	Pen, eax
	
	cmp	if_draw, 1
	jnz	nBuild
	
	push 	hDC
	push 	hWnd
	call 	DrawGraph
	
;выводим систему координат
nBuild:	invoke 	SelectObject, hDC, Pen
	
	mov 	eax, RCT.R
	sub 	eax, RCT.L
	mov 	_width, eax;ширина окна по x
	
	mov 	eax, RCT.B
	sub 	eax, RCT.T
	mov 	_height, eax;высота окна по y
	sub 	eax, 110
	shr 	eax, 1
	mov 	YT, eax
	mov 	start_coord.Y, eax
	
	;вывод границ
	push	offset RangeStr
	call	LENSTR
	mov 	eax,_height
	sub	eax, 100
	push	eax
	invoke	TextOutA, hDC, 20, eax, offset RangeStr, ebx
	push	offset lRangeStr
	call	LENSTR
	pop	eax
	push	eax
	invoke	TextOutA, hDC, 150, eax, offset lRangeStr,ebx
	pop	eax
	push	eax
	invoke	TextOutA, hDC, 170, eax, offset RangeStr1,3
	push	offset rRangeStr
	call	LENSTR
	pop	eax
	invoke	TextOutA, hDC, 200, eax, offset rRangeStr,ebx
	
	;ось абсцисс
	invoke	MoveToEx, hDC, 0, YT, 0
	
	mov	eax, _width
	mov	XT, eax
	invoke 	LineTo, hDC, XT, YT

	mov	eax, YT
	add	eax, 6
	mov	ebx, _width
	sub	ebx, 26
	invoke 	TextOutA, hDC, ebx, eax, offset Xstr, 1
	
	;ось ординат
	mov 	eax, _width
	sub	eax, 16
	shr 	eax, 1
	mov	XT, eax
	mov	start_coord.X, eax
	
	invoke 	MoveToEx, hDC, XT, 0, 0
	
	mov	eax, XT
	add	eax, 6
	invoke 	TextOutA, hDC, eax, 0, offset Ystr, 1
	
	mov 	eax, _height
	sub 	eax, 160
	invoke 	LineTo, hDC, XT, eax

	;scale
	fild	_width
	fmul	coeff
	fstp	scalex
	
	fild	_height
	fmul	coeff
	fstp	scaley
	;масштабная единица по X
	fild	start_coord.X
	fadd	scalex
	fistp	XT
	mov	eax, start_coord.Y
	add	eax, 16
	invoke 	TextOutA, hDC, XT, eax, offset one,1
	
	mov	eax, start_coord.Y
	sub	eax, 9
	mov	YT, eax
	
	mov	maxX, 0
xstep1:	invoke 	TextOutA, hDC, XT, YT, offset vert,1
	fild	XT
	fadd	scalex
	fistp	XT
	
	inc	maxX

	mov	eax, _width
	cmp	eax, XT
	jg	xstep1

	mov 	eax, _width
	sub	eax, 16
	shr 	eax, 1
	mov	XT, eax
	fild	XT
	fsub	scalex
	fistp	XT
	mov	minX, 0

xstep2:	invoke 	TextOutA, hDC, XT, YT, offset vert,1
	fild	XT
	fsub	scalex
	fistp	XT

	dec	minX

	cmp	XT, 0
	jg	xstep2
	
	;масштабная единица по Y
	fild	start_coord.Y
	fsub	scaley
	fistp	YT
	sub	YT, 8

	mov	eax, start_coord.X
	sub	eax, 4
	mov	XT, eax

ystep1:	invoke 	TextOutA, hDC, XT, YT, offset horiz,2
	fild	YT
	fsub	scaley
	fistp	YT

	cmp	YT, 0
	jg	ystep1
	
	fild	start_coord.Y
	fadd	scaley
	fistp	YT
	sub	YT, 8
	
ystep2:	invoke 	TextOutA, hDC, XT, YT, offset horiz,2
	fild	YT
	fadd	scaley
	fistp	YT

	mov	eax, _height
	sub	eax, 160
	cmp	YT, eax
	jl	ystep2

	mov	eax, _width
	sub	eax, 240
	mov 	XT, eax
        
	mov	ebx, _height
	sub 	ebx, 100
	mov 	YT, ebx
	
	
	invoke 	MoveWindow, hBtnBuild, XT, YT, 100, 30, 0
	mov 	eax, XT
	add 	eax, 110
	mov 	XT, eax
	invoke 	MoveWindow, hBtnClear, XT, YT, 100, 30, 0

endPaint:	invoke 	EndPaint, hWnd, offset PNT
        
        
	mov 	eax, 0
	jmp 	FINISH
	
WMCOMMAND:
	mov  eax,lParam
	cmp  eax, hBtnBuild
	je   WMBUILD
        
	cmp  eax, hBtnClear
	je   WMCLEAR
        
	mov  eax,wParam
	cmp eax, IDM_SETRANGE	
	je WM_SETRANGE
	
	cmp eax, IDM_QUIT	
	je WMQUITE
	
	mov  eax,0
	jmp  FINISH
WM_SETRANGE:
dialog:	mov	FlagErr, 0
	invoke	DialogBoxParam, [HINST], IDD_DIALOG, hWnd,offset DlgProc,0 
	cmp	FlagErr, 1
	jz	dialog
	
	mov	if_draw, 1
	invoke	InvalidateRect,  hWnd, 0, 1
	mov	FlagErr, 0
	jmp	FINISH
	
WMQUITE:
	jmp	WMDESTROY

WMBUILD:	
	invoke	InvalidateRect,  hWnd, 0, 1
	mov	x, 0
	mov	y, 0
	mov	xCor, 0
	mov	yCor, 0
	mov	flg, 0
	
	mov	if_draw, 1
		
	invoke	GetDC, hWnd
	mov	hDC, eax
	
	;рисуем график
	push	eax	
	push	hWnd
	call	DrawGraph
	
	invoke	ReleaseDC, hWnd, hDC
	jmp	FINISH
WMCLEAR:	
	mov 	if_draw, 0
	invoke 	InvalidateRect,  hWnd, 0, 1
	mov	x, 0
	mov	y, 0
	mov	xCor, 0
	mov	yCor, 0
	mov	flg, 0
	 
	jmp	FINISH
	
;Создаем элементы в окне
WMCREATE:	
	invoke	CreateWindowExA, 0, offset CLSBUTN, offset CPBUT_BUILD, STYLBTN, XT, YT, 100, 30, hWnd, 0, [HINST], 0
	mov	hBtnBuild,eax

	invoke	CreateWindowExA, 0, offset CLSBUTN, offset CPBUT_CLEAR, STYLBTN, XT, YT, 100, 30, hWnd, 0, [HINST], 0
	mov	hBtnClear,eax
        
	jmp	FINISH
DEFWNDPROC:	
	invoke	DefWindowProcA, hWnd, Msg, wParam, lParam
	jmp  FINISH
WMDESTROY:	
	invoke PostQuitMessage, 0 ;Сообщение WM_QUIT
	mov  eax, 0
FINISH:	
	RET
WNDPROC 	endp


DrawGraph	proc _hWnd:DWORD, _hDC:DWORD
    invoke	CreatePen, 0, 4, 00ff00h
    mov	PenGreen, eax
    invoke 	SelectObject, _hDC, PenGreen
    
    mov	eax, rRange
    cmp	lRange, eax
    jz	finGr
    
    ; Инициализация x
    fild	lRange
    fstp	x
    
    ; Начальная координата X
    fld	x
    fmul	scalex
    fist	xCor
    
    ; Количество итераций (шаг 0.01)
    mov	eax, rRange
    sub	eax, lRange
    mov	ebx, 100
    mul	ebx
    mov	ncycl, eax

cycl:
    finit
    fld x
    
    ; Вычисление |x|^a
    fld x           ; st(0) = x
    fabs            ; st(0) = |x|
    
    ; Вычисление |x|^a через e^(a*ln|x|)
    fldln2          ; st(0) = ln(2)
    fxch            ; st(0) = |x|, st(1) = ln(2)
    fyl2x           ; st(0) = ln(|x|)
    fld a           ; st(0) = a, st(1) = ln(|x|)
    fmul            ; st(0) = a*ln(|x|)
    fldl2e          ; st(0) = log2(e)
    fmul            ; st(0) = a*ln(|x|)*log2(e)
    fld st(0)       ; Копия
    frndint         ; Целая часть
    fsub st(1), st(0)
    fxch st(1)
    f2xm1
    fld1
    fadd
    fscale          ; st(0) = |x|^a
    fstp st(1)      ; Очистка стека
    
    ; e^(a*x)
    fld x           ; st(0) = x
    fld a           ; st(0) = a, st(1) = x
    fmul            ; st(0) = a*x
    fldl2e          ; st(0) = log2(e)
    fmul            ; st(0) = a*x*log2(e)
    fld st(0)       ; Копия
    frndint         ; Целая часть
    fsub st(1), st(0)
    fxch st(1)
    f2xm1
    fld1
    fadd
    fscale          ; st(0) = e^(a*x)
    fstp st(1)      ; Очистка стека
    
    fmul            ; st(0) = |x|^a * e^(a*x)
    
    ; Знаменатель: sin(x)*cos(x)
    fld x           ; st(0) = x
    fsin            ; st(0) = sin(x)
    fld x           ; st(0) = x
    fcos            ; st(0) = cos(x)
    fmul            ; st(0) = sin(x)*cos(x)
    
    ; Проверка деления на ноль
    ftst
    fstsw ax
    sahf
    jz skip_point   ; Пропустить, если знаменатель = 0
    
    fdiv            ; st(0) = (|x|^a * e^(ax)) / (sin(x)*cos(x))
    fstp y          ; Сохранить y
    
    jmp calc_done

skip_point:
    finit           ; Очистить стек FPU
    mov flg, 0      ; Сбросить флаг рисования
    jmp next_point

calc_done:
    ; Преобразование y в координаты
    fld y
    fmul scaley
    fistp yCor
    
    mov eax, start_coord.X
    add eax, xCor
    mov XT, eax
    mov ebx, start_coord.Y
    sub ebx, yCor
    mov YT, ebx
    
    cmp flg, 0
    jnz line
    invoke MoveToEx, _hDC, XT, YT, 0
    inc flg

line:
    invoke LineTo, _hDC, XT, YT

next_point:
    ; Увеличиваем x
    fld x
    fadd step
    fst x
    fmul scalex
    fistp xCor
    
    dec ncycl
    jnz cycl          

finGr:	
    ret
DrawGraph	endp
LENSTR  PROC
        PUSH	EBP
        mov	EBP,ESP
        PUSH	esi
        mov	esi, DWORD ptr [ebp+08h]
        XOR	ebx,ebx
LBL1:
        cmp	BYTE ptr [esi],0 
        JZ	LBL2 
        INC	ebx 
        INC	esi 
        jmp	LBL1
LBL2:
        POP	esi
        POP	EBP
        RET	4
LENSTR  ENDP
	
	END 	START