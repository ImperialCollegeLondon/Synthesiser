	#include p18f87k22.inc

	extern	UART_Setup, UART_Transmit_Message   ; external UART subroutines
	extern  LCD_Setup, LCD_Write_Message	    ; external LCD subroutines
	extern	LCD_Write_Hex			    ; external LCD subroutines
	extern  ADC_Setup, ADC_Read		    ; external ADC routines
	extern	multiply816, multiply1616, multiply824
	
acs0	udata_acs   ; reserve data space in access ram
counter	    res 1   ; reserve one byte for a counter variable
delay_count res 1   ; reserve one byte for counter in the delay routine

tables	udata	0x400    ; reserve data anywhere in RAM (here at 0x400)
myArray res 0x80    ; reserve 128 bytes for message data
slope	res 1

rst	code	0    ; reset vector
	goto	setup

pdata	code    ; a section of programme memory for storing data
	; ******* myTable, data in programme memory, and its length *****
myTable data	    "Hello World!\n"	; message, plus carriage return
	constant    myTable_l=.13	; length of data
	
	; ******* My data and where to put it in RAM *
myTable db	0x55,0xAA
	constant myArray=0x400	; Address in RAM for data
		; Address of counter variable
main	code
	; ******* Programme FLASH read Setup Code ***********************
setup	bcf	EECON1, CFGS	; point to Flash program memory  
	bsf	EECON1, EEPGD 	; access Flash program memory
	call	UART_Setup	; setup UART
	call	LCD_Setup	; setup LCD
	call	ADC_Setup	; setup ADC
	call	SPI_MasterInit
	call	Character_Setup
	goto	start
	
	; ******* Main programme ****************************************
start

main_loop
	banksel PADCFG1		; PADCFG1 is not in Access Bank!!
	bsf	PADCFG1, REPU, BANKED	; PortE pull-ups on 
	movlb	0x00		; set BSR back to Bank 0
	clrf	LATE
	call	operations_loop
	call	keypad_read_rows
	movlw	0x0f
	cpfslt	keypadval
	goto	OUTPUT_ZERO	; go to top of loop as no button is pressed
				;THIS NEEDS TO BE CHANGED
	call	keypad_read_columns
	movlw	0xEF		
	cpfslt	keypadval	; go to top of loop as button has been released
				;THIS NEEDS TO BE CHANGED
	goto	OUTPUT_ZERO
	call	get_slope
	
	
	
	
	
	
	call	SPI_MasterTransmit;takes data in through W
	call	delay
	goto	0
	
	
	
	goto	main_loop
	
	
	
	
Character_Setup	    ; save all the slopes at address which is coordinate
	movlw	b'00110001'	; 1 
	movwf	0x77
	movlw	b'00110010'	; 2
	movwf	0xB7
	movlw	b'00110011'	; 3
	movwf	0xD7
	movlw	b'00110100'	; 4
	movwf	0x7B
	movlw	b'00110101'	; 5
	movwf	0xBB
	movlw	b'00110110'	; 6
	movwf	0xDB
	movlw	b'00110111'	; 7
	movwf	0x7D
	movlw	b'00111000'	; 8
	movwf	0xBD
	movlw	b'00111001'	; 9
	movwf	0xDD
	movlw	b'00110000'	; 0
	movwf	0xBE
	movlw	b'01000001'	; A
	movwf	0x7E
	movlw	b'01000010'	; B
	movwf	0xDE
	movlw	b'01000011'	; C
	movwf	0xEE
	movlw	b'01000100'	; D
	movwf	0xED
	movlw	b'01000101'	; E
	movwf	0xEB
	movlw	b'01000110'	; F
	movwf	0xE7
	
SPI_MasterInit	; Set Clock edge to positive
	bcf	SSP2STAT, CKE
	; MSSP enable; CKP=1; SPI master, clock=Fosc/64 (1MHz)
	movlw 	(1<<SSPEN)|(1<<CKP)|(0x02)
	movwf 	SSP2CON1
	; SDO2 output; SCK2 output
	bcf	TRISD, SDO2
	bcf	TRISD, SCK2
	return	
	



SPI_MasterTransmit  ; Start transmission of data (held in W)
	movwf 	SSP2BUF
	call    delay
