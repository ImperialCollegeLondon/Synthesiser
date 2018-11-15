#include p18f87k22.inc

    global  keypad_read_rows, keypad_read_columns, get_slope  
    
    
acs0	udata_acs   ; reserve data space in access ram
	
counter		res 1   ; reserve one byte for a counter variable
accum		res 1
wav_sel		res 1
tri		res 1   ; reserve one byte for selecting up/down for triangle wave
output		res 1
slope		res 1
input		res 1
delay_count	res 1   ; reserve one byte for counter in the delay routine
keypadval	res 1
UART_counter	res 1	    ; reserve 1 byte for variable UART_counter
    
    
    
   
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

	
	end