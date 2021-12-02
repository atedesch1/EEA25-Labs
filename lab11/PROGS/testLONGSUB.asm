;*************************************************************************
; testLONGSUB.ASM                                                        *
;                                                                        *
;    Programa teste para a instrucão LONSUB.                             *
;                                                                        *
;    LONGSUB nao faz parte do conjunto instrucoes do 8080/8085.          *
;                                                                        *
;    LONGSUB é codifivada com o byte [20H].                              *
;      Subtrai o numero de C bytes apontado por DE                       *
;      do numero de C bytes apontado por HL e coloca o                   *
;      o resultado a partir do endereço HL.                              *
;      Os numeros são armazenados do byte mais significativo             *
;      para o menos significativo. Afeta apenas CARRY.                   *
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
;         "zmac -8 --oo lst,hex longsub.asm".                            *
;                                                                        *
;    zmac produzirá na pasta zout o arquivo "longsub.hex", imagem do     *
;    código executável a ser carregado no projeto Proteus e também       *
;    e também o arquivo de listagem "longsub.lst".                       *
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

INICIO:         LXI	B,8
		LXI	D,CONSTANTE1
		LXI	H,PARCELA1
		MOVBLOCK

		LXI	D,CONSTANTE2
		LXI	H,PARCELA2
		MOVBLOCK

		LXI	B,8
		LXI	D,PARCELA1
		LXI	H,PARCELA2

; Efetua Mem[HL..HL+(C-1)]<--Mem[HL..HL+(C-1)]-Mem[DE..DE+(C-1)].
REP_LONGSUB:	LONGSUB
		JMP	STOP_LONGSUB
		JMP	REP_LONGSUB

STOP_LONGSUB:	JMP	$

CONSTANTE1:	DB	00H,00H,00H,00H,00H,0FEH,0DCH,0BAH	 
CONSTANTE2:	DB	00H,00H,00H,00H,00H,0ABH,0CDH,0EFH


	ORG	DADOS
PARCELA1:	DS	8
PARCELA2:	DS	8

        END	INICIO

