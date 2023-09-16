.386
.MODEL FLAT, STDCALL
;OPTION CASEMAP: NONE
; ��������� ������� ������� (��������) ����������� ���������� EXTERN, 
; ����� ����� @ ����������� ����� ����� ������������ ����������,
; ����� ��������� ����������� ��� �������� ������� � ���������
EXTERN  GetStdHandle@4: PROC
EXTERN  WriteConsoleA@20: PROC
EXTERN  CharToOemA@8: PROC
EXTERN  ReadConsoleA@20: PROC
EXTERN  ExitProcess@4: PROC; ������� ������ �� ���������
EXTERN  lstrlenA@4: PROC; ������� ����������� ����� ������
.DATA; ������� ������
INPUT DB "������� ����� � ������������ ������� ���������: ", 13,10,0 ;������ - ����������� �����
OUTPUT DB "���������: ", 13,10,0 ;������ - ����� ������� ����������
STRN1 DB 50 dup(?) ;������ ��� ����� ������� �����
STRN2 DB 50 dup(?) ;������ ��� ����� ������� �����
RESULT DB 50 dup(?) ;������, � ������� ������� ���������
DIN DD ? ;���������� �����
DOUT DD ? ;���������� ������
NUMBER1 DD ? ;������ ����� � ���������
NUMBER2 DD ? ;������ �����
LEN DD ? ;��������������� ����������-���������� ��������
SIGN DD 1 ;���� �����, ����� ���������� �� -1
MINUS DB "-" ;����� 

.CODE; ������� ���� 
MAIN PROC; ������ �������� ��������� � ������ MAIN

;������� ����������� ����� � ������
PUSH -10
CALL GetStdHandle@4
MOV DIN, EAX
PUSH -11
CALL GetStdHandle@4
MOV DOUT, EAX

;����������� ������ � DOS-���������
MOV EAX, OFFSET INPUT
PUSH EAX
PUSH EAX
CALL CharToOemA@8

MOV EAX, OFFSET OUTPUT
PUSH EAX
PUSH EAX
CALL CharToOemA@8

;����� ����������� ����� ��� ������� �����
PUSH OFFSET INPUT
CALL lstrlenA@4
PUSH 0
PUSH OFFSET LEN
PUSH EAX
PUSH OFFSET INPUT
PUSH DOUT
CALL WriteConsoleA@20

;���� ������� �����
PUSH 0
PUSH OFFSET LEN
PUSH 50
PUSH OFFSET STRN1
PUSH DIN
CALL ReadConsoleA@20

;������� ������ ������ � �����
;�������� �����
MOV ESI, OFFSET STRN1
MOV EDI, OFFSET MINUS
CMPSB
JNE @I1
	SUB LEN, 1
	MOV SIGN, -1
	INC ESI
@I1: DEC ESI
SUB LEN, 2 ;�������� ��� ������� - \r\n
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


;����� ����������� ����� ��� ������� �����
PUSH OFFSET INPUT
CALL lstrlenA@4
PUSH 0
PUSH OFFSET LEN
PUSH EAX
PUSH OFFSET INPUT
PUSH DOUT
CALL WriteConsoleA@20

;���� ������� �����
PUSH 0
PUSH OFFSET LEN
PUSH 50
PUSH OFFSET STRN2
PUSH DIN
CALL ReadConsoleA@20

;������� ������ ������ � �����
;�������� �����
MOV SIGN, 1
MOV ESI, OFFSET STRN2
MOV EDI, OFFSET MINUS
CMPSB
JNE @I2
	SUB LEN, 1
	MOV SIGN, -1
	INC ESI
@I2: DEC ESI
SUB LEN, 2 ;�������� ��� ������� - \r\n
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
;CMP NUMBER2, 0     ���� �� ������������� �����
;JGE @T1
;	MOV NUMBER2, 0
;	MOV NUMBER2, 0
;@T1:

; �������� ���� �����
ADD NUMBER1, EAX

; ������� ����� � ������
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

; ����� ������, �������������� ����������
PUSH OFFSET OUTPUT
CALL lstrlenA@4
PUSH 0
PUSH OFFSET LEN
PUSH EAX
PUSH OFFSET OUTPUT
PUSH DOUT
CALL WriteConsoleA@20

; ����� ����������
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

MAIN ENDP; ���������� �������� ��������� � ������ MAIN
END MAIN; ���������� �������� ������ � ��������� ������ ����������� ���������
