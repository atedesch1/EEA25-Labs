;*************************************************************************
; testJMP256.ASM                                                         *
;    Programa teste para instrução JMP256.                               *
;    JMP256 nao esta contida no conjunto de instrucoes do 8080/8085.     *
;                                                                        *
;  JMP256 é codificada com o byte [0CBH].                                *
;    Salta para o endereco armazenado na tabela de words apontada        *
;    por HL+2*A. "A" funciona como um indice na tabela, a qual           *
;    pode conter ate 256 enderecos.                                      *
;    Nao deixa efeitos colaterais em PSW,BC,DE e HL.                     *
;                                                                        *
;    O programa assume um hardware dotado dos seguintes elementos:       *
;                                                                        *
;    - Processador MP8 (8080/8085 simile);                               *
;    - ROM de 0000H a 1FFFh;                                             *
;    - RAM de E000h a FFFFh;                                             *
;    - UART 8250A vista nos enderecos 08H a 0Fh;                         *
;    - PIO de entrada vista no endereço 00h;                             *
;    - PIO de saída vista no endereço 00h.                               *
;                                                                        *
;    Para compilar e "linkar" o programa, pode ser usado o assembler     *
;    "zmac", com a linha de comando:                                     *
;                                                                        *
;         "zmac -8 --oo lst,hex testjmp256.asm".                         *
;                                                                        *
;    zmac produzirá na pasta zout o arquivo "testjmp256.hex", imagem do  *
;    código executável a ser carregado no projeto Proteus e também       *
;    e também o arquivo de listagem "testjmp256.lst".                    *
;                                                                        *
;*************************************************************************

; Define origem da ROM e da RAM (este programa tem dois segmentos).
; Diretivas nao podem comecar na primeira coluna.

CODIGO		EQU	0000H

DADOS		EQU	0E000H

TOPO_RAM	EQU	0FFFFH

;*******************************************
; Definicao de macros par que zmac reconheca
; novos mnemonicos de instrucao.
;*******************************************

FILLBLOCK	MACRO
		DB	08H
		ENDM	

MOVBLOCK	MACRO
		DB	10H
		ENDM	

LONGADD		MACRO
		DB	18H
		ENDM	

LONGSUB		MACRO
		DB	20H
		ENDM	

LONGCMP		MACRO
		DB	28H
		ENDM	

JMP256		MACRO
		DB	0CBH
		ENDM

;********************
; Início do código  *
;********************

	ORG	CODIGO

INICIO:         LXI	SP,TOPO_RAM-1
		CALL	INICIASIO
REPETIR:	LXI	H,MENSAGEM
		CALL	DISPLAY

LOOP:		CALL	INPUT
		CPI	'0'	; Rejeita se < '0'
		JC	REJEITAR
		CPI	'9'+1	; Rejeita se > '9'
		JNC	REJEITAR

ACEITAR:	SUI	'0'
		LXI	H,TABELA

; Salta para o endereco contido na tabela de words apontada por HL
; indexada pelo conteúdo de "A".
; PC <-- Mem[Mem[HL+2*A]] ou seja
;   PCL <-- Mem[Mem[HL+2*A]] e PCH <-- Mem[Mem[HL+2*A+1]].

		JMP256

REJEITAR:	JMP	REPETIR

;********************
; Tabela de saltos  *
;********************
TABELA	DW	CASO0,CASO1,CASO2,CASO3,CASO4,CASO5,CASO6,CASO7,CASO8,CASO9

;******************************
; Codigos para CASO0 a CASO9  *
;******************************
CASO0:	LXI	H,MENSAGEM0
	CALL	DISPLAY
	JMP	LOOP

CASO1:	LXI	H,MENSAGEM1
	CALL	DISPLAY
	JMP	LOOP

CASO2:	LXI	H,MENSAGEM2
	CALL	DISPLAY
	JMP	LOOP

CASO3:	LXI	H,MENSAGEM3
	CALL	DISPLAY
	JMP	LOOP

CASO4:	LXI	H,MENSAGEM4
	CALL	DISPLAY
	JMP	LOOP

CASO5:	LXI	H,MENSAGEM5
	CALL	DISPLAY
	JMP	LOOP

CASO6:	LXI	H,MENSAGEM6
	CALL	DISPLAY
	JMP	LOOP

CASO7:	LXI	H,MENSAGEM7
	CALL	DISPLAY
	JMP	LOOP

CASO8:	LXI	H,MENSAGEM8
	CALL	DISPLAY
	JMP	LOOP

CASO9:	LXI	H,MENSAGEM9
	CALL	DISPLAY
	JMP	LOOP

;********************************
; Mensagem inicial e
; Mensagens para CASO0 a CASO9  *
;********************************
;**********************************
RETURN          EQU     0DH
LINEFEED	EQU	0AH

MENSAGEM:       DB      "Digite uma tecla pertencente a",RETURN
		DB	"{0,1,2,3,4,5,6,7,8,9}.",RETURN,"$"

