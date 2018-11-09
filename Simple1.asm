	#include p18f87k22.inc

	extern	UART_Setup, UART_Transmit_Message   ; external UART subroutines
	extern  ADC_Setup, ADC_Read		    ; external ADC routines
	;extern	multiply816, multiply1616, multiply824
	
acs0	udata_acs   ; reserve data space in access ram
counter	    res 1   ; reserve one byte for a counter variable
delay_count res 1   ; reserve one byte for counter in the delay routine
accum	    res 1
acc_max	    res 1
wav_sel	    res 1
tri	    res 1   ; reserve one byte for selecting up/down for triangle wave
keypadval   res 1
output	    res	1
	
rst	code	0    ; reset vector
	goto	setup

main	code
	; ******* Programme FLASH read Setup Code ***********************
setup	bcf	EECON1, CFGS	; point to Flash program memory  
	bsf	EECON1, EEPGD 	; access Flash program memory
	call	UART_Setup	; setup UART
	call	ADC_Setup	; setup ADC
	call	SPI_MasterInit
	call	Slope_Setup
	movlw	0x0f
	movwf	TRISF		; set 4 PORTF all inputs for 4 waveforms control
	movlw	0x00
	movwf	TRISH		; set PORTH output
	goto	start
	movlw	0x01
	movwf	wav_sel		; default is sawtooth
	goto    start
	; ******* Main programme ****************************************
	; PORTF for waveform control
	; PORTE for keypad inputs
	; PORTD sends SPI, do we need to set as output?
	; PORTH used for chip select


testit  code	0x0008	; high vector, no low vector
	btfss	PIR4,CCP4IF	; check that this is timer0 interrupt
	retfie	1		; if not then return
	call	blink
	bcf	PIR4,CCP4IF	; clear interrupt flag
	retfie  1		; fast return from interrupt
	
start	nop
	movlw	b'00110001'	; Set timer1 to 16-bit, Fosc/4/8
	movwf	T1CON		; = 2MHz clock rate
	banksel CCPTMRS1	; not in access bank!
	bcf	CCPTMRS1,C4TSEL1    ; Choose Timer1
	bcf	CCPTMRS1,C4TSEL0
	movlw	b'00001011'	; Compare mode, reset on compare match
	movwf	CCP4CON
	movlw	0x1E		; set period compare registers
	movwf	CCPR4H		; 0x1E84 gives MSB blink rate at 1Hz
	movlw	0x84
	movwf	CCPR4L
	bsf	PIE4,CCP4IE	; Enable CCP4 interrupt
	bsf	INTCON,PEIE	; Enable peripheral interrupts
	bsf	INTCON,GIE	; Enable all interrupts
	goto	$		; Sit in infinite loop

;int_hi	code	0x0008	; high vector, no low vector
;	btfss	INTCON,TMR0IF	; check that this is timer0 interrupt
;	btfss	INTCON,TMR0IF	; check that this is timer0 interrupt
;	call	transmit
;	bcf	INTCON,TMR0IF	; clear interrupt flag
;	retfie	FAST		; fast return from interrupt

blink
	movlw	0x00
	movwf	PORTH
	nop
	movlw	0x01
	movwf	PORTH
	return
	
	end
	
main_loop
	banksel PADCFG1		; PADCFG1 is not in Access Bank!!
	bsf	PADCFG1, REPU, BANKED	; PortE pull-ups on 
	movlb	0x00		; set BSR back to Bank 0
	clrf	LATE
	
	call	keypad_read_rows
	nop
	nop
	movlw	0x0f
	cpfslt	keypadval
	goto	output_zero	; output zero as no button is pressed
				;THIS NEEDS TO BE CHANGED
	call	keypad_read_columns
	movlw	0xEF		
	cpfslt	keypadval	; output zero as button has been released
	goto	output_zero	;THIS NEEDS TO BE CHANGED
	
	call	get_slope	; gets slope corresponding to button. puts in W
	call	accumulate	; adds slope to the accumulator, if it becomes
				; greater than the max_acc then reset accum to zero
	call	waveform_select	; selects waveform and makes W value to output
	movwf	output
	goto	main_loop

transmit
	movlw	0x00
	movwf	PORTH		    ; set CS low
	movlw	0x50		    ;SEND ZERO FOR UPPER NIBBLE OF DATA TO DAC WORKS FOR ONE NOTE ONLY!!!!!!!!!!!!!
	call	SPI_MasterTransmit;takes data in through W
	movf	output, W
	call	SPI_MasterTransmit;takes data in through W
	movlw	0x01		    ; set CS high
	movwf	PORTH
	goto	main_loop
	

output_zero
	movlw	0x00
	movwf	output
	goto	main_loop
	
accumulate 
	addwf	accum, F	 ; adds slope to the accumulator, if it becomes
	movlw	0xfe		 ; greater than the 0xfe then reset accum to zero 
	cpfsgt	accum		 
	return
	movlw	0x00
	movwf	accum
	return



	
