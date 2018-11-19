#include p18f87k22.inc

    global  MIDI_Setup, get_midi_slope, receive_midi, slopeH, slopeL 
    extern  UART_Receive_Byte, input, output
    
    
acs0	udata_acs   ; reserve data space in access ram
			
slopeH		res 1	; to put the slope into high
slopeL		res 1	; slope low byte
note		res 1	; one byte for note		
status		res 1	; byte to save status byte for compare on/off
		
MIDI	code
		
receive_midi ; receives the midi and sets the appropriate slope or outputs zero
	call	UART_Receive_Byte	; waits for status byte
	movwf	status			; saves status byte
	movlw	0x8f
	cpfsgt	status			; checks if status is on or off
	bra	note_off		
	call	UART_Receive_Byte	; receive the note byte		
	movwf	note			; put it into note 
	call	UART_Receive_Byte	; clear velocity byte flag
	call	get_midi_slope		; get slopeL/H stored at MIDI note no.
	movlw	0x01
	movwf	input			; set the input as 0x01, meaning there..
	return				; ..is an input
note_off
	; clear 2 bytes flags
	call	UART_Receive_Byte
	call	UART_Receive_Byte
	movlw	0x00
	movwf	input		; set input to 0x00 meaning, there is no input
	movwf	output
	return
	
get_midi_slope		
	movff	note, FSR2L	; move address (MIDI note no.) of slopeH and..
	movlw	0x01		; ..slopeL into FSR2L
	movwf	FSR2H		; slopeH's stored in bank 1
	movf    INDF2, W	; Read contents of address (not incrementing)
	movwf	slopeH
	movlw	0x03		; slopeL's stored in bank 3
	movwf	FSR2H		
	movf    INDF2, W	; Read contents of address (not incrementing)
	movwf	slopeL
	return
	
