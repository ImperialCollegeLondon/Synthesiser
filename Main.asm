	#include p18f87k22.inc

	extern  Sine_Setup, Slope_Setup		    ; 'Table_Setup.asm' routines
	extern	SPI_MasterInit, SPI_MasterTransmit  ; 'SPI_Trans.asm' routines
	extern	transmit			    ; 'SPI_Trans.asm' routines
	extern	receive_midi			    ; 'MIDI.asm' routines
	extern  UART_Setup			    ; 'UART.asm' routine
	extern  get_output			    ; 'Output_gen.asm' routine
	
	global	output, input, wav_sel
	
	
acs0	udata_acs   ; reserve data space in access ram
	
; variables used in setup
output		res 1	; a byte to put the output into
input		res 1	; 0 then no input, 1 means input
wav_sel		res 1	; the byte that is used to choose waveform
		
rst	code	0    ; reset vector
	goto	setup

main	code
	; ******* Programme FLASH read Setup Code ***********************
setup	bcf	EECON1, CFGS	; point to Flash program memory  
	bsf	EECON1, EEPGD 	; access Flash program memory
	call	SPI_MasterInit
	call	Slope_Setup
	call	Sine_Setup
	call	UART_Setup
	movlw	0xff
	movwf	TRISJ		; set 4 PORTJ inputs for 4 waveforms control
	movlw	0x00
	movwf	TRISH		; set PORTH to output for DAC CS
	movwf	input		; default no input
	movwf	output		; default output zero
	movlw	0x01
	movwf	wav_sel		; default sound is sawtooth
	goto    start
	
; *******PORT USE*********
    ; PORTJ for waveform control
    ; PORTD sends SPI
    ; PORTH used for DAC chip select
    ; PORTC used for UART recieve
;*******BANK USE*********
    ; BANK 1 for slopeH
    ; BANK 2 for sine
    ; BANK 3 for slopeL

; ******* Main programme ****************************************
inter   code	0x0008		; high vector, no low vector
	call	transmit	; generate output and then transmit
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
	movlw	0x01		; set period compare registers
	movwf	CCPR4H		; 0x63F is .362 (rollover) = 44.077kHz rate
	movlw	0x68		; (divide 16MHz by 362)
	movwf	CCPR4L
	bsf	PIE4,CCP4IE	; Enable CCP4 interrupt
	bsf	INTCON,PEIE	; Enable peripheral interrupts
	bsf	INTCON,GIE	; Enable all interrupts


; polls in receive loop until timer interrupts to transmit
receive_loop
	call	receive_midi	; receives the midi signal and sets the 
	bra	receive_loop	; appropriate slope

	end
	