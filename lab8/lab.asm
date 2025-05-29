.586
.model flat, stdcall
option casemap:none

include C:\masm32\include\windows.inc
include C:\masm32\include\kernel32.inc
include C:\masm32\include\winmm.inc
include C:\masm32\include\user32.inc
include C:\masm32\include\masm32.inc
include C:\masm32\include\msvcrt.inc
includelib C:\masm32\lib\kernel32.lib
includelib C:\masm32\lib\winmm.lib
includelib C:\masm32\lib\user32.lib
includelib C:\masm32\lib\masm32.lib
includelib C:\masm32\lib\msvcrt.lib


cr = 0dh
lf = 0ah

.data
    inhan   dd  ?
    outhan  dd  ?
    readsize dd ?
	sizeio dd ?
	InHandle dd ?
	OutHandle dd ?
	tiki dd ?
	X dd ?
	size_of_file dd ?
	smem dd ?
	memPoint dd ?
	roll dd ?
	zvezd db '*', 0
	sizeread dd ?
    CRLF	db	cr,lf, 0
    CRLT    db  '    ', 0 
    byffer db 255 dup (?)
    rezul  db 255 dup (?)
    fname db 255, 0, 255 dup (?)
    msopen db 'File to read: ', 0
    msmake db 'File to write: ', 0
    erropen db 'Cant open file!', 0
	errmemmsg db 'No memory',cr, lf, 0
    errreed db 'Cant read from file!',cr, lf, 0
    errmake db 'Cant create file!',cr, lf, 0
    errwr db 'Cant write to file',cr, lf, 0
    succes db cr, lf, 'Succes!',  0
.code

find_size_str proc adr:dword
	xor eax, eax
	mov esi, adr
Fstr:
	cmp byte ptr [esi], 0
	je Final_str
	inc esi
	inc eax
	jmp Fstr
Final_str:
	ret 4
find_size_str endp

print macro str
	invoke CharToOem, offset str, offset str
	invoke find_size_str,  offset str
    invoke WriteConsole, OutHandle, offset str, eax, offset sizeio, 0
	endm 

cinstr macro str 
    invoke ReadConsole, InHandle, offset str, 255, offset sizeio, 0
    endm

task_proc proc    ; процедура обработки данных
	mov esi, memPoint
	mov ebx, smem
task_start:
	cmp X, 0
    jg 	task_start
	add X, 1
    mov al, byte ptr [esi]
    for1:       
	    cmp 	al, 192
		jae		co2 
		jmp 	co3 
    co2: 	
        cmp 	al, 223
		jbe		co5
		jmp 	co3
    co5:	
        sub 	al, 95 
    co3: 		 
        mov byte ptr [esi], al
        cmp ebx, 0
        je task_end
        add esi, 1 
        dec ebx
        push esi
        print zvezd
        pop esi
        jmp task_start
task_end:
    ret
task_proc endp

exit proc 
	invoke CloseHandle, inhan
	invoke CloseHandle, outhan
    invoke ExitProcess, 0
exit endp 

err_open_file proc ; ошибка открытия файла
    print erropen
    print CRLF
    ret
err_open_file endp

err_read_file proc ; ошибка чтения файла
    print errreed
    call exit
    ret
err_read_file endp

err_write_file proc ; ошибка записи файла
    print errwr
	invoke timeKillEvent, tiki
	invoke LocalFree, memPoint
	invoke CloseHandle, inhan
	invoke CloseHandle, outhan
	call FreeConsole
	call exit
    ret
err_write_file endp

err_make_file proc ; ошибка создания файла
    print errmake
    call exit
    ret 
err_make_file endp

err_no_mem proc ; ошибка выделения памяти
    print errmemmsg
    call exit
    ret 
err_no_mem endp

