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
	call	Sine_Setup
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



	
	
Sine_Setup	    ; save all the sine values from 0 to 2pi at consectutive addresses
	movlb	 0x2		; set BSR to Bank 1
	movlw    0x7f
	movwf    0x0 , BANKED
	movlw    0x82
	movwf    0x1 , BANKED
	movlw    0x85
	movwf    0x2 , BANKED
	movlw    0x88
	movwf    0x3 , BANKED
	movlw    0x8b
	movwf    0x4 , BANKED
	movlw    0x8e
	movwf    0x5 , BANKED
	movlw    0x91
	movwf    0x6 , BANKED
	movlw    0x94
	movwf    0x7 , BANKED
	movlw    0x97
	movwf    0x8 , BANKED
	movlw    0x9a
	movwf    0x9 , BANKED
	movlw    0x9d
	movwf    0xa , BANKED
	movlw    0xa1
	movwf    0xb , BANKED
	movlw    0xa4
	movwf    0xc , BANKED
	movlw    0xa6
	movwf    0xd , BANKED
	movlw    0xa9
	movwf    0xe , BANKED
	movlw    0xac
	movwf    0xf , BANKED
	movlw    0xaf
	movwf    0x10 , BANKED
	movlw    0xb2
	movwf    0x11 , BANKED
	movlw    0xb5
	movwf    0x12 , BANKED
	movlw    0xb8
	movwf    0x13 , BANKED
	movlw    0xbb
	movwf    0x14 , BANKED
	movlw    0xbd
	movwf    0x15 , BANKED
	movlw    0xc0
	movwf    0x16 , BANKED
	movlw    0xc3
	movwf    0x17 , BANKED
	movlw    0xc5
	movwf    0x18 , BANKED
	movlw    0xc8
	movwf    0x19 , BANKED
	movlw    0xca
	movwf    0x1a , BANKED
	movlw    0xcd
	movwf    0x1b , BANKED
	movlw    0xcf
	movwf    0x1c , BANKED
	movlw    0xd2
	movwf    0x1d , BANKED
	movlw    0xd4
	movwf    0x1e , BANKED
	movlw    0xd6
	movwf    0x1f , BANKED
	movlw    0xd9
	movwf    0x20 , BANKED
	movlw    0xdb
	movwf    0x21 , BANKED
	movlw    0xdd
	movwf    0x22 , BANKED
	movlw    0xdf
	movwf    0x23 , BANKED
	movlw    0xe1
	movwf    0x24 , BANKED
	movlw    0xe3
	movwf    0x25 , BANKED
	movlw    0xe5
	movwf    0x26 , BANKED
	movlw    0xe7
	movwf    0x27 , BANKED
	movlw    0xe8
	movwf    0x28 , BANKED
	movlw    0xea
	movwf    0x29 , BANKED
	movlw    0xec
	movwf    0x2a , BANKED
	movlw    0xed
	movwf    0x2b , BANKED
	movlw    0xef
	movwf    0x2c , BANKED
	movlw    0xf0
	movwf    0x2d , BANKED
	movlw    0xf2
	movwf    0x2e , BANKED
	movlw    0xf3
	movwf    0x2f , BANKED
	movlw    0xf4
	movwf    0x30 , BANKED
	movlw    0xf5
	movwf    0x31 , BANKED
	movlw    0xf6
	movwf    0x32 , BANKED
	movlw    0xf7
	movwf    0x33 , BANKED
	movlw    0xf8
	movwf    0x34 , BANKED
	movlw    0xf9
	movwf    0x35 , BANKED
	movlw    0xfa
	movwf    0x36 , BANKED
	movlw    0xfb
	movwf    0x37 , BANKED
	movlw    0xfb
	movwf    0x38 , BANKED
	movlw    0xfc
	movwf    0x39 , BANKED
	movlw    0xfc
	movwf    0x3a , BANKED
	movlw    0xfd
	movwf    0x3b , BANKED
	movlw    0xfd
	movwf    0x3c , BANKED
	movlw    0xfd
	movwf    0x3d , BANKED
	movlw    0xfd
	movwf    0x3e , BANKED
	movlw    0xfd
	movwf    0x3f , BANKED
	movlw    0xfd
	movwf    0x40 , BANKED
	movlw    0xfd
	movwf    0x41 , BANKED
	movlw    0xfd
	movwf    0x42 , BANKED
	movlw    0xfd
	movwf    0x43 , BANKED
	movlw    0xfd
	movwf    0x44 , BANKED
	movlw    0xfc
	movwf    0x45 , BANKED
	movlw    0xfc
	movwf    0x46 , BANKED
	movlw    0xfb
	movwf    0x47 , BANKED
	movlw    0xfb
	movwf    0x48 , BANKED
	movlw    0xfa
	movwf    0x49 , BANKED
	movlw    0xf9
	movwf    0x4a , BANKED
	movlw    0xf9
	movwf    0x4b , BANKED
	movlw    0xf8
	movwf    0x4c , BANKED
	movlw    0xf7
	movwf    0x4d , BANKED
	movlw    0xf6
	movwf    0x4e , BANKED
	movlw    0xf5
	movwf    0x4f , BANKED
	movlw    0xf3
	movwf    0x50 , BANKED
	movlw    0xf2
	movwf    0x51 , BANKED
	movlw    0xf1
	movwf    0x52 , BANKED
	movlw    0xef
	movwf    0x53 , BANKED
	movlw    0xee
	movwf    0x54 , BANKED
	movlw    0xec
	movwf    0x55 , BANKED
	movlw    0xeb
	movwf    0x56 , BANKED
	movlw    0xe9
	movwf    0x57 , BANKED
	movlw    0xe7
	movwf    0x58 , BANKED
	movlw    0xe6
	movwf    0x59 , BANKED
	movlw    0xe4
	movwf    0x5a , BANKED
	movlw    0xe2
	movwf    0x5b , BANKED
	movlw    0xe0
	movwf    0x5c , BANKED
	movlw    0xde
	movwf    0x5d , BANKED
	movlw    0xdc
	movwf    0x5e , BANKED
	movlw    0xda
	movwf    0x5f , BANKED
	movlw    0xd7
	movwf    0x60 , BANKED
	movlw    0xd5
	movwf    0x61 , BANKED
	movlw    0xd3
	movwf    0x62 , BANKED
	movlw    0xd1
	movwf    0x63 , BANKED
	movlw    0xce
	movwf    0x64 , BANKED
	movlw    0xcc
	movwf    0x65 , BANKED
	movlw    0xc9
	movwf    0x66 , BANKED
	movlw    0xc7
	movwf    0x67 , BANKED
	movlw    0xc4
	movwf    0x68 , BANKED
	movlw    0xc1
	movwf    0x69 , BANKED
	movlw    0xbf
	movwf    0x6a , BANKED
	movlw    0xbc
	movwf    0x6b , BANKED
	movlw    0xb9
	movwf    0x6c , BANKED
	movlw    0xb6
	movwf    0x6d , BANKED
	movlw    0xb4
	movwf    0x6e , BANKED
	movlw    0xb1
	movwf    0x6f , BANKED
	movlw    0xae
	movwf    0x70 , BANKED
	movlw    0xab
	movwf    0x71 , BANKED
	movlw    0xa8
	movwf    0x72 , BANKED
	movlw    0xa5
	movwf    0x73 , BANKED
	movlw    0xa2
	movwf    0x74 , BANKED
	movlw    0x9f
	movwf    0x75 , BANKED
	movlw    0x9c
	movwf    0x76 , BANKED
	movlw    0x99
	movwf    0x77 , BANKED
	movlw    0x96
	movwf    0x78 , BANKED
	movlw    0x93
	movwf    0x79 , BANKED
	movlw    0x90
	movwf    0x7a , BANKED
	movlw    0x8d
	movwf    0x7b , BANKED
	movlw    0x89
	movwf    0x7c , BANKED
	movlw    0x86
	movwf    0x7d , BANKED
	movlw    0x83
	movwf    0x7e , BANKED
	movlw    0x80
	movwf    0x7f , BANKED
	movlw    0x7d
	movwf    0x80 , BANKED
	movlw    0x7a
	movwf    0x81 , BANKED
	movlw    0x77
	movwf    0x82 , BANKED
	movlw    0x74
	movwf    0x83 , BANKED
	movlw    0x70
	movwf    0x84 , BANKED
	movlw    0x6d
	movwf    0x85 , BANKED
	movlw    0x6a
	movwf    0x86 , BANKED
	movlw    0x67
	movwf    0x87 , BANKED
	movlw    0x64
	movwf    0x88 , BANKED
	movlw    0x61
	movwf    0x89 , BANKED
	movlw    0x5e
	movwf    0x8a , BANKED
	movlw    0x5b
	movwf    0x8b , BANKED
	movlw    0x58
	movwf    0x8c , BANKED
	movlw    0x55
	movwf    0x8d , BANKED
	movlw    0x52
	movwf    0x8e , BANKED
	movlw    0x4f
	movwf    0x8f , BANKED
	movlw    0x4c
	movwf    0x90 , BANKED
	movlw    0x49
	movwf    0x91 , BANKED
	movlw    0x47
	movwf    0x92 , BANKED
	movlw    0x44
	movwf    0x93 , BANKED
	movlw    0x41
	movwf    0x94 , BANKED
	movlw    0x3e
	movwf    0x95 , BANKED
	movlw    0x3c
	movwf    0x96 , BANKED
	movlw    0x39
	movwf    0x97 , BANKED
	movlw    0x36
	movwf    0x98 , BANKED
	movlw    0x34
	movwf    0x99 , BANKED
	movlw    0x31
	movwf    0x9a , BANKED
	movlw    0x2f
	movwf    0x9b , BANKED
	movlw    0x2c
	movwf    0x9c , BANKED
	movlw    0x2a
	movwf    0x9d , BANKED
	movlw    0x28
	movwf    0x9e , BANKED
	movlw    0x26
	movwf    0x9f , BANKED
	movlw    0x23
	movwf    0xa0 , BANKED
	movlw    0x21
	movwf    0xa1 , BANKED
	movlw    0x1f
	movwf    0xa2 , BANKED
	movlw    0x1d
	movwf    0xa3 , BANKED
	movlw    0x1b
	movwf    0xa4 , BANKED
	movlw    0x19
	movwf    0xa5 , BANKED
	movlw    0x17
	movwf    0xa6 , BANKED
	movlw    0x16
	movwf    0xa7 , BANKED
	movlw    0x14
	movwf    0xa8 , BANKED
	movlw    0x12
	movwf    0xa9 , BANKED
	movlw    0x11
	movwf    0xaa , BANKED
	movlw    0xf
	movwf    0xab , BANKED
	movlw    0xe
	movwf    0xac , BANKED
	movlw    0xc
	movwf    0xad , BANKED
	movlw    0xb
	movwf    0xae , BANKED
	movlw    0xa
	movwf    0xaf , BANKED
	movlw    0x8
	movwf    0xb0 , BANKED
	movlw    0x7
	movwf    0xb1 , BANKED
	movlw    0x6
	movwf    0xb2 , BANKED
	movlw    0x5
	movwf    0xb3 , BANKED
	movlw    0x4
	movwf    0xb4 , BANKED
	movlw    0x4
	movwf    0xb5 , BANKED
	movlw    0x3
	movwf    0xb6 , BANKED
	movlw    0x2
	movwf    0xb7 , BANKED
	movlw    0x2
	movwf    0xb8 , BANKED
	movlw    0x1
	movwf    0xb9 , BANKED
	movlw    0x1
	movwf    0xba , BANKED
	movlw    0x0
	movwf    0xbb , BANKED
	movlw    0x0
	movwf    0xbc , BANKED
	movlw    0x0
	movwf    0xbd , BANKED
	movlw    0x0
	movwf    0xbe , BANKED
	movlw    0x0
	movwf    0xbf , BANKED
	movlw    0x0
	movwf    0xc0 , BANKED
	movlw    0x0
	movwf    0xc1 , BANKED
	movlw    0x0
	movwf    0xc2 , BANKED
	movlw    0x0
	movwf    0xc3 , BANKED
	movlw    0x0
	movwf    0xc4 , BANKED
	movlw    0x1
	movwf    0xc5 , BANKED
	movlw    0x1
	movwf    0xc6 , BANKED
	movlw    0x2
	movwf    0xc7 , BANKED
	movlw    0x2
	movwf    0xc8 , BANKED
	movlw    0x3
	movwf    0xc9 , BANKED
	movlw    0x4
	movwf    0xca , BANKED
	movlw    0x5
	movwf    0xcb , BANKED
	movlw    0x6
	movwf    0xcc , BANKED
	movlw    0x7
	movwf    0xcd , BANKED
	movlw    0x8
	movwf    0xce , BANKED
	movlw    0x9
	movwf    0xcf , BANKED
	movlw    0xa
	movwf    0xd0 , BANKED
	movlw    0xb
	movwf    0xd1 , BANKED
	movlw    0xd
	movwf    0xd2 , BANKED
	movlw    0xe
	movwf    0xd3 , BANKED
	movlw    0x10
	movwf    0xd4 , BANKED
	movlw    0x11
	movwf    0xd5 , BANKED
	movlw    0x13
	movwf    0xd6 , BANKED
	movlw    0x15
	movwf    0xd7 , BANKED
	movlw    0x16
	movwf    0xd8 , BANKED
	movlw    0x18
	movwf    0xd9 , BANKED
	movlw    0x1a
	movwf    0xda , BANKED
	movlw    0x1c
	movwf    0xdb , BANKED
	movlw    0x1e
	movwf    0xdc , BANKED
	movlw    0x20
	movwf    0xdd , BANKED
	movlw    0x22
	movwf    0xde , BANKED
	movlw    0xff		;change back to 0x24
	movwf    0xdf , BANKED
	movlw    0x27
	movwf    0xe0 , BANKED
	movlw    0x29
	movwf    0xe1 , BANKED
	movlw    0x2b
	movwf    0xe2 , BANKED
	movlw    0x2e
	movwf    0xe3 , BANKED
	movlw    0x30
	movwf    0xe4 , BANKED
	movlw    0x33
	movwf    0xe5 , BANKED
	movlw    0x35
	movwf    0xe6 , BANKED
	movlw    0x38
	movwf    0xe7 , BANKED
	movlw    0x3a
	movwf    0xe8 , BANKED
	movlw    0x3d
	movwf    0xe9 , BANKED
	movlw    0x40
	movwf    0xea , BANKED
	movlw    0x42
	movwf    0xeb , BANKED
	movlw    0x45
	movwf    0xec , BANKED
	movlw    0x48
	movwf    0xed , BANKED
	movlw    0x4b
	movwf    0xee , BANKED
	movlw    0x4e
	movwf    0xef , BANKED
	movlw    0x51
	movwf    0xf0 , BANKED
	movlw    0x54
	movwf    0xf1 , BANKED
	movlw    0x57
	movwf    0xf2 , BANKED
	movlw    0x59
	movwf    0xf3 , BANKED
	movlw    0x5c
	movwf    0xf4 , BANKED
	movlw    0x60
	movwf    0xf5 , BANKED
	movlw    0x63
	movwf    0xf6 , BANKED
	movlw    0x66
	movwf    0xf7 , BANKED
	movlw    0x69
	movwf    0xf8 , BANKED
	movlw    0x6c
	movwf    0xf9 , BANKED
	movlw    0x6f
	movwf    0xfa , BANKED
	movlw    0x72
	movwf    0xfb , BANKED
	movlw    0x75
	movwf    0xfc , BANKED
	movlw    0x78
	movwf    0xfd , BANKED
	movlw    0x7b
	movwf    0xfe , BANKED
	movlw    0x7f
	movwf    0xff , BANKED
	
;	movlb	 0x1
;	movlw    0x24		;change back to 0x24
;	movwf    0xdf , BANKED
;	
	
	
	movlb	 0x00		; set BSR to Bank 0

	
	
	
	
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

	
	
sine	;look up sine valuein table corresponding to the value of accum
	movlb	0x2		; set BSR to Bank 1
	movff	accum, FSR2L
	nop
	clrf	FSR2H		; make sure high byte is zero
	movf    INDF2, 0, 1 ;Read contents of address in FSR2 not changing it
	nop
	movlb	0x00		; set BSR to Bank 0
	return
	
	
	
	
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
