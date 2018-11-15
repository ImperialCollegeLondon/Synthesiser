#include p18f87k22.inc

    global  MIDI_Setup, get_midi_slope, note_off
    extern  counter, accum, wav_sel, tri, output, slope, input, delay_count, keypadval, UART_Receive_Byte, output_zero, UART_Receive_Byte, buffer
    

MIDI	code

get_midi_slope
	movf	POSTINC1, W
	movwf   FSR2L	
	movlw	0x01
	movwf	FSR2H	
	movf    INDF2, W	;Read contents of address in FSR2 not changing it
	movwf	slope
	; reseting FSR1 when it gets to end of buffer
	movlw	0x01
	addwf	counter
	movlw	0x80
	cpfsgt	counter
	return
	lfsr	FSR1, buffer
	movlw	0x00
	movwf	counter
	return
		

	
note_off
	; clear 2 bytes
	call	UART_Receive_Byte
	call	UART_Receive_Byte
	movlb	0x00
	movlw	0x01
	cpfslt	PORTJ, ACCESS	; want to stay at current waveform	
	movff	PORTJ, wav_sel	; save wav_sel
	goto	output_zero
		
	
	

	
	
  
MIDI_Setup	    ; save all the slopes at address which is coordinate on keypad
	movlb	 0x01
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
	movlb	 0x00
	return


	end