Wait_Transmit	; Wait for transmission to complete 
	btfss 	PIR2, SSP2IF
	bra 	Wait_Transmit
	bcf 	PIR2, SSP2IF	; clear interrupt flag
	return


operations_loop
	movlw	0x00
	cpfsgt	PORTD, ACCESS
	return	; no input on PORTD
	movlw	0x01
	cpfsgt	PORTD, ACCESS
	goto	Clear_Display
	movlw	0x02
	cpfsgt	PORTD, ACCESS 
	goto	Move_Display
	return
	

	
	
	
keypad_read_rows
	movlw   0x0F
	movwf	TRISE, ACCESS	; PORTE all inputs
	movlw	0xFF		; 256 loop delay 
	movwf	delay_count
	call	delay		; delay for voltage to settle
	movff	PORTE, keypadval; read in rows
	return


keypad_read_columns
	movlw   0xF0
	movwf	TRISE, ACCESS	; PORTE all inputs
	movlw	0xFF
	movwf	delay_count
	call	delay		; delay for voltage to settle
	movf	PORTE, W	; read in columns	
	addwf	keypadval, F	; add to get full coordinates of button
	return
	
	
get_slope
	movff	keypadval, FSR2L
	clrf	FSR2H		;CANT REMEMBER WHY WE DID THIS
	movff   INDF2, slope	;Read contents of address in FSR2 not changing it
	return
	


	
	

	
	
	
	

	
	
	
	
	
	
	
	
	
Clear_Display
	call	LCD_Clear_Display
	return
	;goto	operations_loop

Move_Display
	call	LCD_Clear_Display
	call	LCD_Move_Display
	goto	$		; goto current line in code

	; a delay subroutine if you need one, times around loop in delay_count
delay	decfsz	delay_count	; decrement until zero
	bra delay
	return
	
	
; a delay subroutine

delayy  decfsz  0x30, F, ACCESS
        bra     delay1
        return  
	
delay1  movlw	0xff
	movwf	0x20
	call    delay2, 0
	nop
	

delay2  movwf   0x30, ACCESS
	call    delay3, 0
	nop
	decfsz  0x20, F, ACCESS
        bra     delay2
        return  
	
delay3  decfsz  0x30, F, ACCESS
        bra     delay3
        return  


	end
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	loop 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter		; count down to zero
	bra	loop		; keep going until finished
		
	movlw	myTable_l-1	; output message to LCD (leave out "\n")
	lfsr	FSR2, myArray
	nop
	call	LCD_Write_Message

	movlw	myTable_l	; output message to UART
	lfsr	FSR2, myArray
	nop
	call	UART_Transmit_Message
	
	
	keypad_read_loop
	banksel PADCFG1		; PADCFG1 is not in Access Bank!!
	bsf	PADCFG1, REPU, BANKED	; PortE pull-ups on 
	movlb	0x00		; set BSR back to Bank 0
	clrf	LATE
	call	operations_loop
	call	keypad_read_rows
	movlw	0x0f
	cpfslt	keypadval
	goto	keypad_read_loop; go to top of loop as no button is pressed
	call	keypad_read_columns
	movlw	0xEF		
	cpfslt	keypadval	; go to top of loop as button has been released
	goto	keypad_read_loop
	call	keypad_write_char
	goto	keypad_read_loop
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
	banksel PADCFG1		; PADCFG1 is not in Access Bank!!
	bsf	PADCFG1, REPU, BANKED	; Port E pull-ups on
	movlb	0x00		; set BSR back to Bank 0
	movlw   0x00
	movwf	TRISE, ACCESS	; Port E all outputs enabled
	movwf	TRISD, ACCESS	; Port D all outputs enabled
	movlw	upper(myTable)	; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(myTable)	; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(myTable)	; address of data in PM
	movwf	TBLPTRL		; load low byte to TBLPTRL
	movlw	.1		; half the bytes to read
	movwf 	counter		; our counter register
	
loop 	movlw 	0x01		; WR high		
	movwf	PORTD			
	nop
	tblrd*+			; move one byte, PM to TABLAT, increment TBLPRT
	movff	TABLAT, PORTE   ; move read data from TABLAT to PORTE
	nop
	movlw	0x00		; WR high to low - clock falling slope for writing
	movwf 	PORTD		; 
	nop
	bra	loop		; keep going until finished
	
	goto	0

	end
