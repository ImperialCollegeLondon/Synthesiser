	#include p18f87k22.inc

	extern	UART_Setup, UART_Transmit_Message   ; external UART subroutines
	extern  Slope_Setup, Sine_Setup	    ; external look up tables
	extern	SPI_MasterInit, SPI_MasterTransmit  ; external SPI subroutines
	extern  keypad_read_rows		    ; external keypad read
	extern	keypad_read_columns, get_slope	    ; subroutines
	
	
acs0	udata_acs   ; reserve data space in access ram
	
counter		res 1	; reserve one byte for a counter variable
accum		res 1	; the accumulator byte
wav_sel		res 1	; the byte that is used to choose waveform
tri		res 1   ; for selecting up/down for triangle wave
output		res 1	; a byte to put the output into
slope		res 1	; to put the slope into
input		res 1	; 0 then no input, 1 means input
delay_count	res 1   ; reserve one byte for counter in the delay routine
keypadval	res 1	; the coordinates of button pressed
UART_counter	res 1	; reserve 1 byte for variable UART_counter

	
rst	code	0    ; reset vector
	goto	setup

main	code
	; ******* Programme FLASH read Setup Code ***********************
setup	bcf	EECON1, CFGS	; point to Flash program memory  
	bsf	EECON1, EEPGD 	; access Flash program memory
	call	UART_Setup	; setup UART
	call	SPI_MasterInit
	call	Slope_Setup
	call	Sine_Setup
	movlw	0xff
	movwf	TRISJ		; set 4 PORTJ all inputs for 4 waveforms control
	movlw	0x00
	movwf	TRISH		; set PORTH output
	movlw	0x01
	movwf	wav_sel		; default is sawtooth
	goto    start
	; ******* Main programme ****************************************
	; PORTJ for waveform control
	; PORTE for keypad inputs
	; PORTD sends SPI
	; PORTH used for chip select
	; PORTC used for UART recieve


inter   code	0x0008		; high vector, no low vector
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
	movlw	0x05		; set period compare registers
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
	call	get_output	; hopefully this delay isnt a problem
	movlw	0x00
	movwf	PORTH		; set CS low
	movlw	0x50		;SEND ZERO FOR UPPER NIBBLE OF DATA TO DAC WORKS FOR ONE NOTE ONLY!!!!!!!!!!!!!
	call	SPI_MasterTransmit  ;takes data in through W
	movf	output, W
	call	SPI_MasterTransmit  ;takes data in through W
	movlw	0x01		 ; set CS high
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
	
sine	;look up sine valuein table corresponding to the value of accum
	movlw	0x02		; set BSR to Bank 1
	movwf	FSR2H
	movff	accum, FSR2L
	nop
	movf    INDF2, W	;Read contents of address in FSR2 not changing it
	nop
	return
	
		
	end
	
	