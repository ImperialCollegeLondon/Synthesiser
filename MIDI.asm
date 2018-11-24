#include p18f87k22.inc

    global  receive_midi, slopeH, slopeL 
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
	movlw	0x90
	cpfslt	status			; checks if status is not key on
	bra	note_off	
	call	UART_Receive_Byte	; receive the note byte		
	movwf	note			; put it into note 
	call	UART_Receive_Byte	; clear velocity byte flag
	call	get_midi_slope		; get slopeL/H stored at MIDI note no.
	movlw	0x01
	movwf	input			; set the input as 0x01, meaning there..
	return				; ..is an input
note_off
	call	UART_Receive_Byte	; clear 2 bytes flags
	call	UART_Receive_Byte
	movlw	0x00
	movwf	input			; set input to 0x00 meaning, there is no input
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


	end
