#include p18f87k22.inc

    global  UART_Setup, UART_Transmit_Message

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

UART_Receive_Byte	    ; Transmits byte stored in W
    btfss   PIR1,RC1IF	    ; RC1IF is set when RCREG1 is full (cleared when read)
    bra	    UART_Receive_Byte
    movf    RCREG1, W
    return

    end
    end


