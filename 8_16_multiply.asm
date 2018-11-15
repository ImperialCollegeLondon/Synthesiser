#include p18f87k22.inc

	global  multiply816, multiply1616, multiply824

acs0	udata_acs   ; reserve data space in access ram
highbyte    res 1   ; reserve one byte for a high byte variable
lowbyte	    res 1   ; reserve one byte for a low byte variable
	    
; 8 by 24 product results
upperpr	    res 1
highpr	    res 1 	    
middlepr    res 1
lowpr	    res 1    
; 8 by 16 product results
highp   res 1 	    
middlep  res 1
lowp    res 1
;16 by 16 product result (32 bit)
upperprod   res 1
highprod    res 1 	    
middleprod  res 1
lowprod	    res 1
; variables for the 8 by 16 bit multiplier
_8bit_num   res 1   
; input numbers for multiplying:
num_1	    res 1
num_1_high  res 1
num_1_low   res 1
num_2_high  res 1
num_2_middle  res 1  
num_2_low   res 1	    
   
   
main	code	    

number_setup
    movlw   0x41	
    movwf   num_1_high
    movlw   0x8A
    movwf   num_1_low
    movlw   0x04
    movwf   num_2_high
    movlw   0xD2
    movwf   num_2_low

number_setup_824
    movlw   0x41	
    movwf   num_1
    movlw   0x8A
    movwf   num_2_low
    movlw   0x04
    movwf   num_2_middle
    movlw   0xD2
    movwf   num_2_high
    return
    


multiply824    ;16 bit by 16 bit multiplier
    call    number_setup_824
    movlw   0x0
    movwf   upperpr
    movf    num_1, 0, 0
    mulwf   num_2_low	    ;multiply W by lowbyte
    movff   PRODL, lowpr
    nop
    movff   PRODH, middlepr
    nop
    
    movf    num_1, 0, 0
    mulwf   num_2_middle	    ;multiply W by lowbyte
    movf    PRODL,  0, 0
    addwfc  middlepr
    nop
    movff   PRODH, highpr
    nop
    
    movf    num_1, 0, 0
    mulwf   num_2_high	    ;multiply W by lowbyte
    movf    PRODL, 0, 0
    addwfc  highpr
    nop
    movf    PRODH, 0, 0
    addwfc  upperpr
    nop
    return
     
    
multiply1616	    ;16 bit by 16 bit multiplier
    movff   num_1_low, _8bit_num
    call    multiply816
    movff   lowp, lowprod
    movff   middlep, middleprod
    movff   highp, highprod

    movlw   0x00
    movwf   upperprod
    
    movff   num_1_high, _8bit_num
    call    multiply816
    movf    lowp, 0, 0
    addwfc  middleprod
    movf    middlep, 0, 0
    addwfc  highprod
    movf    highp, 0, 0
    addwfc  upperprod
    
multiply816 ;multiply an 8 bit by a 16 bit
    movf    _8bit_num, 0, 0
    mulwf   num_2_low	    ;multiply W by lowbyte
    movff   PRODL, lowp
    nop
    movff   PRODH, middlep
    nop
    
    mulwf   num_2_high	    ;multiply W by highbyte
    movf    PRODL, 0, 0	    ;move the lower byte of the multiplication to W
    addwfc  middlep	    ;add W to middleprod
    nop
    movff   PRODH, highp
    nop

    return
    
    end
    
