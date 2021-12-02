;*************************************************************************
; lab11.ASM                                                              *
;    Programa teste para as instruções implementadas:                    *
;    - FILLBLOCK;                                                        *
;    - MOVBLOCK;                                                         *
;    - LONGADD;                                                          *
;    - LONGSUB;                                                          *
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
;         "zmac -8 --oo lst,hex lab11.asm".                              *
;                                                                        *
;    zmac produzirá na pasta zout o arquivo "lab11.hex",                 *
;    imagem do código executável a ser carregado no projeto Proteus      *
;    e também o arquivo de listagem "lab11.lst".                         *
;                                                                        *
;*************************************************************************

; Define origem da ROM e da RAM (este programa tem dois segmentos).
; Diretivas nao podem comecar na primeira coluna.

CODIGO		EQU	0000H

DADOS		EQU	0E000H

TOPO_RAM	EQU	0FFFFH

;*******************************************
; Definicao de macros para que zmac reconheca
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

;********************
; Início do código  *
;********************

	ORG	CODIGO

INICIO:

; Teste FILLBLOCK
; Carrega a partir de DADOS o numero FFH (272) 20H (32) vezes          
		LXI	B,020H
		LXI	H,DADOS
		MVI	A,0FFH

		FILLBLOCK	; Mem[HL..HL+BC]<--A

; Teste MOVBLOCK
; Copia o conteudo a partir de DADOS para as posicoes a partir DADOS+40H (64) 20H (32) vezes
		LXI	D,DADOS
		LXI	H,DADOS+040H

		MOVBLOCK	; Mem[HL..HL+BC]<--Mem[DE..DE+BC]

; Teste LONGADD
; Copia os numeros de 8 bytes ADD1 e ADD2 para as posicoes 80H...80H+7 e 80H+8...80H+15
; Adiciona-os resultando no numero nas posicoes 80H+8...80H+15
		LXI	B,8		; Carrega 8 em BC
		LXI	D,ADD1		; Carrega o endereco do byte mais significativo de ADD1 em DE
		LXI	H,ADDPOS1	; Carrega o endereco futuro do numero ADD1
		MOVBLOCK		; Copia ADD1 a partir do endereco ADDPOS1

		LXI	D,ADD2		; Carrega o endereco do byte mais significativo de ADD2 em DE
		LXI	H,ADDPOS2	; Carrega o endereco futuro do numero ADD2
		MOVBLOCK		; Copia ADD2 a partir do endereco ADDPOS2

		LXI	D,ADDPOS1	; Carrega o endereco do numero ADD1
		LXI	H,ADDPOS2	; Carrega o endereco do numero ADD2
		LONGADD			; Soma ADD1 e ADD2 com resultado em ADDPOS2

; Teste LONGSUB
; Copia os numeros de 8 bytes SUB1 e SUB2 para as posicoes B0H...B0H+7 e B0H+8...B0H+15
; Subtrai-os resultando no numero nas posicoes B0H+8...B0H+15
		LXI	B,8		; Carrega 8 em BC
		LXI	D,SUB1		; Carrega o endereco do byte mais significativo de SUB1 em DE
		LXI	H,SUBPOS1	; Carrega o endereco futuro do numero SUB1
		MOVBLOCK		; Copia SUB1 a partir do endereco SUBPOS1

		LXI	D,SUB2		; Carrega o endereco do byte mais significativo de SUB2 em DE
		LXI	H,SUBPOS2	; Carrega o endereco futuro do numero SUB2
		MOVBLOCK		; Copia SUB2 a partir do endereco SUBPOS2

		LXI	D,SUBPOS1	; Carrega o endereco do numero SUB1
		LXI	H,SUBPOS2	; Carrega o endereco do numero SUB2
		LONGSUB			; Soma SUB1 e SUB2 com resultado em SUBPOS2

END_LOOP:	JMP	$

; Define numeros para soma tal que Resultado = ADD1+ADD2
ADD1:	DB	00H,00H,00H,00H,00H,0ABH,0CDH,0EFH		
ADD2:	DB	00H,00H,00H,00H,00H,0FEH,0DCH,0BAH
; Resultado = 1AA AAA9

; Define numeros para subtracao tal que Resultado = SUB1-SUB2
SUB1:	DB	00H,00H,00H,00H,00H,0FEH,0DCH,0BAH	 
SUB2:	DB	00H,00H,00H,00H,00H,0ABH,0CDH,0EFH
; Resultado = 53 0ECB

	ORG	DADOS+080H
ADDPOS1:	DS	8
ADDPOS2:	DS	8

	ORG	DADOS+0B0H
SUBPOS1:	DS	8
SUBPOS2:	DS	8

 
        END	INICIO