;*****************************************************
;*****************************************************
;**   lab3.asm
;**
;**   Target uC: Atmel ATmega2560
;**   X-TAL frequency: 16 MHz
;**
;**   Description:
;**		Implements a controller of 3 servos by
;**		using USART as input and interruption source.	
;**
;**   Details:	
;**	    Uses approximation of 100/9 ~ 11 + 1/8
;**	
;**   By: Alvaro Tedeschi Neto 23/09/2021
;*****************************************************
;*****************************************************

;***********
; Constants  
;***********

	.EQU BAUD_RATE = 103               ; Baud rate constants (2400:416, 9600:103, 57600:16, 115200:8)
	.EQU RETURN = 0x0A                 ; Cursor return
	.EQU LINEFEED = 0x0D               ; New line
	.EQU USART1_RXC1_vect = 0x0048     ; Interrupt vector for RXC1
	.EQU CONST_ICR1 = 40000            ; ICR1 constant for TIMER
	.EQU INITIAL_ANGLE = 3000          ; Initial angle
   
;**************
; Code (FLASH)               
;**************
	.CSEG

; Reset entry point
	.ORG 0 
	JMP RESET

;**********************************
; USART1 interruptions entry point
;**********************************
	.ORG USART1_RXC1_vect

VETOR_USART1RX:
	JMP USART1_RX1_INTERRUPT

	.ORG 0x100

RESET:
	; Initializes Stack pointer
	LDI R16, LOW(RAMEND) 
	OUT SPL, R16         
	LDI R16, HIGH(RAMEND)
	OUT SPH, R16

	CALL PWM_INIT_MODE14    ; Initializes PWM Mode 14
	CALL INIT_PORTS         ; Initializes ports
	CALL INIT_SERVOS        ; Initializes servos
	CALL USART1_INIT        ; Initializes USART1
	CALL RESET_INPUT_STATE
	SEI                     ; Enables interruptions

;************
;* MAIN_LOOP
;************

MAIN_LOOP:
	LDI ZH, HIGH(2*PROMPT)   
	LDI ZL, LOW(2*PROMPT)
	CALL PRINT_USART1       ; Prints prompt to USART1

	CALL GET_INPUT          ; Calls get input loop

	LDI ZH, HIGH(2*NEWLINE)   
	LDI ZL, LOW(2*NEWLINE)
	CALL PRINT_USART1       ; Prints newline to USART1

	JMP MAIN_LOOP

;******************************************
;* GET_INPUT
;* Input loops until full input is entered
;******************************************

GET_INPUT:
	CPI R17, 5
	BREQ RESET_STATE    ; Branches and resets state if state is 5
	JMP GET_INPUT
	RESET_STATE:
		CALL RESET_INPUT_STATE
		RET

;**************************************************************
;* SET_SERVO
;* Calculates and sets the corresponding values read on USART1
;**************************************************************
SET_SERVO:
	; R23:R22 = INITIAL_ANGLE
	LDI R23, HIGH(INITIAL_ANGLE)
	LDI R22, LOW(INITIAL_ANGLE)
	; R1:R0 = 11 * ANGLE
	LDI R24, 11
	MUL R21, R24
	; R21 = ANGLE / 8
	LSR R21
	LSR R21
	LSR R21
	; Branches to corresponding operation
	CPI R20, '+'
	BREQ POS_ANGLE
	CPI R20, '-'
	BREQ NEG_ANGLE
	; R23:R22 = INITIAL_ANGLE + 11 * ANGLE + ANGLE / 8
	POS_ANGLE:
	ADD R22, R0
	ADC R23, R1
	ADD R22, R21
	JMP END_SIGN
	; R23:R22 = INITIAL_ANGLE - 11 * ANGLE - ANGLE / 8
	NEG_ANGLE:
	SUB R22, R0
	SBC R23, R1
	SUB R22, R21

	END_SIGN:
	; Branches to corresponding servo output
	CPI R19, '0'
	BREQ SET_SERVOA
	CPI R19, '1'
	BREQ SET_SERVOB
	CPI R19, '2'
	BREQ SET_SERVOC

	; Sets servos outputs
	SET_SERVOA:
	STS OCR1AH, R23
	STS OCR1AL, R22
	JMP END_SET_SERVO

	SET_SERVOB:
	STS OCR1BH, R23
	STS OCR1BL, R22
	JMP END_SET_SERVO

	SET_SERVOC:
	STS OCR1CH, R23
	STS OCR1CL, R22

	END_SET_SERVO:

	RET

;***********************
;* INTERRUPT DRIVER
;* USART1_RX1_INTERRUPT
;***********************

USART1_RX1_INTERRUPT:
   PUSH  R16

   LDS   R16, UDR1           ; R16 <- CHAR received.
   STS   CHAR, R16

   CALL  USART1_TRANSMIT     ; Prints CHAR to USART1

   ; Branches to corresponding state logic
   CPI R17, 0
   BREQ STATE_0
   CPI R17, 1
   BREQ STATE_1
   CPI R17, 2
   BREQ STATE_2
   CPI R17, 3
   BREQ STATE_3
   CPI R17, 4
   BREQ STATE_4
   ; State corresponding to input {S}
   STATE_0:
	   MOV R19, R16          ; Copies USART1's input R16 to R19
	   JMP END_STATE_CHECK
   ; State corresponding to servo number input {0, 1, 2}
   STATE_1:
	   MOV R19, R16          ; Copies USART1's input R16 to R19
	   JMP END_STATE_CHECK
   ; State corresponding to angle sign {-, +}
   STATE_2:
	   MOV R20, R16          ; Copies USART1's input R16 to R20
	   JMP END_STATE_CHECK
   ; State corresponding to first angle digit input {0, ..., 9}
   STATE_3:
	   SUBI R16, '0'         ; Transforms input from ascii to binary
	   MOV R21, R16          ; Copies R16 to R21
	   LDI R24, 10
	   MUL R21, R24          ; R1:R0 = R21 * 10
	   MOV R21, R0           ; R21 * 10 <= 90 (max 7 bits)
	   JMP END_STATE_CHECK
   ; State corresponding to second angle digit input {0, ..., 9}
   STATE_4:
	   SUBI R16, '0'         ; Transforms input from ascii to binary
	   ADD R21, R16          ; Finishes calculating angle in binary
	   CALL SET_SERVO

   END_STATE_CHECK:

   INC R17                   ; Increments state
   POP R16

   RETI

