#include p18f87k22.inc

    global  UART_Setup, UART_Receive_Message

acs0    udata_acs	    ; named variables in access ram
UART_counter res 1	    ; reserve 1 byte for variable UART_counter

UART    code
    
UART_Setup
    bsf	    RCSTA1, SPEN    ; enable
    bcf	    TXSTA1, SYNC    ; synchronous  - asynchronous
    bcf	    TXSTA1, BRGH    ; slow speed    - BRGH low	
    bcf	    BAUDCON1, BRG16 ; 8-bit generator only 
    movlw   .31		    ; gives 31250 Baud rate
    movwf   SPBRG1
    bsf	    TRISC, RX1	    ; RX1 pin as input
    return

UART_Receive_Message	    ; Message stored at FSR2, length stored in W
    movwf   UART_counter
UART_Loop_message
    movf    POSTINC2, W
    call    UART_Receive_Byte
    decfsz  UART_counter
    bra	    UART_Loop_message
    return

UART_Receive_Byte	    ; Transmits byte stored in W
    btfss   PIR1,RC1IF	    ; RC1IF is set when RCREG1 is full (cleared when read)
    bra	    UART_Receive_Byte
    movwf   RCREG1
    return

    end
