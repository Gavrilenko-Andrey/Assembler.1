.386
.MODEL FLAT, STDCALL
;OPTION CASEMAP: NONE
; прототипы внешних функций (процедур) описываются директивой EXTERN, 
; после знака @ указывается общая длина передаваемых параметров,
; после двоеточия указывается тип внешнего объекта – процедура
EXTERN  GetStdHandle@4: PROC
EXTERN  WriteConsoleA@20: PROC
EXTERN  CharToOemA@8: PROC
EXTERN  ReadConsoleA@20: PROC
EXTERN  ExitProcess@4: PROC; функция выхода из программы
EXTERN  lstrlenA@4: PROC; функция определения длины строки
.DATA; сегмент данных
INPUT DB "Введите число в восьмеричной системе счисления: ", 13,10,0 ;Строка - приглашение ввода
OUTPUT DB "Результат: ", 13,10,0 ;Строка - перед выводом результата
STRN1 DB 50 dup(?) ;Строка для ввода первого числа
STRN2 DB 50 dup(?) ;Строка для ввода второго числа
RESULT DB 50 dup(?) ;Строка, в которую запишем результат
DIN DD ? ;Дескриптор ввода
DOUT DD ? ;Дескриптор вывода
NUMBER1 DD ? ;Первое число и результат
NUMBER2 DD ? ;Второе число
LEN DD ? ;Вспомогательная переменная-количество символов
SIGN DD 1 ;Знак числа, может измениться на -1
MINUS DB "-" ;Минус 

.CODE; сегмент кода 
MAIN PROC; начало описания процедуры с именем MAIN

;Получим дескрипторы ввода и вывода
PUSH -10
CALL GetStdHandle@4
MOV DIN, EAX
PUSH -11
CALL GetStdHandle@4
MOV DOUT, EAX

;Преобразуем строки в DOS-кодировку
MOV EAX, OFFSET INPUT
PUSH EAX
PUSH EAX
CALL CharToOemA@8

MOV EAX, OFFSET OUTPUT
PUSH EAX
PUSH EAX
CALL CharToOemA@8

;Вывод приглашения ввода для первого числа
PUSH OFFSET INPUT
CALL lstrlenA@4
PUSH 0
PUSH OFFSET LEN
PUSH EAX
PUSH OFFSET INPUT
PUSH DOUT
CALL WriteConsoleA@20

;Ввод первого числа
PUSH 0
PUSH OFFSET LEN
PUSH 50
PUSH OFFSET STRN1
PUSH DIN
CALL ReadConsoleA@20

;Перевод первой строки в число
;Проверка знака
MOV ESI, OFFSET STRN1
MOV EDI, OFFSET MINUS
CMPSB
JNE @I1
	SUB LEN, 1
	MOV SIGN, -1
	INC ESI
@I1: DEC ESI
SUB LEN, 2 ;Отнимаем два символа - \r\n
MOV DI, 8
MOV ECX, LEN
XOR AX, AX
XOR BX, BX
WHEEL:
	MOV BL, [ESI]
	SUB BL, '0'
	MUL DI
	ADD AX, BX
	INC ESI
LOOP WHEEL
IMUL SIGN
MOV NUMBER1, EAX


;Вывод приглашения ввода для второго числа
PUSH OFFSET INPUT
CALL lstrlenA@4
PUSH 0
PUSH OFFSET LEN
PUSH EAX
PUSH OFFSET INPUT
PUSH DOUT
CALL WriteConsoleA@20

;Ввод второго числа
PUSH 0
PUSH OFFSET LEN
PUSH 50
PUSH OFFSET STRN2
PUSH DIN
CALL ReadConsoleA@20

;Перевод второй строки в число
;Проверка знака
MOV SIGN, 1
MOV ESI, OFFSET STRN2
MOV EDI, OFFSET MINUS
CMPSB
JNE @I2
	SUB LEN, 1
	MOV SIGN, -1
	INC ESI
@I2: DEC ESI
SUB LEN, 2 ;Отнимаем два символа - \r\n
MOV DI, 8
MOV ECX, LEN
XOR AX, AX
XOR BX, BX
ROLL:
	MOV BL, [ESI]
	SUB BL, '0'
	MUL DI
	ADD AX, BX
	INC ESI
LOOP ROLL
IMUL SIGN
MOV NUMBER2, EAX
;CMP NUMBER2, 0     Тест на отрицательное число
;JGE @T1
;	MOV NUMBER2, 0
;	MOV NUMBER2, 0
;@T1:

; Сложение двух чисел
ADD NUMBER1, EAX

; Перевод суммы в строку
MOV EAX, NUMBER1
MOV EDI, OFFSET RESULT
MOV ECX, 0
CMP EAX, 0
MOV EBX, 10
JGE @SPIN
	MOV DL, MINUS
	MOV [EDI], DL
	INC EDI
	NOT EAX
	INC EAX
@SPIN:
MOV EDX, 0
IDIV EBX
PUSH EDX
INC ECX
CMP EAX, 0
JG @SPIN
TWIRL:
	POP EDX
	ADD Dl, 30h
	MOV [EDI], DL
	INC EDI
LOOP TWIRL
MOV DL, 0
MOV [EDI], DL
;INC EDI
;MOV EAX, EDI
;SUB EAX, OFFSET RESULT

; Вывод строки, предшествующей результату
PUSH OFFSET OUTPUT
CALL lstrlenA@4
PUSH 0
PUSH OFFSET LEN
PUSH EAX
PUSH OFFSET OUTPUT
PUSH DOUT
CALL WriteConsoleA@20

; Вывод результата
PUSH OFFSET RESULT
CALL lstrlenA@4
PUSH 0
PUSH OFFSET LEN
PUSH EAX
PUSH OFFSET RESULT
PUSH DOUT
CALL WriteConsoleA@20

PUSH 0
CALL ExitProcess@4

MAIN ENDP; завершение описания процедуры с именем MAIN
END MAIN; завершение описания модуля с указанием первой выполняемой процедуры
