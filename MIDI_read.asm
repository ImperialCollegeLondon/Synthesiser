#include p18f87k22.inc

    global  MIDI_Setup, get_midi_slope, receive_midi
    extern  counter, slopeH, slopeL, note, UART_Receive_Byte, status, input, output
    

MIDI	code

get_midi_slope;_16
	movf	INDF1, W	; increment FSR1
	movwf   FSR2L	
	movlw	0x01
	movwf	FSR2H		; slopeH's stored in bank 1
	movf    INDF2, W	;Read contents of address in FSR2 not changing it
	movwf	slopeH
	movlw	0x03
	movwf	FSR2H		; slopeL's stored in bank 3
	movf    INDF2, W	;Read contents of address in FSR2 not changing it
	movwf	slopeL
	return
	
		
receive_midi		; receives the midi signal and sets the appropriate slope or outputs zero
	lfsr	FSR1, note
	call	UART_Receive_Byte	; waits for status byte
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
note_off
	; clear 2 bytes flags
	call	UART_Receive_Byte
	call	UART_Receive_Byte
	movlw	0x00
	movwf	input		; set input to 0x00 meaning, there is no input
	movwf	output
	return
	
	
MIDI_Setup;_16	    ; save all the slopes at address which is coordinate on keypad
	movlb	 0x01
	movlb    0x01    ; slope high bytes stored in bank 1
	movlw    0x1
	movwf    0x24 ,BANKED
	movlw    0x1
	movwf    0x25 ,BANKED
	movlw    0x1
	movwf    0x26 ,BANKED
	movlw    0x1
	movwf    0x27 ,BANKED
	movlw    0x2
	movwf    0x28 ,BANKED
	movlw    0x2
	movwf    0x29 ,BANKED
	movlw    0x2
	movwf    0x2a ,BANKED
	movlw    0x2
	movwf    0x2b ,BANKED
	movlw    0x2
	movwf    0x2c ,BANKED
	movlw    0x2
	movwf    0x2d ,BANKED
	movlw    0x2
	movwf    0x2e ,BANKED
	movlw    0x3
	movwf    0x2f ,BANKED
	movlw    0x3
	movwf    0x30 ,BANKED
	movlw    0x3
	movwf    0x31 ,BANKED
	movlw    0x3
	movwf    0x32 ,BANKED
	movlw    0x3
	movwf    0x33 ,BANKED
	movlw    0x4
	movwf    0x34 ,BANKED
	movlw    0x4
	movwf    0x35 ,BANKED
	movlw    0x4
	movwf    0x36 ,BANKED
	movlw    0x4
	movwf    0x37 ,BANKED
	movlw    0x5
	movwf    0x38 ,BANKED
	movlw    0x5
	movwf    0x39 ,BANKED
	movlw    0x5
	movwf    0x3a ,BANKED
	movlw    0x6
	movwf    0x3b ,BANKED
	movlw    0x6
	movwf    0x3c ,BANKED
	movlw    0x7
	movwf    0x3d ,BANKED
	movlw    0x7
	movwf    0x3e ,BANKED
	movlw    0x7
	movwf    0x3f ,BANKED
	movlw    0x8
	movwf    0x40 ,BANKED
	movlw    0x8
	movwf    0x41 ,BANKED
	movlw    0x9
	movwf    0x42 ,BANKED
	movlw    0x9
	movwf    0x43 ,BANKED
	movlw    0xa
	movwf    0x44 ,BANKED
	movlw    0xb
	movwf    0x45 ,BANKED
	movlw    0xb
	movwf    0x46 ,BANKED
	movlw    0xc
	movwf    0x47 ,BANKED
	movlw    0xd
	movwf    0x48 ,BANKED
	movlw    0xe
	movwf    0x49 ,BANKED
	movlw    0xe
	movwf    0x4a ,BANKED
	movlw    0xf
	movwf    0x4b ,BANKED
	movlw    0x10
	movwf    0x4c ,BANKED
	movlw    0x11
	movwf    0x4d ,BANKED
	movlw    0x12
	movwf    0x4e ,BANKED
	movlw    0x13
	movwf    0x4f ,BANKED
	movlw    0x15
	movwf    0x50 ,BANKED
	movlw    0x16
	movwf    0x51 ,BANKED
	movlw    0x17
	movwf    0x52 ,BANKED
	movlw    0x19
	movwf    0x53 ,BANKED
	movlw    0x1a
	movwf    0x54 ,BANKED



	movlb    0x03    ; slope low bytes stored in bank 3
	movlw    0xaa
	movwf    0x24 ,BANKED
	movlw    0xc3
	movwf    0x25 ,BANKED
	movlw    0xde
	movwf    0x26 ,BANKED
	movlw    0xfa
	movwf    0x27 ,BANKED
	movlw    0x19
	movwf    0x28 ,BANKED
	movlw    0x39
	movwf    0x29 ,BANKED
	movlw    0x5b
	movwf    0x2a ,BANKED
	movlw    0x7f
	movwf    0x2b ,BANKED
	movlw    0xa5
	movwf    0x2c ,BANKED
	movlw    0xcd
	movwf    0x2d ,BANKED
	movlw    0xf7
	movwf    0x2e ,BANKED
	movlw    0x25
	movwf    0x2f ,BANKED
	movlw    0x55
	movwf    0x30 ,BANKED
	movlw    0x88
	movwf    0x31 ,BANKED
	movlw    0xbd
	movwf    0x32 ,BANKED
	movlw    0xf6
	movwf    0x33 ,BANKED
	movlw    0x33
	movwf    0x34 ,BANKED
	movlw    0x73
	movwf    0x35 ,BANKED
	movlw    0xb6
	movwf    0x36 ,BANKED
	movlw    0xfe
	movwf    0x37 ,BANKED
	movlw    0x4b
	movwf    0x38 ,BANKED
	movlw    0x9b
	movwf    0x39 ,BANKED
	movlw    0xf0
	movwf    0x3a ,BANKED
	movlw    0x4b
	movwf    0x3b ,BANKED
	movlw    0xab
	movwf    0x3c ,BANKED
	movlw    0x11
	movwf    0x3d ,BANKED
	movlw    0x7c
	movwf    0x3e ,BANKED
	movlw    0xee
	movwf    0x3f ,BANKED
	movlw    0x67
	movwf    0x40 ,BANKED
	movlw    0xe6
	movwf    0x41 ,BANKED
	movlw    0x6e
	movwf    0x42 ,BANKED
	movlw    0xfd
	movwf    0x43 ,BANKED
	movlw    0x96
	movwf    0x44 ,BANKED
	movlw    0x38
	movwf    0x45 ,BANKED
	movlw    0xe2
	movwf    0x46 ,BANKED
	movlw    0x97
	movwf    0x47 ,BANKED
	movlw    0x57
	movwf    0x48 ,BANKED
	movlw    0x22
	movwf    0x49 ,BANKED
	movlw    0xf9
	movwf    0x4a ,BANKED
	movlw    0xdd
	movwf    0x4b ,BANKED
	movlw    0xce
	movwf    0x4c ,BANKED
	movlw    0xce
	movwf    0x4d ,BANKED
	movlw    0xdd
	movwf    0x4e ,BANKED
	movlw    0xfc
	movwf    0x4f ,BANKED
	movlw    0x2e
	movwf    0x50 ,BANKED
	movlw    0x70
	movwf    0x51 ,BANKED
	movlw    0xc5
	movwf    0x52 ,BANKED
	movlw    0x2f
	movwf    0x53 ,BANKED
	movlw    0xae
	movwf    0x54 ,BANKED
	movlb    0x01    ; bsr reset to bank 0
	return

	end