;*****************************************
; INIT_PORTS                      
; Initializes PB5, PB6 and PB7 as outputs                 
;*****************************************
INIT_PORTS:
	LDI R16, 0b11100000        
	OUT DDRB, R16
	RET

;*********************************
; INIT_SERVOS                     
; Initializes servos to 0 degrees        
;*********************************
INIT_SERVOS:
	LDI R16, HIGH(INITIAL_ANGLE)
	STS OCR1AH, R16
	STS OCR1BH, R16
	STS OCR1CH, R16
	LDI R16, LOW(INITIAL_ANGLE)
	STS OCR1AL, R16
	STS OCR1BL, R16
	STS OCR1CL, R16
	RET

;*******************************
; RESET_INPUT_STATE                     
; Resets input state to state 0   
;*******************************
RESET_INPUT_STATE:
	LDI R17, 0
	RET

;****************************************************
; PWM_INIT_MODE14                
; Sets MODE14 to TIMER with ICR1 = 40000, TOP = 20ms       
;****************************************************
PWM_INIT_MODE14:

	; Mode 14, Fast PWM: (WGM13, WGM12, WGM11, WGM10)=(1,1,1,0)
	; Clear OC1X on compare match: (COM1X1, COM1X0)=(1,0)
	LDI R16, (1<<COM1A1) | (0<<COM1A0) | (1<<COM1B1) | (0<<COM1B0) | (1<<COM1C1) | (0<<COM1C0) | (1<<WGM11) | (0<<WGM10)
	STS TCCR1A, R16

	; Mode 14, Fast PWM: (WGM13, WGM12, WGM11, WGM10)=(1,1,1,0)
	; Clock select: (CS12, CS11, CS10)=(0,1,0), PRESCALER/8
	; No input capture: (ICNC1, ICES1)=(0,0)
	LDI R16, (0<<ICNC1) | (0<<ICES1) | (1<<WGM13) | (1<<WGM12) | (0<<CS12) | (1<<CS11) | (0<<CS10)
	STS TCCR1B, R16

	; TOP = 40000
	LDI R16, CONST_ICR1 >> 8
	STS ICR1H, R16
	LDI R16, CONST_ICR1 & 0xff
	STS ICR1L, R16

	RET

;********************
; USART1_INIT                          
; Initializes USART1  
;********************
; Sets async mode, 9600 bps, 1 stop bit, no parity bit.  
; Registries:
;     - UBRR1 (USART1 Baud Rate Register)
;     - UCSR1 (USART1 Control Status Register B)
;     - UCSR1 (USART1 Control Status Register C)
USART1_INIT:
	LDI R17, HIGH(BAUD_RATE)
	STS UBRR1H, R17
	LDI R16, LOW(BAUD_RATE)
	STS UBRR1L, R16


;********************************************************************************
; ICSRB1 initialized with enabled RXCIE1 interruptions (input CHAR interruption)
;********************************************************************************
	LDI R16, (1<<RXCIE1) | (1<<RXEN1) | (1<<TXEN1)   ; Interruptions of receiver and transmitter

	STS UCSR1B,R16
	LDI R16, (0<<USBS1) | (1<<UCSZ11) | (1<<UCSZ10)  ; Frame: 8 bits, 1 stop bit, no parity bit
	STS UCSR1C, R16 

	RET

;*************************
; USART1_TRANSMIT                   
; Transmits R16 to USART1
;*************************

USART1_TRANSMIT:
	PUSH R17               

WAIT_TRANSMIT1:
	LDS R17, UCSR1A
	SBRS R17, UDRE1             ; Waits for empty buffer 
	RJMP WAIT_TRANSMIT1
	STS UDR1, R16               ; Writes to buffer

	POP R17                   
	RET

;*****************************************************
; PRINT_USART1                                   
; Prints the message pointed by Z in CODSEG to USART1                       
; CHAR '$' signals end of message.  
;*****************************************************
PRINT_USART1:
	PUSH R16
	LDS R16, SREG
	PUSH R16
	PUSH R17
	PUSH ZH
	PUSH ZL

PRINT_USART1_REP:
	LPM R16, Z+
	CPI R16, '$'
	BREQ END_PRINT_USART1
	CALL USART1_TRANSMIT
	JMP PRINT_USART1_REP

END_PRINT_USART1:
	POP ZL
	POP ZH
	POP R17
	POP R16
	STS SREG, R16
	POP R16
	RET

;******************************
; Strings to be used in USART1
;******************************
PROMPT:
	.DB "Servo control (SXsAA format): ", '$'
NEWLINE:
	.DB RETURN, LINEFEED, '$'

;************
; Data (RAM)           
;************
   .DSEG
   .ORG 0x200
CHAR:
   .BYTE 1

;*****
; End
;*****
   .EXIT
