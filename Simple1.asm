	#include p18f87k22.inc

	extern  Sine_Setup			    ; 'Sine_Table' routines
	extern	SPI_MasterInit, SPI_MasterTransmit  ; 'SPI' routines
	extern	MIDI_Setup, get_midi_slope, receive_midi ; 'MIDI_read' routines
	extern  UART_Setup, UART_Receive_Byte		 ; 'UART' routines
	extern  get_output, accumulate		 ; 'Accumulate_generator' routines
	extern  sawtooth, square, waveform_select; 'Accumulate_generator' routines
	extern  sqr_zero, triangle, sine	 ; 'Accumulate_generator' routines
	
	global	counter, accumH, accumL, wav_sel, tri, output, slopeH, slopeL
	global	input, delay_count, note, output, status
	
	
acs0	udata_acs   ; reserve data space in access ram

		
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
note		res 1	; one byte for note
	
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
	movwf	TRISJ		; set PORTJ all inputs for 4 waveforms control
	movlw	0x00
	movwf	TRISH		; set PORTH to output for DAC CS
	movwf	input		; default no input
	movwf	output		; default output zero
	movlw	0x01
	movwf	wav_sel		; default sound is sawtooth
	goto    start
	; ********PORT USES********
	; PORTJ for waveform control
	; PORTE for keypad inputs
	; PORTD sends SPI
	; PORTH used for DAC chip select
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
	movlw	b'00000001'	; Set timer1 to 16-MHz, Fosc/4
	movwf	T1CON		; = 2MHz clock rate
	banksel CCPTMRS1	; not in access bank!
	bcf	CCPTMRS1,C4TSEL1    ; Choose Timer1
	bcf	CCPTMRS1,C4TSEL0
	movlw	b'00001011'	; Compare mode, reset on compare match
	movwf	CCP4CON
	movlw	0x06		; set period compare registers
	movwf	CCPR4H		; 0x63F is .1599 (rollover) = 10kHz sample rate
	movlw	0x3F		
	movwf	CCPR4L
	bsf	PIE4,CCP4IE	; Enable CCP4 interrupt
	bsf	INTCON,PEIE	; Enable peripheral interrupts
	bsf	INTCON,GIE	; Enable all interrupts


receive_loop
	banksel PADCFG1		; PADCFG1 is not in Access Bank!!
	movlb	0x00		; ensure bsr bank 0
	call	receive_midi	; receives the midi signal and sets the 
	goto	receive_loop	; appropriate slope


	
transmit
	movlw	0x01
	cpfslt	PORTJ, ACCESS	; want to stay at current waveform if PORTJ is 0
	movff	PORTJ, wav_sel	; save wav_sel
	movlw	0x01
	cpfslt	input		; check if there is an input
	call	get_output	; hopefully this delay isnt a problem
	movlw	0x00
	movwf	PORTH		; set CS low
	movlw	0x50		; send zero for upper nibble data (only 1 note)
	call	SPI_MasterTransmit  ;takes data in through W
	movf	output, W
	call	SPI_MasterTransmit  ;takes data in through W
	movlw	0x01		 ; set CS high
	movwf	PORTH
	return

	
	end
	