#include p18f87k22.inc

    global  Slope_Setup
    
    

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
   
    
   
    
Slope   code
    
Slope_Setup	    ; save all the slopes at address which is coordinate on keypad

	movlw	0x0B		; slopes must correspond to particular freqs
	movwf	0x77		; 1
	movlw	0x0C	
	movwf	0xB7		; 2
	movlw	0x0D	
	movwf	0xD7		; 3
	movlw	0x0E	
	movwf	0xE7		; F
	movlw	0x0F	
	movwf	0x7B		; 4
	movlw	0x10	
	movwf	0xBB		; 5
	movlw	0x11	
	movwf	0xDB		; 6
	movlw	0x12	
	movwf	0xEB		; E
	movlw	0x13	
	movwf	0x7D		; 7
	movlw	0x14	
	movwf	0xBD		; 8
	movlw	0x15	
	movwf	0xDD		; 9
	movlw	0x16	
	movwf	0xED		; D
	movlw	0x17	
	movwf	0x7E		; A
	movlw	0x18	
	movwf	0xBE		; 0
	movlw	0x19	
	movwf	0xDE		; B
	movlw	0x1a	
	movwf	0xEE		; C

	return

	
	end
