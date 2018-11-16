#include p18f87k22.inc

    global  get_output, accumulate, waveform_select, sawtooth, square
    global  sqr_zero, triangle, sine
    extern  counter, slopeH, slopeL, UART_Receive_Byte
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


waveform_select
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
	
	
sawtooth;_16
	movf accumH, W
	return 

	
square;_16	;conditions for the square wave value based on accum
	movlw	0x80	    ; midpoint of accumulator
	cpfsgt	accumH
	goto	sqr_zero 
	movlw	0xff	    ; square wave max amplitude
	return
sqr_zero;_16
	movlw	0x00
	return
	
	
triangle;_16
	movf	slopeH
	cpfsgt	accumH	    ; make change of direction if accumulator has reached
	call	up_down	    ; its peak ie. now it is 0x00
	call	accumulate
	movlw	0x02
	cpfsgt	tri	    ; 0=up, 3=down
	goto	sawtooth
	movlw	0xff	    ; max value of accumulator
	subfwb	accumH, W
	return
up_down;_16		    ; make decision whether to go up or down at peak
	movlw	0x02	    ; of accumulator
	cpfsgt	tri	    ; tri = 0x00 went up now go down
	goto	up	    ; tri = 0x03 went down now go up
	goto	down
up;_16
	movlw	0x03	    ; now go down
	movwf	tri
	return
down;_16
	movlw	0x00	    ; now go up
	movwf	tri
	return	
	
sine;_16	;look up sine valuein table corresponding to the value of accum
	movlw	0x02		; set BSR to Bank 1
	movwf	FSR2H
	movff	accumH, FSR2L
	nop
	movf    INDF2, W	;Read contents of address in FSR2 not changing it
	nop
	return
	
	
	end