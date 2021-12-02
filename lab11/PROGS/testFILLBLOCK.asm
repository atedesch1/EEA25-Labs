;*************************************************************************
; testFILLBLOCK.ASM                                                      *
;    Programa teste para instrução FILLBLOCK.                            *
;    FILLBLOCK Nao faz parte do conjunto de instrucoes do 8080/8085.     *
;                                                                        *
;      FILLBLOCK codificada com o byte [08H]                             *
;        Preenche BC posicoes da memoria, a partir do endereco HL        *
;        com a constante A.                                              *
;        Nao deixa efeitos colaterais em PSW,BC,DE e HL.                 *
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
;         "zmac -8 --oo lst,hex testfillblock.asm".                      *
;                                                                        *
;    zmac produzirá na pasta zout o arquivo "testfillblock.hex",         *
;    imagem do código executável a ser carregado no projeto Proteus      *
;    e também o arquivo de listagem "testfillblock.lst".                 *
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

INICIO:         LXI	B,0100H
		LXI	H,DADOS
		MVI	A,69H

; Preenche BC posicoes de memória, a partir de HL,
; com a constante A.
		FILLBLOCK
	JMP $
		


        END	INICIO

