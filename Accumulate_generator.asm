#include p18f87k22.inc

    global  get_output, accumulate, waveform_select, sawtooth, square
    global  sqr_zero, triangle, sine
    extern  slopeH, slopeL, UART_Receive_Byte
    extern  accumH, accumL, output, wav_sel, tri
    

Accumu	code

get_output
	call	accumulate	; adds slope to the accumulator, if it becomes
				; greater than the max_acc then reset accum to zero
	call	waveform_select	; selects waveform and makes W value to output
	movwf	output
	return
	
	

accumulate
	movf	slopeL, W
	addwfc	accumL, F	 ; adds slope to the accumulator
	movf	slopeH, W
	addwfc	accumH, F
	return


waveform_select	; uses conditions to choose the waveform
	movlw	0x01
	cpfsgt	wav_sel, ACCESS
	goto	sawtooth	; press 0th bit button
	movlw	0x02
	cpfsgt	wav_sel, ACCESS 
	goto	square		; press 1st bit button
	movlw	0x04
	cpfsgt	wav_sel, ACCESS 
	goto	triangle	; press 2nd bit button
	movlw	0x08
	cpfsgt	wav_sel, ACCESS 
	goto	sine		; press 3rd bit button
	goto	sawtooth	; if a higher button is pressed then sawtooth
	return
	
	
sawtooth	; sawtooth is just the high byte of the accumulator
	movf accumH, W
	return 

	
square		; uses midpoint of accumulator to switch between 0 or ff
	movlw	0x80	    ; midpoint of accumulator
	cpfsgt	accumH
	goto	sqr_zero 
	movlw	0xff	    ; square wave max amplitude
	return
sqr_zero
	movlw	0x00
	return
	
	
triangle	; doubles freq of accum, then alternates between outputting...
	movf	slopeH	    ;..the accumulator and ff minus accumulator
	cpfsgt	accumH	    ; make change of direction if accumulator has reached
	call	up_down	    ; its peak ie. now it is 0x00
	call	accumulate
	movlw	0x02
	cpfsgt	tri	    ; 0=up, 3=down
	goto	sawtooth
	movlw	0xff	    ; max value of accumulator
	subfwb	accumH, W
	return
up_down			    ; make decision whether to go up or down at peak
	movlw	0x02	    ; of accumulator
	cpfsgt	tri	    ; tri = 0x00 went up now go down
	goto	up	    ; tri = 0x03 went down now go up
	goto	down
up	    ; switch from up to down
	movlw	0x03	    ; now go down
	movwf	tri
	return
down	    ; switch from down to up
	movlw	0x00	    ; now go up
	movwf	tri
	return	
	
sine		; use accum to point to a table of sine values
	movlw	0x02		; set BSR to Bank 2
	movwf	FSR2H
	movff	accumH, FSR2L
	nop
	movf    INDF2, W	; Read contents of address in FSR2 no increment
	nop
	return
	
	
	end