openfile_write proc
openst:
    print msopen							; Выводит строку "File to read: "
    cinstr fname							; Считывает строку из консоли в буфер fname
	lea edi, fname							; Загружаем адрес fname в edi
	ADD EDI, sizeio							; Перемещаем edi на конец введенной строки
	MOV BYTE PTR [EDI-2], 0    
    invoke CreateFile, offset fname, GENERIC_READ, 0, 0, OPEN_EXISTING, 0, 0 ; Пытаемся открыть файл на чтение
	CMP EAX, -1
    je opfer
    mov inhan, eax 							; Сохраняем хендл открытого файла
    ret
opfer:
    call err_open_file
    jmp openst
openfile_write endp

timer proc ; таймер
    dec X									; уменьшаем значение переменной X
    ret 20									; возвращение из таймера
timer endp

task proc
write_start:
	invoke GetFileSize, inhan, 0 			; получаем размер файла
	mov size_of_file, eax					; сохраняем в eax
	cmp size_of_file, 0
	jne operexit 
	call exit								; завершаем, если файл пустой
operexit:
	invoke LocalAlloc, LMEM_FIXED, size_of_file ; выделяем память под содержимое файла
	cmp eax, NULL
    je ermem
	mov ebx, size_of_file
	mov smem, ebx							; сколько байт будет обработано
	jmp change_chars
ermem:
	invoke LocalAlloc, LMEM_FIXED, 255
	cmp eax, NULL
    je errmem
	mov smem, 255
change_chars:
	mov memPoint, eax 						; сохраняем указатель на выделенную память	
	invoke ReadFile, inhan, memPoint, smem, sizeread, 0 ; считываем файл в память
	cmp eax, 0
	je errz
	invoke timeSetEvent, 100, 0, offset timer, 0, TIME_PERIODIC ; запуск таймера
	mov tiki, eax
    call task_proc 							; вызов процедуры для обработки данных
    call writefile							; запись обработанных файлов в выходной файл
	mov eax, roll							; количество записанных байт
	cmp size_of_file, eax
	je write_exit
    jmp write_start							; если не все, то читаем следующий кусок	
write_exit:
	invoke timeKillEvent, tiki				; останавливаем таймер
    ret
errmem:
    call err_no_mem
    ret 
errz:
	call err_read_file
	ret
task endp 

makefile proc 
    print msmake 							; вывод "File to write"
    cinstr fname							; считывание имени файла
    lea edi, fname
	ADD EDI, sizeio
	MOV BYTE PTR [EDI-2], 0    
    invoke CreateFile, offset fname, GENERIC_WRITE, 0, 0, CREATE_ALWAYS, 0, 0
	cmp eax, -1
    jne err_make_file_proc
    call err_make_file
err_make_file_proc:
    mov outhan, eax 						; сохранение хендла
    ret
makefile endp

writefile proc
    invoke WriteFile, outhan, memPoint, smem, offset roll  , 0 ; запись из памяти memPoint в Файл
	cmp eax, 0 
    jne err_write_file_proc
    call err_write_file
    ret
err_write_file_proc:
    ret
writefile endp

main proc         
    call openfile_write 					; ввод имени входного файла, открытие
    call makefile							; ввод имени выходного файла, создание
    call task								; чтение, обработка и запись
    print succes							 
    invoke Sleep, 200						; пауза на 200 мс
	invoke LocalFree, memPoint				; освобождение памяти
	invoke CloseHandle, inhan				; закрытие входного файла
	invoke CloseHandle, outhan				; закрытие выходного файла
	call FreeConsole						; освобожение консоли
    ret 
main endp  

mainStart:   
	call FreeConsole 						; сброс консоли
	call AllocConsole 					   	; создание новой консоли для текущего процесса
    invoke GetStdHandle, STD_OUTPUT_HANDLE 	; получеаем хэндл выходного файла
    mov OutHandle, eax
	invoke GetStdHandle, STD_INPUT_HANDLE 	; gолучеаем хэндл входного файла
    mov InHandle, eax
    call main
    invoke ExitProcess, 0					; завершение процесса с кодом выхода 0 (успешно)

end mainStart


