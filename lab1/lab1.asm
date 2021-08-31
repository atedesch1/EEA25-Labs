;******************************************************************************
;******************************************************************************
;**   lab1.asm
;**
;**   Target uC: Atmel ATmega328P
;**   X-TAL frequency: 16 MHz
;**
;**   Description:
;**
;**   Implements a 4 bit counter controlled by:
;**       1. A terminal which determines if counter should increment or
;**          decrement its value.
;**       2. A switch which is used to operate the counter on the
;**          desired counter mode.
;**   
;**   Logic behind code:
;**       1. Code has an outer and an inner loop.
;**       2. Outer loop is responsible for calling the inner loop and
;**          printing to terminal after it gets input.
;**       3. Inner loop is resposible for checking the switch and the
;**          terminal for user input respectively. If the switch is pressed
;**          the code goes into updating the counter subroutines. If terminal
;**          receives input the code goes into the printing subsection of the
;**          outer loop mentioned before.
;**
;**   By: Alvaro Tedeschi Neto 30/08/2021
;******************************************************************************
;******************************************************************************


; Baud rate constant
.EQU BAUD_RATE_57600 = 16
; Counter constants
.EQU COUNTER_UNIT = 0b00000100
                        
.CSEG            
.ORG 0    

JMP RESET

RESET:
    LDI	R16, LOW(0x8ff)
	OUT	SPL, R16
	LDI	R16, HIGH(0x8ff)
	OUT	SPH, R16
	CALL USART_INIT

    LDI R19, 0b00111100
    OUT DDRD, R19
    LDI R20, 0b00000000
    OUT PORTD, R20

READY_SWITCH:
    IN R19, PIND
    ANDI R19, 0b10000000
    BREQ READY_SWITCH    ; Branches until PD7 is 0

CALL PRINT_PROMPT
CALL PRINT_NEWLINE

MAIN_LOOP:
    CALL INPUT_LOOP
    GOT_TERMINAL_INPUT:    ; Is reached when USART receives input, else loops INPUT_LOOP
        CALL PRINT_RESULT
        CALL PRINT_NEWLINE
    RJMP MAIN_LOOP    ; Loops forever

INPUT_LOOP:
    CALL CHECK_SWITCH
    CALL CHECK_TERMINAL
    RJMP INPUT_LOOP    ; Loops until USART receives input

;*********************************************************************
; Input Subroutines
; Checks USART and writes input to a register (USART_RECEIVE
; modification by removing waiting for input), checks for switch press
; and calls UPDATE_COUNTER and waits for switch release respectively.
;*********************************************************************
CHECK_TERMINAL:
    LDS	R17, UCSR0A
	SBRS R17, RXC0
	RET    ; Returns if there is no input
	LDS R16, UDR0   ; Writes input to register
	JMP GOT_TERMINAL_INPUT

CHECK_SWITCH:
    IN R19, PIND                        
    ANDI R19, 0b10000000
    BRNE END_CHECK_SWITCH   ; Branches if PD7 is 0
    CHANGE_COUNTER:
        CALL UPDATE_COUNTER
        CALL WAIT_SWITCH_RELEASE
    END_CHECK_SWITCH:
        RET
             
WAIT_SWITCH_RELEASE:
    IN R19, PIND
    ANDI R19, 0b10000000
    BREQ WAIT_SWITCH_RELEASE   ; Branches until PD7 is 1
    RET

;*********************************************************************
; PRINT Subroutines
; Prints the prompt, the result after the user inputs counter mode
; and a new line respectively.
;*********************************************************************
PRINT_PROMPT:
    LDI	ZH, HIGH(2*PROMPT)
	LDI	ZL, LOW(2*PROMPT)
	CALL SEND
    RET

