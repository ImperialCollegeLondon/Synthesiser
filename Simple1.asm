	#include p18f87k22.inc

	extern  Sine_Setup			    ; external look up tables
	extern	MIDI_Setup
	extern	SPI_MasterInit, SPI_MasterTransmit  ; external SPI subroutines
	extern	get_midi_slope, note_off
	extern  UART_Setup, UART_Receive_Byte
	
	global	counter, accumH, accumL, wav_sel, tri, output, slopeH, slopeL, input, delay_count, output_zero, buffer, slope, accum
	
	
acs0	udata_acs   ; reserve data space in access ram

; setup MIDI buffer hello

		
counter		res 1	; reserve one byte for a counter variable
accumH		res 1	; the accumulator high byte	
accumL		res 1	; the accumulator  low byte		
wav_sel		res 1	; the byte that is used to choose waveform
tri		res 1   ; for selecting up/down for triangle wave
output		res 1	; a byte to put the output into
slopeH		res 1	; to put the slope into high
slopeL		res 1	; slope low byte
input		res 1	; 0 then no input, 1 means input
delay_count	res 1   ; reserve one byte for counter in the delay routine
status		res 1	; byte to save status byte for compare
accum		res 1
slope		res 1
		
		
		
tables		udata	0x400    ; reserve data anywhere in RAM (here at 0x400)
buffer		res 0x80    ; reserve 128 bytes for message data
	
rst	code	0    ; reset vector
	goto	setup

main	code
	; ******* Programme FLASH read Setup Code ***********************
setup	bcf	EECON1, CFGS	; point to Flash program memory  
	bsf	EECON1, EEPGD 	; access Flash program memory
	call	SPI_MasterInit
	call	MIDI_Setup
	call	Sine_Setup
	call	UART_Setup
	movlw	0xff
	movwf	TRISJ		; set 4 PORTJ all inputs for 4 waveforms control
	movlw	0x00
	movwf	TRISH		; set PORTH output
	movwf	TRISF
	movwf	PORTF
	movwf	input
	movwf	output
	movwf	counter
	movlw	0x01
	movwf	wav_sel		; default is sawtooth
	goto    start
	; ********PORT USES********
	; PORTJ for waveform control
	; PORTE for keypad inputs
	; PORTD sends SPI
	; PORTH used for chip select
	; PORTC used for UART recieve
	;********BANK USES********
	; BANK 1 for slopeH
	; BANK 2 for sine
	; BANK 3 for slopeL

; ******* Main programme ****************************************
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


receive_loop
	banksel PADCFG1		; PADCFG1 is not in Access Bank!!
	movlb	0x00
	; call either receive midi or receive keypad
	
	call	receive_midi	; receives the midi signal and sets the appropriate slope
	
	goto	receive_loop


receive_midi		; receives the midi signal and sets the appropriate slope or outputs zero
	lfsr	FSR1, buffer
	call	UART_Receive_Byte	; waits for status byte
	movwf	PORTF
	movwf	status
	movlw	0x8f
	cpfsgt	status
	goto	note_off
	call	UART_Receive_Byte	; receive note byte
	movwf	INDF1	
	call	UART_Receive_Byte   ;clear velocity byte flag
	call	get_midi_slope
	movlw	0x01
	movwf	input		; set the input as 0x01, meaning there is an input
	return
	
	
transmit
	movlw	0x01
	cpfslt	PORTJ, ACCESS	; want to stay at current waveform	
	movff	PORTJ, wav_sel	; save wav_sel
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
	movlw	0x00
	movwf	input		; set input to 0x00 meaning, there is no input
	movwf	output
	goto	receive_loop
	
accumulate;_16 
	movf	slopeL, W
	addwfc	accumL, F	 ; adds slope to the accumulator
	movf	slopeH, W
	addwfc	accumH, F
	return

;accumulate 
;	movf	slope, W
;	addwf	accum, F	 ; adds slope to the accumulator, if it becomes
;	movlw	0xfe		 ; greater than the 0xfe then reset accum to zero 
;	cpfsgt	accum
;;	movlw	0xff	    ; max value of accumulator
;;	subfwb	slope, W
;;	cpfsgt	accum
;	return
;	movlw	0x00
;	movwf	accum
;	return

waveform_select
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
	
;sawtooth
;	movf accum, W
;	return 
;
;	
;square	;conditions for the square wave value based on accum
;	movlw	0x80	    ; midpoint of accumulator
;	cpfsgt	accum
;	goto	sqr_zero 
;	movlw	0xff	    ; square wave max amplitude
;	return
;sqr_zero
;	movlw	0x00
;	return
;	
;	
;triangle
;	movf	slope
;	cpfsgt	accum	    ; make change of direction if accumulator has reached
;	call	up_down	    ; its peak ie. now it is 0x00
;	call	accumulate
;	movlw	0x02
;	cpfsgt	tri	    ; 0=up, 3=down
;	goto	sawtooth
;	movlw	0xff	    ; max value of accumulator
;	subfwb	accum, W
;	return
;up_down			    ; make decision whether to go up or down at peak
;	movlw	0x02	    ; of accumulator
;	cpfsgt	tri	    ; tri = 0x00 went up now go down
;	goto	up	    ; tri = 0x03 went down now go up
;	goto	down
;up
;	movlw	0x03	    ; now go down
;	movwf	tri
;	return
;down
;	movlw	0x00	    ; now go up
;	movwf	tri
;	return	
;	
;sine	;look up sine valuein table corresponding to the value of accum
;	movlw	0x02		; set BSR to Bank 1
;	movwf	FSR2H
;	movff	accum, FSR2L
;	nop
;	movf    INDF2, W	;Read contents of address in FSR2 not changing it
;	nop
;	return
;		

sawtooth;_16
	movf accumH, W
	return 

	
square;_16	;conditions for the square wave value based on accum
	movlw	0x80	    ; midpoint of accumulator
	cpfsgt	accumH
	goto	sqr_zero 
	movlw	0xff	    ; square wave max amplitude
	return
sqr_zero;_16
	movlw	0x00
	return
	
	
triangle;_16
	movf	slopeH
	cpfsgt	accumH	    ; make change of direction if accumulator has reached
	call	up_down	    ; its peak ie. now it is 0x00
	call	accumulate
	movlw	0x02
	cpfsgt	tri	    ; 0=up, 3=down
	goto	sawtooth
	movlw	0xff	    ; max value of accumulator
	subfwb	accumH, W
	return
up_down;_16		    ; make decision whether to go up or down at peak
	movlw	0x02	    ; of accumulator
	cpfsgt	tri	    ; tri = 0x00 went up now go down
	goto	up	    ; tri = 0x03 went down now go up
	goto	down
up;_16
	movlw	0x03	    ; now go down
	movwf	tri
	return
down;_16
	movlw	0x00	    ; now go up
	movwf	tri
	return	
	
sine;_16	;look up sine valuein table corresponding to the value of accum
	movlw	0x02		; set BSR to Bank 1
	movwf	FSR2H
	movff	accumH, FSR2L
	nop
	movf    INDF2, W	;Read contents of address in FSR2 not changing it
	nop
	return
	
		
	end
	