#include p18f87k22.inc

    global  SPI_MasterInit, SPI_MasterTransmit

    
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
    
    
    
    
SPI   code
    
SPI_MasterInit	; Set Clock edge to positive
	bcf	SSP2STAT, CKE
	; MSSP enable; CKP=1; SPI master, clock=Fosc/64 (1MHz)
	movlw 	(1<<SSPEN)|(1<<CKP)|(0x02)
	movwf 	SSP2CON1
	; SDO2 output; SCK2 output
	bcf	TRISD, SDO2
	bcf	TRISD, SCK2
	return	

SPI_MasterTransmit  ; Start transmission of data (held in W)
	movwf 	SSP2BUF
	call    delay; DO NOT SEEM TO SET DELAY!!!!!
Wait_Transmit	; Wait for transmission to complete 
	btfss 	PIR2, SSP2IF
	bra 	Wait_Transmit
	bcf 	PIR2, SSP2IF	; clear interrupt flag
	return
	
	

; a delay subroutine if you need one, times around loop in delay_count
delay	decfsz	delay_count	; decrement until zero	
	bra delay
	return

	
	
    end


