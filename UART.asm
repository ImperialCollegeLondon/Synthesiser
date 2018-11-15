#include p18f87k22.inc

    global  UART_Setup, UART_Receive_Byte
    extern  counter, accumH, accumL, wav_sel, tri, output, slopeH, slopeL, input, delay_count


UART    code
        
    
UART_Setup
    bcf	    TXSTA1, SYNC    ; synchronous  - asynchronous
    bcf	    TXSTA1, BRGH    ; slow speed    - BRGH low	
    bcf	    BAUDCON1, BRG16 ; 8-bit generator only 
    movlw   .31		    ; gives 31250 Baud rate
    movwf   SPBRG1
    bsf	    TRISC, RX1	    ; RX1 pin as input
    clrf    RCSTA1
    bsf	    RCSTA1, SPEN    ; enable
    bsf	    RCSTA1, CREN    ; continuous receive enable
    return

;UART_Receive_Message	    ; Message stored at FSR2, length stored in W
;    movwf   UART_counter
;UART_Loop_message
;    call    UART_Receive_Byte
;    movwf   POSTINC2
;    decfsz  UART_counter
;    bra	    UART_Loop_message
;    return

    
    
    
    
    
UART_Receive_Byte  
    btfss   PIR1,RC1IF	    ; RC1IF is set when RCREG1 is full (cleared when read)
    bra	    UART_Receive_Byte
    movf    RCREG1, W
    return
    
    


    end
    end


