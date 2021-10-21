/*****************************************************
*****************************************************
**   lab7.c
**
**   Target uC: Atmel ATmega2560
**   X-TAL frequency: 16 MHz
**
**   Description:
**		Implements a controller of 3 servos by
**		using USART as input and master/slave logic. 
**
**   By: Alvaro Tedeschi Neto 21/10/2021
*****************************************************
*****************************************************/

#include <avr/io.h>
#include <avr/interrupt.h>
#include <stdio.h>
#include <string.h>
#include "commit.h"

// Constants
#define BAUDRATE 57600
#define UBRRVALUE 16
#define CONST_ICR1 40000
#define INITIAL_ANGLE 3000

// Functions definitions
int USART0SendByte(char u8Data, FILE *stream);
int USART0ReceiveByte(FILE *stream);
void USART0Init(void);

int USART1SendByte(char u8Data, FILE *stream);
int USART1ReceiveByte(FILE *stream);
void USART1Init(void);

void ServosInit();
void PWMInitMode14();

int validateRequest(char *request);
void setServo(char *request);
void setLed(char *request);

// USART streams
FILE usart0_str = FDEV_SETUP_STREAM(USART0SendByte, USART0ReceiveByte, _FDEV_SETUP_RW);
FILE usart1_str = FDEV_SETUP_STREAM(USART1SendByte, USART1ReceiveByte, _FDEV_SETUP_RW);

int main(void)
{
	DDRB |= (1<<DDB5) | (1<<DDB6) | (1<<DDB7); // Sets PB5, PB6 and PB7 as outputs
	DDRF |= (1<<DDF0); // Sets PF0 as output
	DDRH |= (1<<DDH0) | (1<<DDH1); // Sets PH0 and PH1 as outputs
	DDRL |= (0<<DDL7); // Sets PL7 as input
	
	int isMaster = (PINL & (1 << PINL7)) >> PINL7; // Reads if master or slave

	PORTF |= (isMaster<<PF0); // Sets PF0 LED to indicate if master or slave

	// Unitializes USARTs
	USART0Init();
	USART1Init();

	char request[10];
	char response[10];
	
	if (isMaster) {
		fprintf(&usart0_str, "%s", hash);
		fprintf(&usart0_str, " ***MASTER***\n");
		while(1)
		{
			// Prints request prompt to USART0
			fprintf(&usart0_str,"\nREQUEST: ");
			// Gets request from USART0 and prints to USART0
			for (int i = 0; i < 5; ++i) {
				fscanf(&usart0_str, "%c", &request[i]);
				fprintf(&usart0_str, "%c", request[i]);
			}
			request[5] = '\n';
			// Sends request to USART1
			fprintf(&usart1_str, "%s", request);
			// Prints response prompt to USART0
			fprintf(&usart0_str, "\nRESPONSE: ");
			// Gets response from USART1 and prints to USART0
			fscanf(&usart1_str, "%s", response);
			fprintf(&usart0_str, "%s", response);
			fprintf(&usart0_str, "\n");
		}
	} else {
		// Initializes timer and servos
		PWMInitMode14();
		ServosInit();
		
		fprintf(&usart0_str, "%s", hash);
		fprintf(&usart0_str, " ***SLAVE***\n");
		while(1)
		{
			// Prints request prompt
			fprintf(&usart0_str,"\nREQUEST: ");
			// Gets request from USART1 and prints to USART0
			fscanf(&usart1_str, "%s", request);
			fprintf(&usart0_str, "%s", request);
			
			if (validateRequest(request)) {
				// Executes command on servo or led
				if (request[0] == 'S') { setServo(request); }
				else { setLed(request); }
				
				strcpy(response, "ACK\n");
			} else {
				strcpy(response, "INVALID\n");
			}
			fprintf(&usart0_str, "%s%s", " ", response);
			// Sends response to USART1
			fprintf(&usart1_str, "%s", response);
		}
	}
	
}

// Validates incoming request and returns 1 if valid or 0 if not valid
int validateRequest(char *request) {
	if (request[0] == 'S') {
		int servoNumber = request[1] - '0';
		if (!(servoNumber >= 0 && servoNumber <= 2)) { return 0; }
			
		char angleSign = request[2];
		if (angleSign != '-' && angleSign != '+') { return 0; }
			
		int angle = 10 * (request[3] - '0') + request[4] - '0';
		if (!(angle >= 0 && angle <= 90)) { return 0; }
		
	}
	else if (request[0] == 'L') {
		int ledNumber = request[1] - '0';
		if (!(ledNumber == 0 || ledNumber == 1)) { return 0; }
			
		char command[4] = {request[2], request[3], request[4], '\0'};
		if (strcmp(command, "ONN") != 0 && strcmp(command, "OFF") != 0) { return 0; }
	}
	else { return 0; }
	return 1;
}

// Sets servo based on the incoming request
void setServo(char *request) {
	int servoNumber = request[1] - '0';
	char angleSign = request[2];
	int angle = 10 * (request[3] - '0') + request[4] - '0'; 
	
	angle = angleSign == '+' ? angle : -angle;
	
	int servoCommand = INITIAL_ANGLE + 100.0/9.0 * angle;
	
	switch (servoNumber)
	{
		case 0:
		OCR1AH = servoCommand >> 8;
		OCR1AL = servoCommand & 0xFF;
		break;
		case 1:
		OCR1BH = servoCommand >> 8;
		OCR1BL = servoCommand & 0xFF;
		break;
		case 2:
		OCR1CH = servoCommand >> 8;
		OCR1CL = servoCommand & 0xFF;
		break;
	}
}

