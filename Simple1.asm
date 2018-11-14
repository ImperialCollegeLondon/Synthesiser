	#include p18f87k22.inc

	extern	UART_Setup, UART_Transmit_Message   ; external UART subroutines
	extern  ADC_Setup, ADC_Read		    ; external ADC routines
	;extern	multiply816, multiply1616, multiply824
	
acs0	udata_acs   ; reserve data space in access ram
delay_count res 1   ; reserve one byte for counter in the delay routine
accum	    res 1
acc_max	    res 1
wav_sel	    res 1
tri	    res 1   ; reserve one byte for selecting up/down for triangle wave
keypadval   res 1
output	    res	1
slope	    res 1
input	    res 1
	
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
	movlw	0xff
	movwf	TRISJ		; set 4 PORTJ all inputs for 4 waveforms control
	movlw	0x00
	movwf	TRISH		; set PORTH output
;	movlw	0xFF
;	movwf	TRISG		; set PORTG output
	movlw	0x01
	movwf	wav_sel		; default is sawtooth
	goto    start
	; ******* Main programme ****************************************
	; PORTJ for waveform control
	; PORTE for keypad inputs
	; PORTD sends SPI
	; PORTH used for chip select
	; PORTG used for UART recieve


inter   code	0x0008	; high vector, no low vector
	btfss	PIR4,CCP4IF	; check that this is timer0 interrupt
	retfie	1		; if not then return
	call	transmit
	bcf	PIR4,CCP4IF	; clear interrupt flag
	retfie  1		; fast return from interrupt
	
start	nop
	
timer	
	movlw	b'00000001'	; Set timer1 to 16-bit, Fosc/4
	movwf	T1CON		; = 2MHz clock rate
	banksel CCPTMRS1	; not in access bank!
	bcf	CCPTMRS1,C4TSEL1    ; Choose Timer1
	bcf	CCPTMRS1,C4TSEL0
	movlw	b'00001011'	; Compare mode, reset on compare match
	movwf	CCP4CON
	movlw	0x2f		; set period compare registers
	movwf	CCPR4H		; 0x1E84 gives MSB blink rate at 1Hz
	movlw	0x0c
	movwf	CCPR4L
	bsf	PIE4,CCP4IE	; Enable CCP4 interrupt
	bsf	INTCON,PEIE	; Enable peripheral interrupts
	bsf	INTCON,GIE	; Enable all interrupts


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
				
	call	keypad_read_columns
	movlw	0xEF		
	cpfslt	keypadval	; output zero as button has been released
	goto	output_zero	
	
	movlw	0x01
	movwf	input		; set the input as 0x01, meaning there is an input
	call	get_slope	; gets slope corresponding to button. puts in W

	goto	main_loop

transmit
	movlw	0x01
	cpfslt	input		; check if there is an input
	call	get_output	    ; hopefully this delay isnt a problem
	movlw	0x00
	movwf	PORTH		    ; set CS low
	movlw	0x50		    ;SEND ZERO FOR UPPER NIBBLE OF DATA TO DAC WORKS FOR ONE NOTE ONLY!!!!!!!!!!!!!
	call	SPI_MasterTransmit;takes data in through W
	movf	output, W
	call	SPI_MasterTransmit;takes data in through W
	movlw	0x01		    ; set CS high
	movwf	PORTH
	return
	
get_output
	call	accumulate	; adds slope to the accumulator, if it becomes
				; greater than the max_acc then reset accum to zero
	call	waveform_select	; selects waveform and makes W value to output
	movwf	output
	return
	
	
output_zero
	movlw	0x01
	cpfslt	PORTJ, ACCESS	; want to stay at current waveform	
	movff	PORTJ, wav_sel	; save wav_sel
	movlw	0x00
	movwf	input		; set input to 0x00 meaning, there is no input
	movwf	output
	goto	main_loop
	
accumulate 
	movf	slope, W
	addwf	accum, F	 ; adds slope to the accumulator, if it becomes
	movlw	0xfe		 ; greater than the 0xfe then reset accum to zero 
	cpfsgt	accum
;	movlw	0xff	    ; max value of accumulator
;	subfwb	slope, W
;	cpfsgt	accum
	return
	movlw	0x00
	movwf	accum
	return



	
Slope_Setup	    ; save all the slopes at address which is coordinate on keypad

	movlw	0x0B		; slopes must correspond to particular freqs
	movwf	0x77		; 1
	movlw	0x0C	
	movwf	0xB7		; 2
	movlw	0x0D	
	movwf	0xD7		; 3
	movlw	0x0E	
	movwf	0xE7		; F
	movlw	0x0F	
	movwf	0x7B		; 4
	movlw	0x10	
	movwf	0xBB		; 5
	movlw	0x11	
	movwf	0xDB		; 6
	movlw	0x12	
	movwf	0xEB		; E
	movlw	0x13	
	movwf	0x7D		; 7
	movlw	0x14	
	movwf	0xBD		; 8
	movlw	0x15	
	movwf	0xDD		; 9
	movlw	0x16	
	movwf	0xED		; D
	movlw	0x17	
	movwf	0x7E		; A
	movlw	0x18	
	movwf	0xBE		; 0
	movlw	0x19	
	movwf	0xDE		; B
	movlw	0x1a	
	movwf	0xEE		; C



	
	
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
	cpfslt	PORTJ, ACCESS	; want to stay at current waveform	
	movff	PORTJ, wav_sel	; save to prevent problems if released in loop
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
	goto	sawtooth
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
	movf	slope
	cpfsgt	accum	    ; make change of direction if accumulator has reached
	call	up_down	    ; its peak ie. now it is 0x00
	call	accumulate
	movlw	0x02
	cpfsgt	tri	    ; 0=up, 3=down
	goto	sawtooth
	movlw	0xff	    ; max value of accumulator
	subfwb	accum, W
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
	movwf	slope
	return
	

	; a delay subroutine if you need one, times around loop in delay_count
delay	decfsz	delay_count	; decrement until zero	
	bra delay
	return
	
	
	end
	
	
	
	
	
