#include p18f87k22.inc

    global  MIDI_Setup, get_midi_slope, note_off
    extern  counter, accum, wav_sel, tri, output, slope, input, delay_count, keypadval, UART_Receive_Byte, output_zero, UART_Receive_Byte, buffer
    

MIDI	code

get_midi_slope
	movff	POSTINC1, FSR2L
	movlw	0x01
	movwf	FSR2H	
	movf    INDF2, W	;Read contents of address in FSR2 not changing it
	movwf	slope
	; reseting FSR1 when it gets to end of buffer
	movlw	0x01
	addwf	counter
	movlw	0x80
	cpfslt	counter
	lfsr	FSR1, buffer	
	return	
	
note_off
	; clear 2 bytes
	call	UART_Receive_Byte
	call	UART_Receive_Byte
	goto	output_zero
		
	
	
	
	
	
	
	
  
MIDI_Setup	    ; save all the slopes at address which is coordinate on keypad
	movlb	 0x01
	movlw	 0x1
	movwf    0x24
	movlw    0x1
	movwf    0x25
	movlw    0x1
	movwf    0x26
	movlw    0x1
	movwf    0x27
	movlw    0x2
	movwf    0x28
	movlw    0x2
	movwf    0x29
	movlw    0x2
	movwf    0x2a
	movlw    0x2
	movwf    0x2b
	movlw    0x2
	movwf    0x2c
	movlw    0x2
	movwf    0x2d
	movlw    0x2
	movwf    0x2e
	movlw    0x3
	movwf    0x2f
	movlw    0x3
	movwf    0x30
	movlw    0x3
	movwf    0x31
	movlw    0x3
	movwf    0x32
	movlw    0x3
	movwf    0x33
	movlw    0x4
	movwf    0x34
	movlw    0x4
	movwf    0x35
	movlw    0x4
	movwf    0x36
	movlw    0x4
	movwf    0x37
	movlw    0x5
	movwf    0x38
	movlw    0x5
	movwf    0x39
	movlw    0x5
	movwf    0x3a
	movlw    0x6
	movwf    0x3b
	movlw    0x6
	movwf    0x3c
	movlw    0x7
	movwf    0x3d
	movlw    0x7
	movwf    0x3e
	movlw    0x7
	movwf    0x3f
	movlw    0x8
	movwf    0x40
	movlw    0x8
	movwf    0x41
	movlw    0x9
	movwf    0x42
	movlw    0x9
	movwf    0x43
	movlw    0xa
	movwf    0x44
	movlw    0xb
	movwf    0x45
	movlw    0xb
	movwf    0x46
	movlw    0xc
	movwf    0x47
	movlw    0xd
	movwf    0x48
	movlw    0xe
	movwf    0x49
	movlw    0xe
	movwf    0x4a
	movlw    0xf
	movwf    0x4b
	movlw    0x10
	movwf    0x4c
	movlw    0x11
	movwf    0x4d
	movlw    0x12
	movwf    0x4e
	movlw    0x13
	movwf    0x4f
	movlw    0x15
	movwf    0x50
	movlw    0x16
	movwf    0x51
	movlw    0x17
	movwf    0x52
	movlw    0x19
	movwf    0x53
	movlw    0x1a
	movwf    0x54
	movlb	 0x00
	return


	end