// Sets led based on the incoming request
void setLed(char *request) {
	int ledNumber = request[1] - '0';
	char command[4] = {request[2], request[3], request[4], '\0'};
	int action = !strcmp(command, "ONN");
	
	if (action) {
		if (ledNumber == 0) {
			PORTH |= (1<<PH0);
		}
		else {
			PORTH |= (1<<PH1);
		}
	} else {
		if (ledNumber == 0) {
			PORTH &= ~(1<<PH0);
		}
		else {
			PORTH &= ~(1<<PH1);
		}
	}
	
	
}

// Initializes servos
void ServosInit() {
	OCR1AH = INITIAL_ANGLE >> 8;
	OCR1AL = INITIAL_ANGLE & 0xFF;
	OCR1BH = INITIAL_ANGLE >> 8;
	OCR1BL = INITIAL_ANGLE & 0xFF;
	OCR1CH = INITIAL_ANGLE >> 8;
	OCR1CL = INITIAL_ANGLE & 0xFF;
}

// Sets MODE14 to TIMER with ICR1 = 40000, TOP = 20ms    
void PWMInitMode14() {
	// Mode 14, Fast PWM: (WGM13, WGM12, WGM11, WGM10)=(1,1,1,0)
	// Clear OC1X on compare match: (COM1X1, COM1X0)=(1,0)
	TCCR1A = (1<<COM1A1) | (0<<COM1A0) | (1<<COM1B1) | (0<<COM1B0) | (1<<COM1C1) | (0<<COM1C0) | (1<<WGM11) | (0<<WGM10);

	// Mode 14, Fast PWM: (WGM13, WGM12, WGM11, WGM10)=(1,1,1,0)
	// Clock select: (CS12, CS11, CS10)=(0,1,0), PRESCALER/8
	// No input capture: (ICNC1, ICES1)=(0,0)
	TCCR1B = (0<<ICNC1) | (0<<ICES1) | (1<<WGM13) | (1<<WGM12) | (0<<CS12) | (1<<CS11) | (0<<CS10);
	
	// TOP = 40000
	ICR1H = CONST_ICR1 >> 8;
	ICR1L = CONST_ICR1 & 0xff;
}

/**********************
	USART FUNCTIONS
***********************/

void USART0Init(void)
{
    // Sets 57600 bps, 1 stop bit, no parity bit. 
	UCSR0A = (0<<RXC0) | (0<<TXC0) | (0<<UDRE0) | (0<<FE0) | (0<<DOR0) | (0<<UPE0) | (0<<U2X0) | (0<<MPCM0);
    UCSR0B = (0<<RXCIE0) | (0<<TXCIE0) | (0<<UDRIE0) | (1<<RXEN0) | (1<<TXEN0) | (0<<UCSZ02) | (0<<RXB80) | (0<<TXB80);
    UCSR0C = (0<<UMSEL01) | (0<<UMSEL00) | (0<<UPM01) | (0<<UPM00) | (0<<USBS0) | (1<<UCSZ01) | (1<<UCSZ00) | (0<<UCPOL0);
    UBRR0H = UBRRVALUE >> 8;
    UBRR0L = UBRRVALUE & 0xFF;
}

int USART0SendByte(char u8Data, FILE *stream)
{
	if (u8Data == '\n') {
		USART0SendByte('\r', stream);
	}
	// Waits for previous byte
	while(!(UCSR0A&(1<<UDRE0)));
	// Transmits data
	UDR0 = u8Data;
	return 0;
}

int USART0ReceiveByte(FILE *stream)
{
	uint8_t u8Data;
	// Waits for byte
	while (!(UCSR0A&(1<<RXC0)));
	u8Data = UDR0;
	// Returns data
	return u8Data;
}     


void USART1Init(void)
{
	// Sets 57600 bps, 1 stop bit, no parity bit.  
	UCSR1A = (0<<RXC1) | (0<<TXC1) | (0<<UDRE1) | (0<<FE1) | (0<<DOR1) | (0<<UPE1) | (0<<U2X1) | (0<<MPCM1);
    UCSR1B = (0<<RXCIE1) | (0<<TXCIE1) | (0<<UDRIE1) | (1<<RXEN1) | (1<<TXEN1) | (0<<UCSZ12) | (0<<RXB81) | (0<<TXB81);
    UCSR1C = (0<<UMSEL11) |(0<<UMSEL10) | (0<<UPM11) | (0<<UPM10) | (0<<USBS1) | (1<<UCSZ11) | (1<<UCSZ10) | (0<<UCPOL1);
    UBRR1H = UBRRVALUE >> 8;
    UBRR1L = UBRRVALUE & 0xFF;
}

int USART1SendByte(char u8Data, FILE *stream)
{
	if (u8Data == '\n') {
		USART1SendByte('\r',stream);
	}
	// Waits for previous byte
	while (!(UCSR1A&(1<<UDRE1)));
	// Transmits data
	UDR1 = u8Data;
	return 0;
}

int USART1ReceiveByte(FILE *stream)
{
	uint8_t u8Data;
	// Waits for byte
	while (!(UCSR1A&(1<<RXC1)));
	u8Data = UDR1;
	// Returns data
	return u8Data;
}                             