Slope_Setup	    ; save all the slopes at address which is coordinate on keypad
	movlw	0x01		; slopes must correspond to particular freqs
	movwf	0x77		; 1
	movlw	0x02	
	movwf	0xB7		; 2
	movlw	0x03	
	movwf	0xD7		; 3
	movlw	0x04	
	movwf	0x7B		; 4
	movlw	0x05	
	movwf	0xBB		; 5
	movlw	0x06	
	movwf	0xDB		; 6
	movlw	0x07	
	movwf	0x7D		; 7
	movlw	0x08	
	movwf	0xBD		; 8
	movlw	0x09	
	movwf	0xDD		; 9
	movlw	0x0a	
	movwf	0xBE		; 0
	movlw	0x0b	
	movwf	0x7E		; A
	movlw	0x0c	
	movwf	0xDE		; B
	movlw	0x0d	
	movwf	0xEE		; C
	movlw	0x0e	
	movwf	0xED		; D
	movlw	0x0f	
	movwf	0xEB		; E
	movlw	0x10	
	movwf	0xE7		; F
	
	
;Sine_Setup	    ; save all the sine values from 0 to 2pi at consectutive addresses
;	movlw	0x01		; 
;	movwf	0x77		; 1
;	movlw	0x02	
;	movwf	0xB7		; 2
;	movlw	0x03	
;	movwf	0xD7		; 3
;	movlw	0x04	
;	movwf	0x7B		; 4
;	movlw	0x05	
;	movwf	0xBB		; 5
;	movlw	0x06	
;	movwf	0xDB		; 6
;	movlw	0x07	
;	movwf	0x7D		; 7
;	movlw	0x08	
;	movwf	0xBD		; 8
;	movlw	0x09	
;	movwf	0xDD		; 9
;	movlw	0x0a	
;	movwf	0xBE		; 0
;	movlw	0x0b	
;	movwf	0x7E		; A
;	movlw	0x0c	
;	movwf	0xDE		; B
;	movlw	0x0d	
;	movwf	0xEE		; C
;	movlw	0x0e	
;	movwf	0xED		; D
;	movlw	0x0f	
;	movwf	0xEB		; E
;	movlw	0x10	
;	movwf	0xE7		; F
	
	
	
	
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


waveform_select
	movlw	0x01
	cpfslt	PORTF, ACCESS	; want to stay at current waveform	
	movff	PORTF, wav_sel	; save to prevent problems if released in loop
	movlw	0x01
	cpfsgt	wav_sel, ACCESS
	goto	sawtooth	; make sure these return
	movlw	0x02
	cpfsgt	wav_sel, ACCESS 
	goto	square		; make sure these return
	movlw	0x04
	cpfsgt	wav_sel, ACCESS 
	goto	triangle	; make sure these return
	movlw	0x08
	cpfsgt	wav_sel, ACCESS 
	goto	sine		; make sure these return
	
	return
	
	
sawtooth
	movf accum, W
	return 

	
square	;conditions for the square wave value based on accum
	movlw	0x80	    ; midpoint of accumulator
	cpfsgt	accum
	goto	sqr_zero 
	movlw	0xff	    ; square wave max amplitude
	return
sqr_zero
	movlw	0x00
	return
	
	
triangle	
	movlw	0x01
	cpfsgt	accum	    ; make change of direction if accumulator has reached
	bra	up_down	    ; its peak ie. now it is 0x00
	movlw	0x02
	cpfsgt	tri	    ; 0=up, 3=down
	goto	sawtooth
	movlw	0xff	    ; max value of accumulator
	subfwb	accum
	return
up_down			    ; make decision whether to go up or down at peak
	movlw	0x02	    ; of accumulator
	cpfsgt	tri	    ; tri = 0x00 went up now go down
	goto	up	    ; tri = 0x03 went down now go up
	goto	down
up
	movlw	0x03	    ; now go down
	movwf	tri
	return
down
	movlw	0x00	    ; now go up
	movwf	tri
	return

	
	
sine
	;look up sine valuein table corresponding to the value of accum
	
	
	
keypad_read_rows
	movlw   0x0F
	movwf	TRISE, ACCESS	; PORTE half inputs
	movlw	0xFF		; 256 loop delay 
	movwf	delay_count
	call	delay		; delay for voltage to settle
	movff	PORTE, keypadval; read in rows
	return


keypad_read_columns
	movlw   0xF0
	movwf	TRISE, ACCESS	; PORTE half inputs
	movlw	0xFF
	movwf	delay_count
	call	delay		; delay for voltage to settle
	movf	PORTE, W	; read in columns	
	addwf	keypadval, F	; add to get full coordinates of button
	return
	
	
get_slope
	movff	keypadval, FSR2L
	clrf	FSR2H		;CANT REMEMBER WHY WE DID THIS
	movf    INDF2, W	;Read contents of address in FSR2 not changing it
	return
	


	
	

	
	
	
	

	
	
	
	
	
	
	
	
	


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
