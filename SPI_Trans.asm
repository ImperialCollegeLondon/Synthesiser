#include p18f87k22.inc

    global  SPI_MasterInit, transmit
    extern  wav_sel, input, get_output, output
   
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
	
transmit
	movlw	0x01
	cpfslt	PORTJ, ACCESS	; want to stay at current waveform if PORTJ is 0
	movff	PORTJ, wav_sel	; save wav_sel
	movlw	0x01
	cpfslt	input		; check if there is an input
	call	get_output	; hopefully this delay isnt a problem
	movlw	0x00
	movwf	PORTH		; set CS low
	movlw	0x50		; send zero for upper nibble data (only 1 note)
	call	SPI_MasterTransmit  ;takes data in through W
	movf	output, W
	call	SPI_MasterTransmit  ;takes data in through W
	movlw	0x01		 ; set CS high
	movwf	PORTH
	
	return	
	
	
SPI_MasterTransmit  ; Start transmission of data (held in W)
	movwf 	SSP2BUF
Wait_Transmit	; Wait for transmission to complete 
	btfss 	PIR2, SSP2IF
	bra 	Wait_Transmit
	bcf 	PIR2, SSP2IF	; clear interrupt flag
	return
	

		
    end


