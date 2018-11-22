#include p18f87k22.inc

    global  get_output, accumulate, sawtooth, square, sqr_zero
    global  triangle, sine
    extern  slopeH, slopeL, UART_Receive_Byte, output, wav_sel
   
    
acs0	udata_acs   ; reserve data space in access ram
	
accumH		res 1	; the accumulator high byte	
accumL		res 1	; the accumulator  low byte
tri		res 1   ; for selecting up/down for triangle wave
		
Accumu	code

get_output
	call	accumulate	; adds slope to the accumulator
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
	bra	sawtooth	; press 0th bit button
	movlw	0x02
	cpfsgt	wav_sel, ACCESS 
	bra	square		; press 1st bit button
	movlw	0x04
	cpfsgt	wav_sel, ACCESS 
	bra	triangle	; press 2nd bit button
	movlw	0x08
	cpfsgt	wav_sel, ACCESS 
	bra	sine		; press 3rd bit button
	bra	sawtooth	; if a higher button is pressed then sawtooth
	return
	
	
sawtooth	; sawtooth is just the high byte of the accumulator
	movf accumH, W
	return 

	
square		; uses midpoint of accumulator to switch between 0 or ff
	movlw	0x7f	    ; midpoint of accumulator
	cpfsgt	accumH
	bra	sqr_zero 
	movlw	0xff	    ; square wave max amplitude
	return
sqr_zero
	movlw	0x00
	return
	
	
triangle	; doubles freq of accum, then alternates between outputting...
	call	accumulate
	movf	accumH	    ;..the accumulator and ff minus accumulator
	subfwb	slopeH, W
	cpfslt	accumH	    ; make change of direction if accumulator has.. 
	call	up_down	    ; ..reached its peak ie. now it is 0x00
	
	
	movlw	0x02
	cpfsgt	tri	    ; 0=up, 3=down
	bra	sawtooth
	movlw	0xff	    ; max value of accumulator
	subfwb	accumH, W
	return
up_down			    ; make decision whether to go up or down at peak
	movlw	0x02	    ; of accumulator
	cpfsgt	tri	    ; tri = 0x00 went up now go down
	bra	up	    ; tri = 0x03 went down now go up
	bra	down
up	    ; switch from up to down
	movlw	0x03	    ; now go down
	movwf	tri
	return
down	    ; switch from down to up
	movlw	0x00	    ; now go up
	movwf	tri
	return	
	
sine		; use accum to point to a table of sine values
	movlw	0x02		; set to Bank 2
	movwf	FSR2H
	movff	accumH, FSR2L	; put accum into FSR2L for looking up sine
	movf    INDF2, W	; Read contents of address in FSR2 no increment
	return
	
	
	end