PRINT_RESULT:
    CPI R16, 'd'
    BREQ RESULT_DECREMENT   ; Branches if USART input is 'd'
    RESULT_INCREMENT:
        LDI	ZH, HIGH(2*RES_INC)
        LDI	ZL, LOW(2*RES_INC)
        JMP END_RESULT
    RESULT_DECREMENT:
        LDI	ZH, HIGH(2*RES_DEC)
        LDI	ZL, LOW(2*RES_DEC)
    END_RESULT:
        CALL SEND
        CALL PRINT_NEWLINE
        RET

PRINT_NEWLINE:
    LDI	ZH, HIGH(2*CRLF)
	LDI	ZL, LOW(2*CRLF)
	CALL SEND
    RET

;*********************************************************************
; Subroutine: UPDATE_COUNTER
; Updates the counter depending on the value read from USART.
; Input 'd' decrements, any other character increments the counter.
;*********************************************************************
UPDATE_COUNTER: 
    PUSH R21
    CPI R16, 'd'
    BREQ DECREMENT   ; Branches if USART input is 'd'
    INCREMENT:
        LDI R21, COUNTER_UNIT
        ADD R20, R21                  
        OUT PORTD, R20
        JMP END_UPDATE          
    DECREMENT:
        LDI R21, COUNTER_UNIT
        SUB R20, R21                  
        OUT PORTD, R20
    END_UPDATE:
        POP R21             
        RET

;*********************************************************************
; Subroutine USART_INIT  
; Setup for USART: async mode, 57600 bps, 1 stop bit, no parity
; Used registers:
;    - UBRR0 (USART0 Baud Rate Register)
;    - UCSR0 (USART0 Control Status Register B)
;    - UCSR0 (USART0 Control Status Register C)
;*********************************************************************	
USART_INIT:
	LDI	R17, HIGH(BAUD_RATE_57600)    ; sets the baud rate
	STS	UBRR0H, R17
	LDI	R16, LOW(BAUD_RATE_57600)
	STS	UBRR0L, R16
	LDI	R16, (1<<RXEN0)|(1<<TXEN0)    ; enables RX and TX
	STS	UCSR0B, R16
	LDI	R16, (0<<USBS0)|(3<<UCSZ00)    ; frame: 8 data bits, 1 stop bit
	STS	UCSR0C, R16    ; no parity bit
	RET

;*********************************************************************
; Subroutine USART_TRANSMIT  
; Transmits (TX) R16   
;*********************************************************************
USART_TRANSMIT:
    PUSH R17
    WAIT_TRANSMIT:
        LDS	R17, UCSR0A
        SBRS R17, UDRE0    ; waits for TX buffer to get empty
        RJMP WAIT_TRANSMIT
        STS	UDR0, R16    ; writes data into the buffer
        POP	R17
        RET


;*********************************************************************
; Subroutine USART_RECEIVE
; Receives the char from USAR and places it in the register R16 
;*********************************************************************
USART_RECEIVE:
	PUSH R17
    WAIT_RECEIVE:
        LDS	R17, UCSR0A
        SBRS R17, RXC0
        RJMP WAIT_RECEIVE    ; waits for the data incomings
        LDS R16, UDR0    ; reads the data
        POP	R17
        RET


;*********************************************************************
; Subroutine SEND
; Sends a message pointed by register Z in the FLASH memory
;*********************************************************************
SEND:
    PUSH R16
    SEND_REP:
        LPM R16, Z+
        CPI R16, '$'
        BREQ END_SEND
        CALL USART_Transmit
        JMP SEND_REP
    END_SEND:
        POP	R16
        RET

;*********************************************************************
; Messages used as output for USART
;*********************************************************************
PROMPT:
    .DB ":: Press 'i' for increasing the counter", 0x0a, 0x0d, ":: Press 'd' for decreasing the counter", 0x0a, 0x0d, ":: Other characters increase the counter",0x0a, 0x0d, '$'
RES_INC:
    .DB ":: !!Now increasing the counter!!", '$'
RES_DEC:
    .DB ":: !!Now decreasing the counter!!", '$'
CRLF:
	.DB  " ", 0x0a, 0x0d, '$'    ; carriage return & line feed chars

.EXIT