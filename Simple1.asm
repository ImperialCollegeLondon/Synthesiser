	#include p18f87k22.inc

	extern	UART_Setup, UART_Receive_Message   ; external UART subroutines

acs0	udata_acs   ; reserve data space in access ram

tables  udata	0x400    ; reserve data anywhere in RAM (here at 0x400)
myArray res 0x80    ; reserve 128 bytes for message data

	
rst	code	0    ; reset vector
	goto	setup

main	code
	; ******* Programme FLASH read Setup Code ***********************
setup	bcf	EECON1, CFGS	; point to Flash program memory  
	bsf	EECON1, EEPGD 	; access Flash program memory
	call	UART_Setup	; setup UART
	goto    start
	; ******* Main programme ****************************************
	



start	nop
	
	lfsr	FSR2, myArray

loop

	movlw	.3
	call	UART_Receive_Message
	goto	loop
	   
	
	end