MIDI_Setup    ; save all the slopes at address equal to the MIDI note number
	movlb    0x01    ; slope low bytes stored in bank 1
	movlw    0x0
	movwf    0x24 ,BANKED
	movlw    0x0
	movwf    0x25 ,BANKED
	movlw    0x0
	movwf    0x26 ,BANKED
	movlw    0x0
	movwf    0x27 ,BANKED
	movlw    0x0
	movwf    0x28 ,BANKED
	movlw    0x0
	movwf    0x29 ,BANKED
	movlw    0x0
	movwf    0x2a ,BANKED
	movlw    0x0
	movwf    0x2b ,BANKED
	movlw    0x0
	movwf    0x2c ,BANKED
	movlw    0x0
	movwf    0x2d ,BANKED
	movlw    0x0
	movwf    0x2e ,BANKED
	movlw    0x0
	movwf    0x2f ,BANKED
	movlw    0x0
	movwf    0x30 ,BANKED
	movlw    0x0
	movwf    0x31 ,BANKED
	movlw    0x0
	movwf    0x32 ,BANKED
	movlw    0x0
	movwf    0x33 ,BANKED
	movlw    0x0
	movwf    0x34 ,BANKED
	movlw    0x1
	movwf    0x35 ,BANKED
	movlw    0x1
	movwf    0x36 ,BANKED
	movlw    0x1
	movwf    0x37 ,BANKED
	movlw    0x1
	movwf    0x38 ,BANKED
	movlw    0x1
	movwf    0x39 ,BANKED
	movlw    0x1
	movwf    0x3a ,BANKED
	movlw    0x1
	movwf    0x3b ,BANKED
	movlw    0x1
	movwf    0x3c ,BANKED
	movlw    0x1
	movwf    0x3d ,BANKED
	movlw    0x1
	movwf    0x3e ,BANKED
	movlw    0x1
	movwf    0x3f ,BANKED
	movlw    0x1
	movwf    0x40 ,BANKED
	movlw    0x2
	movwf    0x41 ,BANKED
	movlw    0x2
	movwf    0x42 ,BANKED
	movlw    0x2
	movwf    0x43 ,BANKED
	movlw    0x2
	movwf    0x44 ,BANKED
	movlw    0x2
	movwf    0x45 ,BANKED
	movlw    0x2
	movwf    0x46 ,BANKED
	movlw    0x2
	movwf    0x47 ,BANKED
	movlw    0x3
	movwf    0x48 ,BANKED
	movlw    0x3
	movwf    0x49 ,BANKED
	movlw    0x3
	movwf    0x4a ,BANKED
	movlw    0x3
	movwf    0x4b ,BANKED
	movlw    0x3
	movwf    0x4c ,BANKED
	movlw    0x4
	movwf    0x4d ,BANKED
	movlw    0x4
	movwf    0x4e ,BANKED
	movlw    0x4
	movwf    0x4f ,BANKED
	movlw    0x4
	movwf    0x50 ,BANKED
	movlw    0x5
	movwf    0x51 ,BANKED
	movlw    0x5
	movwf    0x52 ,BANKED
	movlw    0x5
	movwf    0x53 ,BANKED
	movlw    0x6
	movwf    0x54 ,BANKED



	movlb    0x03    ; slope high bytes stored in bank 3
	movlw    0x60
	movwf    0x24 ,BANKED
	movlw    0x66
	movwf    0x25 ,BANKED
	movlw    0x6c
	movwf    0x26 ,BANKED
	movlw    0x72
	movwf    0x27 ,BANKED
	movlw    0x79
	movwf    0x28 ,BANKED
	movlw    0x80
	movwf    0x29 ,BANKED
	movlw    0x88
	movwf    0x2a ,BANKED
	movlw    0x90
	movwf    0x2b ,BANKED
	movlw    0x99
	movwf    0x2c ,BANKED
	movlw    0xa2
	movwf    0x2d ,BANKED
	movlw    0xab
	movwf    0x2e ,BANKED
	movlw    0xb6
	movwf    0x2f ,BANKED
	movlw    0xc0
	movwf    0x30 ,BANKED
	movlw    0xcc
	movwf    0x31 ,BANKED
	movlw    0xd8
	movwf    0x32 ,BANKED
	movlw    0xe5
	movwf    0x33 ,BANKED
	movlw    0xf3
	movwf    0x34 ,BANKED
	movlw    0x2
	movwf    0x35 ,BANKED
	movlw    0x11
	movwf    0x36 ,BANKED
	movlw    0x22
	movwf    0x37 ,BANKED
	movlw    0x33
	movwf    0x38 ,BANKED
	movlw    0x45
	movwf    0x39 ,BANKED
	movlw    0x58
	movwf    0x3a ,BANKED
	movlw    0x6d
	movwf    0x3b ,BANKED
	movlw    0x82
	movwf    0x3c ,BANKED
	movlw    0x99
	movwf    0x3d ,BANKED
	movlw    0xb2
	movwf    0x3e ,BANKED
	movlw    0xcb
	movwf    0x3f ,BANKED
	movlw    0xe7
	movwf    0x40 ,BANKED
	movlw    0x5
	movwf    0x41 ,BANKED
	movlw    0x23
	movwf    0x42 ,BANKED
	movlw    0x44
	movwf    0x43 ,BANKED
	movlw    0x66
	movwf    0x44 ,BANKED
	movlw    0x8b
	movwf    0x45 ,BANKED
	movlw    0xb1
	movwf    0x46 ,BANKED
	movlw    0xda
	movwf    0x47 ,BANKED
	movlw    0x6
	movwf    0x48 ,BANKED
	movlw    0x34
	movwf    0x49 ,BANKED
	movlw    0x65
	movwf    0x4a ,BANKED
	movlw    0x98
	movwf    0x4b ,BANKED
	movlw    0xcf
	movwf    0x4c ,BANKED
	movlw    0xa
	movwf    0x4d ,BANKED
	movlw    0x47
	movwf    0x4e ,BANKED
	movlw    0x88
	movwf    0x4f ,BANKED
	movlw    0xcd
	movwf    0x50 ,BANKED
	movlw    0x17
	movwf    0x51 ,BANKED
	movlw    0x64
	movwf    0x52 ,BANKED
	movlw    0xb6
	movwf    0x53 ,BANKED
	movlw    0xd
	movwf    0x54 ,BANKED
	movlb    0x01    ; bsr reset to bank 0
	return

	end