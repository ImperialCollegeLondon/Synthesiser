#include p18f87k22.inc

    global  UART_Setup, UART_Receive_Byte

UART    code
        
    
UART_Setup
    bcf	    TXSTA1, SYNC    ; synchronous  - asynchronous
    bcf	    TXSTA1, BRGH    ; slow speed    - BRGH low	
    bcf	    BAUDCON1, BRG16 ; 8-bit generator only 
    movlw   .31		    ; gives 31250 Baud rate
    movwf   SPBRG1	    ; sets Baud rate
    bsf	    TRISC, RX1	    ; RX1 pin as input
    clrf    RCSTA1	    ; ensure all bits are zero before enabling:
    bsf	    RCSTA1, SPEN    ; enable
    bsf	    RCSTA1, CREN    ; continuous receive enable
    return

    
UART_Receive_Byte  
    btfss   PIR1,RC1IF	    ; RC1IF is set when RCREG1 is full
    bra	    UART_Receive_Byte	; wait for flag
    movf    RCREG1, W		; move out to RCREG1 to clear flag
    return
    
 
    end


