;*************************************************************************
;  TESTPCHL.ASM                                                          *
;    Programa teste para instruções de entrada e saída, pchl e outras.   *
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
;         "zmac -8 --oo lst,hex testpchl.asm".                           *
;                                                                        *
;    zmac produzirá na pasta zout o arquivo "testpchl.hex", imagem do    *
;    código executável a ser carregado no projeto Proteus e também       *
;    e também o arquivo de listagem "testpchl.lst".                      *
;                                                                        *
;*************************************************************************

; Define origem da ROM e da RAM (este programa tem dois segmentos).
; Diretivas e instruções nao podem comecar na primeira coluna.

CODIGO		EQU	0000H

DADOS		EQU	0E000H

TOPO_RAM	EQU	0FFFFH


;********************
; Início do código  *
;********************

	ORG	CODIGO

INICIO:         LXI     SP,TOPO_RAM   ; Pilha na RAM.
                CALL    INICIASIO

; Imprime mensagem.
                LXI     H,MENSAGEM
                CALL    DISPLAY

; Aqui comeca o teste de PCHL (PC <-- HL)".

LOOP:		CALL	INPUT		; Le entrada.		

; Aceita apenas se pertencer a {A, B,...,Z,[,\,^,_,`,]a,b,...,z}.
		CPI	'A'
		JC	REJEITAR	
		CPI	'z'+1
		JC	ACEITAR


REJEITAR:	LXI	H,MENSAGEM_INVALIDA
		CALL	DISPLAY
		JMP	LOOP

ACEITAR:

; Lembrar que A contem o codigo lido.
; Constroi em HL o endereco "TABELA + 2* codigo lido".
; Depois faz DE <-- Mem[HL] = Endereco para onde vai saltar.
; Faz a troca HL <--> DE.

; Utiliza BC para embilhar um endereco de retorno para
;    simular uma chamada de subrotina com o salto.

; Salta para o endereco contido em HL utilizando PCHL.

		LXI	D,0000H	; DE <-- 0000H.
		PUSH	PSW	; Salva A.

; Efetua DE <-- DE + 2*A
		ADD	A,E	; DE <-- DE+A.
		MOV	E,A
		MOV	A,D
		ACI	00H
		MOV	D,A

		POP	PSW

		ADD	A,E	; DE <-- DE+A.
		MOV	E,A
		MOV	A,D
		ACI	00H
		MOV	D,A

		LXI	H,TABELA
		DAD	D	; HL <-- TABELA + 2*codigo do simbolo.
 
		MOV	E,M
		INX	H
		MOV	D,M
		XCHG
 		LXI	B,RETORNO
		PUSH	B	; Empilha endereco de retorno
				; Para poder voltar do salto com RET.

; Salto para endereco computado (endereco = Mem[TABELA + 2*(codigo do simbolo)]). 

		PCHL		; Salta para "Mem[TABELA + 2*(codigo do simbolo)]".
RETORNO:	JMP	LOOP
	

; Tabela de saltos.
TABELA:		DW	C00,C01,C02,C03,C04,C05,C06,C07,C08,C09
		DW	C10,C11,C12,C13,C14,C15,C16,C17,C18,C19
		DW	C20,C21,C22,C23,C24,C25,C26,C27,C28,C29
		DW	C30,C31,C32,C33,C34,C35,C36,C37,C38,C39
		DW	C40,C41,C42,C43,C44,C45,C46,C47,C48,C49
		DW	C50,C51,C52,C53,C54,C55,C56,C57,C58,C59
		DW	C60,C61,C62,C63,C64,C65,C66,C67,C68,C69
		DW	C70,C71,C72,C73,C74,C75,C76,C77,C78,C79
		DW	C80,C81,C82,C83,C84,C85,C86,C87,C88,C89
		DW	C90,C91,C92,C93,C94,C95,C96,C97,C98,C99
		DW	C100,C101,C102,C103,C104,C105,C106,C107,C108,C109
		DW	C110,C111,C112,C113,C114,C115,C116,C117,C118,C119
		DW	C120,C121,C122,C123,C124,C125,C126,C127,C128,C129
		DW	C130,C131,C132,C133,C134,C135,C136,C137,C138,C139
		DW	C140,C141,C142,C143,C144,C145,C146,C147,C148,C149
		DW	C150,C151,C152,C153,C154,C155,C156,C157,C158,C159
		DW	C160,C161,C162,C163,C164,C165,C166,C167,C168,C169
		DW	C170,C171,C172,C173,C174,C175,C176,C177,C178,C179
		DW	C180,C181,C182,C183,C184,C185,C186,C187,C188,C189
		DW	C190,C191,C192,C193,C194,C195,C196,C197,C198,C199
		DW	C200,C201,C202,C203,C204,C205,C206,C207,C208,C209
		DW	C210,C211,C212,C213,C214,C215,C216,C217,C218,C219
		DW	C220,C221,C222,C223,C224,C225,C226,C227,C228,C229
		DW	C230,C231,C232,C233,C234,C235,C236,C237,C238,C239
		DW	C240,C241,C242,C243,C244,C245,C246,C247,C248,C249
		DW	C250,C251,C252,C253,C254,C255

C00:		LXI	H,M_C00	
		CALL	DISPLAY
		RET

C01:		LXI	H,M_C01	
		CALL	DISPLAY
		RET

C02:		LXI	H,M_C02	
		CALL	DISPLAY
		RET

C03:		LXI	H,M_C03	
		CALL	DISPLAY
		RET

C04:		LXI	H,M_C04	
		CALL	DISPLAY
		RET

C05:		LXI	H,M_C05	
		CALL	DISPLAY
		RET

C06:		LXI	H,M_C06	
		CALL	DISPLAY
		RET

C07:		LXI	H,M_C07	
		CALL	DISPLAY
		RET

C08:		LXI	H,M_C08	
		CALL	DISPLAY
		RET

C09:		LXI	H,M_C09	
		CALL	DISPLAY
		RET

C10:		LXI	H,M_C10	
		CALL	DISPLAY
		RET

C11:		LXI	H,M_C11	
		CALL	DISPLAY
		RET

C12:		LXI	H,M_C12	
		CALL	DISPLAY
		RET

C13:		LXI	H,M_C13	
		CALL	DISPLAY
		RET

C14:		LXI	H,M_C14	
		CALL	DISPLAY
		RET

C15:		LXI	H,M_C15	
		CALL	DISPLAY
		RET

C16:		LXI	H,M_C16	
		CALL	DISPLAY
		RET

C17:		LXI	H,M_C17	
		CALL	DISPLAY
		RET

C18:		LXI	H,M_C18	
		CALL	DISPLAY
		RET

C19:		LXI	H,M_C19	
		CALL	DISPLAY
		RET

C20:		LXI	H,M_C20	
		CALL	DISPLAY
		RET

C21:		LXI	H,M_C21	
		CALL	DISPLAY
		RET

C22:		LXI	H,M_C22	
		CALL	DISPLAY
		RET

C23:		LXI	H,M_C23	
		CALL	DISPLAY
		RET

C24:		LXI	H,M_C24	
		CALL	DISPLAY
		RET

C25:		LXI	H,M_C25	
		CALL	DISPLAY
		RET

C26:		LXI	H,M_C26	
		CALL	DISPLAY
		RET

C27:		LXI	H,M_C27	
		CALL	DISPLAY
		RET

C28:		LXI	H,M_C28	
		CALL	DISPLAY
		RET

C29:		LXI	H,M_C29	
		CALL	DISPLAY
		RET

C30:		LXI	H,M_C30	
		CALL	DISPLAY
		RET

C31:		LXI	H,M_C31	
		CALL	DISPLAY
		RET

C32:		LXI	H,M_C32	
		CALL	DISPLAY
		RET

C33:		LXI	H,M_C33	
		CALL	DISPLAY
		RET

C34:		LXI	H,M_C34	
		CALL	DISPLAY
		RET

C35:		LXI	H,M_C35	
		CALL	DISPLAY
		RET

C36:		LXI	H,M_C36	
		CALL	DISPLAY
		RET

C37:		LXI	H,M_C37	
		CALL	DISPLAY
		RET

C38:		LXI	H,M_C38	
		CALL	DISPLAY
		RET

C39:		LXI	H,M_C39	
		CALL	DISPLAY
		RET

C40:		LXI	H,M_C40	
		CALL	DISPLAY
		RET

C41:		LXI	H,M_C41	
		CALL	DISPLAY
		RET

C42:		LXI	H,M_C42	
		CALL	DISPLAY
		RET

C43:		LXI	H,M_C43	
		CALL	DISPLAY
		RET

C44:		LXI	H,M_C44	
		CALL	DISPLAY
		RET

C45:		LXI	H,M_C45	
		CALL	DISPLAY
		RET

C46:		LXI	H,M_C46	
		CALL	DISPLAY
		RET

C47:		LXI	H,M_C47	
		CALL	DISPLAY
		RET

C48:		LXI	H,M_C48	
		CALL	DISPLAY
		RET

C49:		LXI	H,M_C49	

		CALL	DISPLAY
		RET

C50:		LXI	H,M_C50	
		CALL	DISPLAY
		RET

C51:		LXI	H,M_C51	
		CALL	DISPLAY
		RET

C52:		LXI	H,M_C52	
		CALL	DISPLAY
		RET

C53:		LXI	H,M_C53	
		CALL	DISPLAY
		RET

C54:		LXI	H,M_C54	
		CALL	DISPLAY
		RET

C55:		LXI	H,M_C55	
		CALL	DISPLAY
		RET

C56:		LXI	H,M_C56	
		CALL	DISPLAY
		RET

C57:		LXI	H,M_C57	
		CALL	DISPLAY
		RET

C58:		LXI	H,M_C58	
		CALL	DISPLAY
		RET

C59:		LXI	H,M_C59	
		CALL	DISPLAY
		RET

C60:		LXI	H,M_C60	
		CALL	DISPLAY
		RET

C61:		LXI	H,M_C61	
		CALL	DISPLAY
		RET

C62:		LXI	H,M_C62	
		CALL	DISPLAY
		RET

C63:		LXI	H,M_C63	
		CALL	DISPLAY
		RET

C64:		LXI	H,M_C64	
		CALL	DISPLAY
		RET

C65:		LXI	H,M_C65	
		CALL	DISPLAY
		RET

C66:		LXI	H,M_C66	
		CALL	DISPLAY
		RET

C67:		LXI	H,M_C67	
		CALL	DISPLAY
		RET

C68:		LXI	H,M_C68	
		CALL	DISPLAY
		RET

C69:		LXI	H,M_C69	
		CALL	DISPLAY
		RET

C70:		LXI	H,M_C70	
		CALL	DISPLAY
		RET

C71:		LXI	H,M_C71	
		CALL	DISPLAY
		RET

C72:		LXI	H,M_C72	
		CALL	DISPLAY
		RET

C73:		LXI	H,M_C73	
		CALL	DISPLAY
		RET

C74:		LXI	H,M_C74	
		CALL	DISPLAY
		RET

C75:		LXI	H,M_C75	
		CALL	DISPLAY
		RET

C76:		LXI	H,M_C76	
		CALL	DISPLAY
		RET

C77:		LXI	H,M_C77	
		CALL	DISPLAY
		RET

C78:		LXI	H,M_C78	
		CALL	DISPLAY
		RET

C79:		LXI	H,M_C79	
		CALL	DISPLAY
		RET

C80:		LXI	H,M_C80	
		CALL	DISPLAY
		RET

C81:		LXI	H,M_C81	
		CALL	DISPLAY
		RET

C82:		LXI	H,M_C82	
		CALL	DISPLAY
		RET

C83:		LXI	H,M_C83	
		CALL	DISPLAY
		RET

C84:		LXI	H,M_C84	
		CALL	DISPLAY
		RET

C85:		LXI	H,M_C85	
		CALL	DISPLAY
		RET

C86:		LXI	H,M_C86	
		CALL	DISPLAY
		RET

C87:		LXI	H,M_C87	
		CALL	DISPLAY
		RET

C88:		LXI	H,M_C88	
		CALL	DISPLAY
		RET

C89:		LXI	H,M_C89	
		CALL	DISPLAY
		RET

C90:		LXI	H,M_C90	
		CALL	DISPLAY
		RET

C91:		LXI	H,M_C91	
		CALL	DISPLAY
		RET

C92:		LXI	H,M_C92	
		CALL	DISPLAY
		RET

C93:		LXI	H,M_C93	
		CALL	DISPLAY
		RET

C94:		LXI	H,M_C94	
		CALL	DISPLAY
		RET

C95:		LXI	H,M_C95	
		CALL	DISPLAY
		RET

C96:		LXI	H,M_C96	
		CALL	DISPLAY
		RET

C97:		LXI	H,M_C97	
		CALL	DISPLAY
		RET

C98:		LXI	H,M_C98	
		CALL	DISPLAY
		RET

C99:		LXI	H,M_C99	
		CALL	DISPLAY
		RET

C100:		LXI	H,M_C100	
		CALL	DISPLAY
		RET

C101:		LXI	H,M_C101	
		CALL	DISPLAY
		RET

C102:		LXI	H,M_C102	
		CALL	DISPLAY
		RET

C103:		LXI	H,M_C103	
		CALL	DISPLAY
		RET

C104:		LXI	H,M_C104	
		CALL	DISPLAY
		RET

C105:		LXI	H,M_C105	
		CALL	DISPLAY
		RET

C106:		LXI	H,M_C106	
		CALL	DISPLAY
		RET

C107:		LXI	H,M_C107	
		CALL	DISPLAY
		RET

C108:		LXI	H,M_C108	
		CALL	DISPLAY
		RET

C109:		LXI	H,M_C109	
		CALL	DISPLAY
		RET

C110:		LXI	H,M_C110	
		CALL	DISPLAY
		RET

C111:		LXI	H,M_C111	
		CALL	DISPLAY
		RET

C112:		LXI	H,M_C112	
		CALL	DISPLAY
		RET

C113:		LXI	H,M_C113	
		CALL	DISPLAY
		RET

C114:		LXI	H,M_C114	
		CALL	DISPLAY
		RET

C115:		LXI	H,M_C115	
		CALL	DISPLAY
		RET

C116:		LXI	H,M_C116	
		CALL	DISPLAY
		RET

C117:		LXI	H,M_C117	
		CALL	DISPLAY
		RET

C118:		LXI	H,M_C118	
		CALL	DISPLAY
		RET

C119:		LXI	H,M_C119	
		CALL	DISPLAY
		RET

C120:		LXI	H,M_C120	
		CALL	DISPLAY
		RET

C121:		LXI	H,M_C121	
		CALL	DISPLAY
		RET

C122:		LXI	H,M_C122	
		CALL	DISPLAY
		RET

C123:		LXI	H,M_C123	
		CALL	DISPLAY
		RET

C124:		LXI	H,M_C124	
		CALL	DISPLAY
		RET

C125:		LXI	H,M_C125	
		CALL	DISPLAY
		RET

C126:		LXI	H,M_C126	
		CALL	DISPLAY
		RET

C127:		LXI	H,M_C127	
		CALL	DISPLAY
		RET

C128:		LXI	H,M_C128	
		CALL	DISPLAY
		RET

C129:		LXI	H,M_C129	
		CALL	DISPLAY
		RET

C130:		LXI	H,M_C130	
		CALL	DISPLAY
		RET

C131:		LXI	H,M_C131	
		CALL	DISPLAY
		RET

C132:		LXI	H,M_C132	
		CALL	DISPLAY
		RET

C133:		LXI	H,M_C133	
		CALL	DISPLAY
		RET

C134:		LXI	H,M_C134	
		CALL	DISPLAY
		RET

C135:		LXI	H,M_C135	
		CALL	DISPLAY
		RET

C136:		LXI	H,M_C136	
		CALL	DISPLAY
		RET

C137:		LXI	H,M_C137	
		CALL	DISPLAY
		RET

C138:		LXI	H,M_C138	
		CALL	DISPLAY
		RET

C139:		LXI	H,M_C139	
		CALL	DISPLAY
		RET

C140:		LXI	H,M_C140	
		CALL	DISPLAY
		RET

C141:		LXI	H,M_C141	
		CALL	DISPLAY
		RET

C142:		LXI	H,M_C142	
		CALL	DISPLAY
		RET

C143:		LXI	H,M_C143	
		CALL	DISPLAY
		RET

C144:		LXI	H,M_C144	
		CALL	DISPLAY
		RET

C145:		LXI	H,M_C145	
		CALL	DISPLAY
		RET

C146:		LXI	H,M_C146	
		CALL	DISPLAY
		RET

C147:		LXI	H,M_C147	
		CALL	DISPLAY
		RET

C148:		LXI	H,M_C148	
		CALL	DISPLAY
		RET

C149:		LXI	H,M_C149	
		CALL	DISPLAY
		RET

C150:		LXI	H,M_C150	
		CALL	DISPLAY
		RET

C151:		LXI	H,M_C151	
		CALL	DISPLAY
		RET

C152:		LXI	H,M_C152	
		CALL	DISPLAY
		RET

C153:		LXI	H,M_C153	
		CALL	DISPLAY
		RET

C154:		LXI	H,M_C154	
		CALL	DISPLAY
		RET

C155:		LXI	H,M_C155	
		CALL	DISPLAY
		RET

C156:		LXI	H,M_C156	
		CALL	DISPLAY
		RET

C157:		LXI	H,M_C157	
		CALL	DISPLAY
		RET

C158:		LXI	H,M_C158	
		CALL	DISPLAY
		RET

C159:		LXI	H,M_C159	
		CALL	DISPLAY
		RET

C160:		LXI	H,M_C160	
		CALL	DISPLAY
		RET

C161:		LXI	H,M_C161	
		CALL	DISPLAY
		RET

C162:		LXI	H,M_C162	
		CALL	DISPLAY
		RET

C163:		LXI	H,M_C163	
		CALL	DISPLAY
		RET

C164:		LXI	H,M_C164	
		CALL	DISPLAY
		RET

C165:		LXI	H,M_C165	
		CALL	DISPLAY
		RET

C166:		LXI	H,M_C166	
		CALL	DISPLAY
		RET

C167:		LXI	H,M_C167	
		CALL	DISPLAY
		RET

C168:		LXI	H,M_C168	
		CALL	DISPLAY
		RET

C169:		LXI	H,M_C169	
		CALL	DISPLAY
		RET

C170:		LXI	H,M_C170	
		CALL	DISPLAY
		RET

C171:		LXI	H,M_C171	
		CALL	DISPLAY
		RET

C172:		LXI	H,M_C172	
		CALL	DISPLAY
		RET

C173:		LXI	H,M_C173	
		CALL	DISPLAY
		RET

C174:		LXI	H,M_C174	
		CALL	DISPLAY
		RET

C175:		LXI	H,M_C175	
		CALL	DISPLAY
		RET

C176:		LXI	H,M_C176	
		CALL	DISPLAY
		RET

C177:		LXI	H,M_C177	
		CALL	DISPLAY
		RET

C178:		LXI	H,M_C178	
		CALL	DISPLAY
		RET

C179:		LXI	H,M_C179	
		CALL	DISPLAY
		RET

C180:		LXI	H,M_C180	
		CALL	DISPLAY
		RET

C181:		LXI	H,M_C181	
		CALL	DISPLAY
		RET

C182:		LXI	H,M_C182	
		CALL	DISPLAY
		RET

C183:		LXI	H,M_C183	
		CALL	DISPLAY
		RET

C184:		LXI	H,M_C184	
		CALL	DISPLAY
		RET

C185:		LXI	H,M_C185	
		CALL	DISPLAY
		RET

C186:		LXI	H,M_C186	
		CALL	DISPLAY
		RET

C187:		LXI	H,M_C187	
		CALL	DISPLAY
		RET

C188:		LXI	H,M_C188	
		CALL	DISPLAY
		RET

C189:		LXI	H,M_C189	
		CALL	DISPLAY
		RET

C190:		LXI	H,M_C190	
		CALL	DISPLAY
		RET

C191:		LXI	H,M_C191	
		CALL	DISPLAY
		RET

C192:		LXI	H,M_C192	
		CALL	DISPLAY
		RET

C193:		LXI	H,M_C193	
		CALL	DISPLAY
		RET

C194:		LXI	H,M_C194	
		CALL	DISPLAY
		RET

C195:		LXI	H,M_C195	
		CALL	DISPLAY
		RET

C196:		LXI	H,M_C196	
		CALL	DISPLAY
		RET

C197:		LXI	H,M_C197	
		CALL	DISPLAY
		RET

C198:		LXI	H,M_C198	
		CALL	DISPLAY
		RET

C199:		LXI	H,M_C199	
		CALL	DISPLAY
		RET

C200:		LXI	H,M_C200	
		CALL	DISPLAY
		RET

C201:		LXI	H,M_C201	
		CALL	DISPLAY
		RET

C202:		LXI	H,M_C202	
		CALL	DISPLAY
		RET

C203:		LXI	H,M_C203	
		CALL	DISPLAY
		RET

C204:		LXI	H,M_C204	
		CALL	DISPLAY
		RET

C205:		LXI	H,M_C205	
		CALL	DISPLAY
		RET

C206:		LXI	H,M_C206	
		CALL	DISPLAY
		RET

C207:		LXI	H,M_C207	
		CALL	DISPLAY
		RET

C208:		LXI	H,M_C208	
		CALL	DISPLAY
		RET

C209:		LXI	H,M_C209	
		CALL	DISPLAY
		RET

C210:		LXI	H,M_C210	
		CALL	DISPLAY
		RET

C211:		LXI	H,M_C211	
		CALL	DISPLAY
		RET

C212:		LXI	H,M_C212	
		CALL	DISPLAY
		RET

C213:		LXI	H,M_C213	
		CALL	DISPLAY
		RET

C214:		LXI	H,M_C214	
		CALL	DISPLAY
		RET

C215:		LXI	H,M_C215	
		CALL	DISPLAY
		RET

C216:		LXI	H,M_C216	
		CALL	DISPLAY
		RET

C217:		LXI	H,M_C217	
		CALL	DISPLAY
		RET

C218:		LXI	H,M_C218	
		CALL	DISPLAY
		RET

C219:		LXI	H,M_C219	
		CALL	DISPLAY
		RET

C220:		LXI	H,M_C220	
		CALL	DISPLAY
		RET

C221:		LXI	H,M_C221	
		CALL	DISPLAY
		RET

C222:		LXI	H,M_C222	
		CALL	DISPLAY
		RET

C223:		LXI	H,M_C223	
		CALL	DISPLAY
		RET

C224:		LXI	H,M_C224	
		CALL	DISPLAY
		RET

C225:		LXI	H,M_C225	
		CALL	DISPLAY
		RET

C226:		LXI	H,M_C226	
		CALL	DISPLAY
		RET

C227:		LXI	H,M_C227	
		CALL	DISPLAY
		RET

C228:		LXI	H,M_C228	
		CALL	DISPLAY
		RET

C229:		LXI	H,M_C229	
		CALL	DISPLAY
		RET

C230:		LXI	H,M_C230	
		CALL	DISPLAY
		RET

C231:		LXI	H,M_C231	
		CALL	DISPLAY
		RET

C232:		LXI	H,M_C232	
		CALL	DISPLAY
		RET

C233:		LXI	H,M_C233	
		CALL	DISPLAY
		RET

C234:		LXI	H,M_C234	
		CALL	DISPLAY
		RET

C235:		LXI	H,M_C235	
		CALL	DISPLAY
		RET

C236:		LXI	H,M_C236	
		CALL	DISPLAY
		RET

C237:		LXI	H,M_C237	
		CALL	DISPLAY
		RET

C238:		LXI	H,M_C238	
		CALL	DISPLAY
		RET

C239:		LXI	H,M_C239	
		CALL	DISPLAY
		RET

C240:		LXI	H,M_C240	
		CALL	DISPLAY
		RET

C241:		LXI	H,M_C241	
		CALL	DISPLAY
		RET

C242:		LXI	H,M_C242	
		CALL	DISPLAY
		RET

C243:		LXI	H,M_C243	
		CALL	DISPLAY
		RET

C244:		LXI	H,M_C244	
		CALL	DISPLAY
		RET

C245:		LXI	H,M_C245	
		CALL	DISPLAY
		RET

C246:		LXI	H,M_C246	
		CALL	DISPLAY
		RET

C247:		LXI	H,M_C247	
		CALL	DISPLAY
		RET

C248:		LXI	H,M_C248	
		CALL	DISPLAY
		RET

C249:		LXI	H,M_C249	
		CALL	DISPLAY
		RET

C250:		LXI	H,M_C250	
		CALL	DISPLAY
		RET

C251:		LXI	H,M_C251	
		CALL	DISPLAY
		RET

C252:		LXI	H,M_C252	
		CALL	DISPLAY
		RET

C253:		LXI	H,M_C253	
		CALL	DISPLAY
		RET

C254:		LXI	H,M_C254	
		CALL	DISPLAY
		RET

C255:		LXI	H,M_C255	
		CALL	DISPLAY
		RET


M_C00:		DB " [NULL] codigo = 00", RETURN,'$'
M_C01:		DB " [Start of Heading] codigo = 01", RETURN,'$'
M_C02:		DB " [Start of Text] codigo = 02", RETURN,'$'
M_C03:		DB " [End of Heading] codigo = 03", RETURN,'$'
M_C04:		DB " [End of Transmission] codigo = 04", RETURN,'$'
M_C05:		DB " [Enquiry] codigo = 05", RETURN,'$'
M_C06:		DB " [Acknowledge] codigo = 06", RETURN,'$'
M_C07:		DB " [BELL] codigo = 07", RETURN,'$'
M_C08:		DB " [BACKSPACE] codigo = 08", RETURN,'$'
M_C09:		DB " [Horizontal Tab] codigo = 09", RETURN,'$'

M_C10:		DB " [Line Feed] codigo = 10", RETURN,'$'
M_C11:		DB " [Verticaal Tab] codigo = 11", RETURN,'$'
M_C12:		DB " [Form Feed] codigo = 12", RETURN,'$'
M_C13:		DB " [Carriage Return] codigo = 13", RETURN,'$'
M_C14:		DB " [Shift Out] codigo = 14", RETURN,'$'
M_C15:		DB " [Shift In] codigo = 15", RETURN,'$'
M_C16:		DB " [Data Link Escape] codigo = 16", RETURN,'$'
M_C17:		DB " [Device Control 1] codigo = 17", RETURN,'$'
M_C18:		DB " [Device Control 2] codigo = 18", RETURN,'$'
M_C19:		DB " [Device Control 3] codigo = 19", RETURN,'$'

M_C20:		DB " [Device Control 4] codigo = 20", RETURN,'$'
M_C21:		DB " [Negative Acknowledge] codigo = 21", RETURN,'$'
M_C22:		DB " [Synchronous Idle] codigo = 22", RETURN,'$'
M_C23:		DB " [End of Trans. Block]A codigo = 23", RETURN,'$'
M_C24:		DB " [Cancel] codigo = 24", RETURN,'$'
M_C25:		DB " [end of Medium] codigo = 25", RETURN,'$'
M_C26:		DB " [Substitute] codigo = 26", RETURN,'$'
M_C27:		DB " [escape] codigo = 27", RETURN,'$'
M_C28:		DB " [File Separator] codigo = 28", RETURN,'$'
M_C29:		DB " [Group Separator] codigo = 29", RETURN,'$'

M_C30:		DB " [Record Separator] codigo = 30", RETURN,'$'
M_C31:		DB " [Unit Separator] codigo = 31", RETURN,'$'
M_C32:		DB "[space] codigo = 32", RETURN,'$'
M_C33:		DB " ! codigo = 33", RETURN,'$'
M_C34:		DB " "" codigo = 34", RETURN,'$'
M_C35:		DB " # codigo = 35", RETURN,'$'
M_C36:		DB " $ codigo = 36", RETURN,'$'
M_C37:		DB " % codigo = 37", RETURN,'$'
M_C38:		DB " & codigo = 38", RETURN,'$'
M_C39:		DB " ' codigo = 39", RETURN,'$'

M_C40:		DB " ( codigo = 40", RETURN,'$'
M_C41:		DB " ) codigo = 41", RETURN,'$'
M_C42:		DB " * codigo = 42", RETURN,'$'
M_C43:		DB " + codigo = 43", RETURN,'$'
M_C44:		DB " , codigo = 44", RETURN,'$'
M_C45:		DB " - codigo = 45", RETURN,'$'
M_C46:		DB " , codigo = 46", RETURN,'$'
M_C47:		DB " / codigo = 47", RETURN,'$'
M_C48:		DB " 0 codigo = 48", RETURN,'$'
M_C49:		DB " 1 codigo = 49", RETURN,'$'

M_C50:		DB " 2 codigo = 50", RETURN,'$'
M_C51:		DB " 3 codigo = 51", RETURN,'$'
M_C52:		DB " 4 codigo = 52", RETURN,'$'
M_C53:		DB " 5 codigo = 53", RETURN,'$'
M_C54:		DB " 6 codigo = 54", RETURN,'$'
M_C55:		DB " 7 codigo = 55", RETURN,'$'
M_C56:		DB " 8 codigo = 56", RETURN,'$'
M_C57:		DB " 9 codigo = 57", RETURN,'$'
M_C58:		DB " : codigo = 58", RETURN,'$'
M_C59:		DB " ; codigo = 59", RETURN,'$'

M_C60:		DB " < codigo = 60", RETURN,'$'
M_C61:		DB " = codigo = 61", RETURN,'$'
M_C62:		DB " > codigo = 62", RETURN,'$'
M_C63:		DB " ? codigo = 63", RETURN,'$'
M_C64:		DB " @ codigo =  64", RETURN,'$'
M_C65:		DB " A codigo = 65", RETURN,'$'
M_C66:		DB " B codigo = 66", RETURN,'$'
M_C67:		DB " C codigo = 67", RETURN,'$'
M_C68:		DB " D codigo = 68", RETURN,'$'
M_C69:		DB " E codigo = 69", RETURN,'$'

M_C70:		DB " F codigo = 70", RETURN,'$'
M_C71:		DB " G codigo = 71", RETURN,'$'
M_C72:		DB " H codigo = 72", RETURN,'$'
M_C73:		DB " I codigo = 73", RETURN,'$'
M_C74:		DB " J codigo = 74", RETURN,'$'
M_C75:		DB " K codigo = 75", RETURN,'$'
M_C76:		DB " L codigo = 76", RETURN,'$'
M_C77:		DB " M codigo = 77", RETURN,'$'
M_C78:		DB " N codigo = 78", RETURN,'$'
M_C79:		DB " O codigo = 79", RETURN,'$'


M_C80:		DB " P codigo = 80", RETURN,'$'
M_C81:		DB " Q codigo = 81", RETURN,'$'
M_C82:		DB " R codigo = 82", RETURN,'$'
M_C83:		DB " S codigo = 83", RETURN,'$'
M_C84:		DB " T codigo = 84", RETURN,'$'
M_C85:		DB " U codigo = 85", RETURN,'$'
M_C86:		DB " V codigo = 86", RETURN,'$'
M_C87:		DB " W codigo = 87", RETURN,'$'
M_C88:		DB " X codigo = 88", RETURN,'$'
M_C89:		DB " Y codigo = 89", RETURN,'$'

M_C90:		DB " Z codigo = 90", RETURN,'$'
M_C91:		DB " [ codigo = 91", RETURN,'$'
M_C92:		DB " \ codigo = 92", RETURN,'$'
M_C93:		DB " ] codigo = 93", RETURN,'$'
M_C94:		DB " ^ codigo = 94", RETURN,'$'
M_C95:		DB " _ codigo = 95", RETURN,'$'
M_C96:		DB " `codigo= 96", RETURN,'$'
M_C97:		DB " a codigo = 97", RETURN,'$'
M_C98:		DB " b codigo = 98", RETURN,'$'
M_C99:		DB " c codigo = 99", RETURN,'$'

M_C100:		DB " d codigo = 100", RETURN,'$'
M_C101:		DB " e codigo = 101", RETURN,'$'
M_C102:		DB " f codigo = 102", RETURN,'$'
M_C103:		DB " g codigo = 103", RETURN,'$'
M_C104:		DB " h codigo = 104", RETURN,'$'
M_C105:		DB " i codigo = 105", RETURN,'$'
M_C106:		DB " j codigo = 106", RETURN,'$'
M_C107:		DB " k codigo = 107", RETURN,'$'
M_C108:		DB " l codigo = 108", RETURN,'$'
M_C109:		DB " m codigo = 109", RETURN,'$'

M_C110:		DB " n codigo = 110", RETURN,'$'
M_C111:		DB " o codigo = 111", RETURN,'$'
M_C112:		DB " p codigo = 112", RETURN,'$'
M_C113:		DB " q codigo = 113", RETURN,'$'
M_C114:		DB " r codigo = 114", RETURN,'$'
M_C115:		DB " s codigo = 115", RETURN,'$'
M_C116:		DB " t codigo =  116", RETURN,'$'
M_C117:		DB " u codigo =  117", RETURN,'$'
M_C118:		DB " v codigo =  118", RETURN,'$'
M_C119:		DB " w codigo =  119", RETURN,'$'

M_C120:		DB " x codigo =  120", RETURN,'$'
M_C121:		DB " y codigo =  121", RETURN,'$'
M_C122:		DB " y codigo =  122", RETURN,'$'
M_C123:		DB " 123", RETURN,'$'
M_C124:		DB " 124", RETURN,'$'
M_C125:		DB " 125", RETURN,'$'
M_C126:		DB " 126", RETURN,'$'
M_C127:		DB " 127", RETURN,'$'
M_C128:		DB " 128", RETURN,'$'
M_C129:		DB " 129", RETURN,'$'

M_C130:		DB " 130", RETURN,'$'
M_C131:		DB " 131", RETURN,'$'
M_C132:		DB " 132", RETURN,'$'
M_C133:		DB " 133", RETURN,'$'
M_C134:		DB " 134", RETURN,'$'
M_C135:		DB " 135", RETURN,'$'
M_C136:		DB " 136", RETURN,'$'
M_C137:		DB " 137", RETURN,'$'
M_C138:		DB " 138", RETURN,'$'
M_C139:		DB " 139", RETURN,'$'

M_C140:		DB " 140", RETURN,'$'
M_C141:		DB " 141", RETURN,'$'
M_C142:		DB " 142", RETURN,'$'
M_C143:		DB " 143", RETURN,'$'
M_C144:		DB " 144", RETURN,'$'
M_C145:		DB " 145", RETURN,'$'
M_C146:		DB " 146", RETURN,'$'
M_C147:		DB " 147", RETURN,'$'
M_C148:		DB " 148", RETURN,'$'
M_C149:		DB " 149", RETURN,'$'


M_C150:		DB " 150", RETURN,'$'
M_C151:		DB " 151", RETURN,'$'
M_C152:		DB " 152", RETURN,'$'
M_C153:		DB " 153", RETURN,'$'
M_C154:		DB " 154", RETURN,'$'
M_C155:		DB " 155", RETURN,'$'
M_C156:		DB " 156", RETURN,'$'
M_C157:		DB " 157", RETURN,'$'
M_C158:		DB " 158", RETURN,'$'
M_C159:		DB " 159", RETURN,'$'

M_C160:		DB " 160", RETURN,'$'
M_C161:		DB " 161", RETURN,'$'
M_C162:		DB " 162", RETURN,'$'
M_C163:		DB " 163", RETURN,'$'
M_C164:		DB " 164", RETURN,'$'
M_C165:		DB " 165", RETURN,'$'
M_C166:		DB " 166", RETURN,'$'
M_C167:		DB " 167", RETURN,'$'
M_C168:		DB " 168", RETURN,'$'
M_C169:		DB " 169", RETURN,'$'

M_C170:		DB " 170", RETURN,'$'
M_C171:		DB " 171", RETURN,'$'
M_C172:		DB " 172", RETURN,'$'
M_C173:		DB " 173", RETURN,'$'
M_C174:		DB " 174", RETURN,'$'
M_C175:		DB " 175", RETURN,'$'
M_C176:		DB " 176", RETURN,'$'
M_C177:		DB " 177", RETURN,'$'
M_C178:		DB " 178", RETURN,'$'
M_C179:		DB " 179", RETURN,'$'

M_C180:		DB " 180", RETURN,'$'
M_C181:		DB " 181", RETURN,'$'
M_C182:		DB " 182", RETURN,'$'
M_C183:		DB " 183", RETURN,'$'
M_C184:		DB " 184", RETURN,'$'
M_C185:		DB " 185", RETURN,'$'
M_C186:		DB " 186", RETURN,'$'
M_C187:		DB " 187", RETURN,'$'
M_C188:		DB " 188", RETURN,'$'
M_C189:		DB " 189", RETURN,'$'

M_C190:		DB " 190", RETURN,'$'
M_C191:		DB " 191", RETURN,'$'
M_C192:		DB " 192", RETURN,'$'
M_C193:		DB " 193", RETURN,'$'
M_C194:		DB " 194", RETURN,'$'
M_C195:		DB " 195", RETURN,'$'
M_C196:		DB " 196", RETURN,'$'
M_C197:		DB " 197", RETURN,'$'
M_C198:		DB " 198", RETURN,'$'
M_C199:		DB " 199", RETURN,'$'

M_C200:		DB " 200", RETURN,'$'
M_C201:		DB " 201", RETURN,'$'
M_C202:		DB " 202", RETURN,'$'
M_C203:		DB " 203", RETURN,'$'
M_C204:		DB " 204", RETURN,'$'
M_C205:		DB " 205", RETURN,'$'
M_C206:		DB " 206", RETURN,'$'
M_C207:		DB " 207", RETURN,'$'
M_C208:		DB " 208", RETURN,'$'
M_C209:		DB " 209", RETURN,'$'

M_C210:		DB " 210", RETURN,'$'
M_C211:		DB " 211", RETURN,'$'
M_C212:		DB " 212", RETURN,'$'
M_C213:		DB " 213", RETURN,'$'
M_C214:		DB " 214", RETURN,'$'
M_C215:		DB " 215", RETURN,'$'
M_C216:		DB " 216", RETURN,'$'
M_C217:		DB " 217", RETURN,'$'
M_C218:		DB " 218", RETURN,'$'
M_C219:		DB " 219", RETURN,'$'

M_C220:		DB " 220", RETURN,'$'
M_C221:		DB " 221", RETURN,'$'
M_C222:		DB " 222", RETURN,'$'
M_C223:		DB " 223", RETURN,'$'
M_C224:		DB " 224", RETURN,'$'
M_C225:		DB " 225", RETURN,'$'
M_C226:		DB " 226", RETURN,'$'
M_C227:		DB " 227", RETURN,'$'
M_C228:		DB " 228", RETURN,'$'
M_C229:		DB " 229", RETURN,'$'

M_C230:		DB " 230", RETURN,'$'
M_C231:		DB " 231", RETURN,'$'
M_C232:		DB " 232", RETURN,'$'
M_C233:		DB " 233", RETURN,'$'
M_C234:		DB " 234", RETURN,'$'
M_C235:		DB " 235", RETURN,'$'
M_C236:		DB " 236", RETURN,'$'
M_C237:		DB " 237", RETURN,'$'
M_C238:		DB " 238", RETURN,'$'
M_C239:		DB " 239", RETURN,'$'

M_C240:		DB " 240", RETURN,'$'
M_C241:		DB " 241", RETURN,'$'
M_C242:		DB " 242", RETURN,'$'
M_C243:		DB " 243", RETURN,'$'
M_C244:		DB " 244", RETURN,'$'
M_C245:		DB " 245", RETURN,'$'
M_C246:		DB " 246", RETURN,'$'
M_C247:		DB " 247", RETURN,'$'
M_C248:		DB " 248", RETURN,'$'
M_C249:		DB " 249", RETURN,'$'

M_C250:		DB " 250", RETURN,'$'
M_C251:		DB " 251", RETURN,'$'
M_C252:		DB " 252", RETURN,'$'
M_C253:		DB " 253", RETURN,'$'
M_C254:		DB " 254", RETURN,'$'
M_C255:		DB " 255", RETURN,'$'


;                               *
;********************************


;************************************
; DELAY                             *
;    Subrotina para gerar atrasos.  *
;************************************
DELAY:		PUSH	PSW
		PUSH	H
		LXI	H,200

LOOP_DELAY:	DCX	H
		MOV	A,H
		ORA	L
		JNZ	LOOP_DELAY

		POP	H
		POP	PSW
		RET
;                               *
;********************************


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

;**********************************
; Cadeias de caracteres em ROM.   *
;**********************************

RETURN          EQU     0DH
LINEFEED	EQU	0AH

MENSAGEM:
                DB      "Digite um simbolo pertencente a",RETURN
		DB	"{A, B,...,Z,[,\,^,_,`,]a,b,...,z}.",RETURN,"$"

MENSAGEM_INVALIDA:
		DB	"Simbolo fora do conjunto.",RETURN,'$'

;                               *
;********************************


;       Final do segmento "CODIGO"                                   **
;                                                                    **
;**********************************************************************
;**********************************************************************

        END	INICIO