MENSAGEM0:	DB	"Zero.",RETURN,'$'
MENSAGEM1:	DB	"Um.",RETURN,'$'
MENSAGEM2:	DB	"Dois.",RETURN,'$'
MENSAGEM3:	DB	"Tres.",RETURN,'$'
MENSAGEM4:	DB	"Quatro.",RETURN,'$'
MENSAGEM5:	DB	"Cinco.",RETURN,'$'
MENSAGEM6:	DB	"Seis.",RETURN,'$'
MENSAGEM7:	DB	"Sete.",RETURN,'$'
MENSAGEM8:	DB	"Oito.",RETURN,'$'
MENSAGEM9:	DB	"Nove.",RETURN,'$'

;****************************************************
;****************************************************
;    SUBROTINAS PARA MANIPULACAO DA UART 8250A     **
;                                                  **
;    NAO ALTERE O QUE VEM A SEGUIR !!!!            **
;****************************************************
;****************************************************


;****************************
;  Definicao de constantes  *
;****************************
RBR             EQU     08H     ; Com bit DLA (LCR.7) em 0.
THR             EQU     08H     ; Com bit DLA (LCR.7) em 0.     
IER             EQU     09H     ; Com bit DLA (LCR.7) em 0.
IIR             EQU     0AH
LCR             EQU     0BH
MCR             EQU     0CH
LSR             EQU     0DH
MSR             EQU     0EH
DLL             EQU     08H     ; Com bit DLA (LCR.7) em 1.
DLM             EQU     09H     ; Com bit DLA (LCR.7) em 1.
SCR             EQU     0FH
;*******************************************************
;  INICIASIO                                           *
;    Inicializa a UART 8250A                           *
;                                                      *
;    UART 8250A inicializada com:                      *
;      - 1 stop bit;                                   *
;      - sem paridade;                                 *
;      - palavras de 8 bits;                           *
;      - baud rate = CLOCK/(16*DIVISOR).               *
;                                                      *
;                                                      *
;    Para operar a 9600 baud devemos ter portanto:     *
;        DIVISOR = 1843200/(16*9600) = 12 = 0CH        *
;                                                      *
;*******************************************************
INICIASIO:      PUSH    PSW

                MVI     A,10000011B
                OUT     LCR
                MVI     A,0CH
                OUT     DLL
                MVI     A,00H
                OUT     DLM
                MVI     A,00000011B
                OUT     LCR

                POP     PSW
                RET
;                               *
;********************************

;*********************************************************************
;  OUTPUT                                                            *
;    Envia A para transmissao pela UART 8250A.                       *
;                                                                    *
;    Somente retorna apos conseguir escrever A no BUFFER da UART.    *
;    Preserva todos os registradores.                                *
;                                                                    *
;   STATUS_UART = (DSR,BRKDET,FE,OE,PE,TXEMPTY,RXREADY,TXREADY)      *
;                                                                    *
;*********************************************************************
OUTPUT:         PUSH    PSW
                PUSH    B

                MOV     B,A
OUTPUTLP:       IN      LSR
                ANI     20H
                JZ      OUTPUTLP
                MOV     A,B
                OUT     THR

                POP     B
                POP     PSW
                RET
;                               *
;********************************

;****************************************************************************
;  INPUT                                                                    *
;    Le byte recebido pela UART 8250A                                       *
;                                                                           *
;      Somente retorna apos detectar um byte no BUFFER de dados da UART.    *
;                                                                           *
;      Retorna com o byte em A.  Preserva os demais registradores.          *
;                                                                           *
;      STATUS_UART = (DSR,BRKDET,FE,OE,PE,TXEMPTY,RXREADY,TXREADY)          *
;                                                                           *
;****************************************************************************
INPUT:          PUSH    PSW

INPUTLP:        IN      LSR
                ANI     00000001B
                JZ      INPUTLP

                POP     PSW
                IN      RBR
                RET
;                               *
;********************************

;********************************************************************
;  CHECKINPUT                                                       *
;    Verifica se ha byte recebido pela UART 8250A:                  *
;                                                                   *
;    Se houver byte retorna com flag Z = 1;                         *
;    caso contrario retorna com flag Z = 0;                         *
;                                                                   *
;    Preserva os demais registradores.                              *
;                                                                   *
;    STATUS_UART = (DSR,BRKDET,FE,OE,PE,TXEMPTY,RXREADY,TXREADY)    *
;                                                                   *
;********************************************************************
CHECKINPUT:     PUSH    PSW

                IN      LSR
                ANI     00000001B
                JNZ     TEMBYTE

; Retorno quando nao tem byte.
NAOTEMBYTE:     POP     PSW
                STC
                CMC
                RET

; Retorno quando tem byte.
TEMBYTE:        POP     PSW
                STC
                RET
;                               *
;********************************

;****************************************************
; DISPLAY                                           *
;   Subrotina para imprimir cadeia de caracteres.   *
;                                                   *
;   Parametro: HL aponta para string ASCII          *
;   terminado em "$"                                *
;****************************************************

DISPLAY:        PUSH    PSW
                PUSH    B
                PUSH    D
                PUSH    H

ADIANTE:        MOV     A,M
                CPI     "$"
                JZ      DISPLAY_FIM
                CALL    OUTPUT
                INX     H
                JMP     ADIANTE

DISPLAY_FIM:    POP     H
                POP     D
                POP     B
                POP     PSW
                RET
;                               *
;********************************


;                               *
;********************************


;       Final do segmento "CODIGO"                                   **
;                                                                    **
;**********************************************************************
;**********************************************************************

        END	INICIO

