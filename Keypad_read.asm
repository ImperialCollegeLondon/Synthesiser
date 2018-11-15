#include p18f87k22.inc

    global  keypad_read_rows, keypad_read_columns, get_slope, Slope_Setup 
    extern	counter, accum, wav_sel, tri, output, slope, input, delay_count, keypadval
    
    
   
Keypad  code
    
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

	return
	

	
	end