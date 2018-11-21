#include p18f87k22.inc

    global  Sine_Setup, Slope_Setup    
   
Tables    code

    
Slope_Setup    ; save all the slopes at address equal to the MIDI note number
	movlb    0x01    ; slope low bytes stored in bank 1
	movlw    0x0
	movwf    0x24 ,BANKED
	movlw    0x0
	movwf    0x25 ,BANKED
	movlw    0x0
	movwf    0x26 ,BANKED
	movlw    0x0
	movwf    0x27 ,BANKED
	movlw    0x0
	movwf    0x28 ,BANKED
	movlw    0x0
	movwf    0x29 ,BANKED
	movlw    0x0
	movwf    0x2a ,BANKED
	movlw    0x0
	movwf    0x2b ,BANKED
	movlw    0x0
	movwf    0x2c ,BANKED
	movlw    0x0
	movwf    0x2d ,BANKED
	movlw    0x0
	movwf    0x2e ,BANKED
	movlw    0x0
	movwf    0x2f ,BANKED
	movlw    0x0
	movwf    0x30 ,BANKED
	movlw    0x0
	movwf    0x31 ,BANKED
	movlw    0x0
	movwf    0x32 ,BANKED
	movlw    0x0
	movwf    0x33 ,BANKED
	movlw    0x0
	movwf    0x34 ,BANKED
	movlw    0x1
	movwf    0x35 ,BANKED
	movlw    0x1
	movwf    0x36 ,BANKED
	movlw    0x1
	movwf    0x37 ,BANKED
	movlw    0x1
	movwf    0x38 ,BANKED
	movlw    0x1
	movwf    0x39 ,BANKED
	movlw    0x1
	movwf    0x3a ,BANKED
	movlw    0x1
	movwf    0x3b ,BANKED
	movlw    0x1
	movwf    0x3c ,BANKED
	movlw    0x1
	movwf    0x3d ,BANKED
	movlw    0x1
	movwf    0x3e ,BANKED
	movlw    0x1
	movwf    0x3f ,BANKED
	movlw    0x1
	movwf    0x40 ,BANKED
	movlw    0x2
	movwf    0x41 ,BANKED
	movlw    0x2
	movwf    0x42 ,BANKED
	movlw    0x2
	movwf    0x43 ,BANKED
	movlw    0x2
	movwf    0x44 ,BANKED
	movlw    0x2
	movwf    0x45 ,BANKED
	movlw    0x2
	movwf    0x46 ,BANKED
	movlw    0x2
	movwf    0x47 ,BANKED
	movlw    0x3
	movwf    0x48 ,BANKED
	movlw    0x3
	movwf    0x49 ,BANKED
	movlw    0x3
	movwf    0x4a ,BANKED
	movlw    0x3
	movwf    0x4b ,BANKED
	movlw    0x3
	movwf    0x4c ,BANKED
	movlw    0x4
	movwf    0x4d ,BANKED
	movlw    0x4
	movwf    0x4e ,BANKED
	movlw    0x4
	movwf    0x4f ,BANKED
	movlw    0x4
	movwf    0x50 ,BANKED
	movlw    0x5
	movwf    0x51 ,BANKED
	movlw    0x5
	movwf    0x52 ,BANKED
	movlw    0x5
	movwf    0x53 ,BANKED
	movlw    0x6
	movwf    0x54 ,BANKED



	movlb    0x03    ; slope high bytes stored in bank 3
	movlw    0x60
	movwf    0x24 ,BANKED
	movlw    0x66
	movwf    0x25 ,BANKED
	movlw    0x6c
	movwf    0x26 ,BANKED
	movlw    0x72
	movwf    0x27 ,BANKED
	movlw    0x79
	movwf    0x28 ,BANKED
	movlw    0x80
	movwf    0x29 ,BANKED
	movlw    0x88
	movwf    0x2a ,BANKED
	movlw    0x90
	movwf    0x2b ,BANKED
	movlw    0x99
	movwf    0x2c ,BANKED
	movlw    0xa2
	movwf    0x2d ,BANKED
	movlw    0xab
	movwf    0x2e ,BANKED
	movlw    0xb6
	movwf    0x2f ,BANKED
	movlw    0xc0
	movwf    0x30 ,BANKED
	movlw    0xcc
	movwf    0x31 ,BANKED
	movlw    0xd8
	movwf    0x32 ,BANKED
	movlw    0xe5
	movwf    0x33 ,BANKED
	movlw    0xf3
	movwf    0x34 ,BANKED
	movlw    0x2
	movwf    0x35 ,BANKED
	movlw    0x11
	movwf    0x36 ,BANKED
	movlw    0x22
	movwf    0x37 ,BANKED
	movlw    0x33
	movwf    0x38 ,BANKED
	movlw    0x45
	movwf    0x39 ,BANKED
	movlw    0x58
	movwf    0x3a ,BANKED
	movlw    0x6d
	movwf    0x3b ,BANKED
	movlw    0x82
	movwf    0x3c ,BANKED
	movlw    0x99
	movwf    0x3d ,BANKED
	movlw    0xb2
	movwf    0x3e ,BANKED
	movlw    0xcb
	movwf    0x3f ,BANKED
	movlw    0xe7
	movwf    0x40 ,BANKED
	movlw    0x5
	movwf    0x41 ,BANKED
	movlw    0x23
	movwf    0x42 ,BANKED
	movlw    0x44
	movwf    0x43 ,BANKED
	movlw    0x66
	movwf    0x44 ,BANKED
	movlw    0x8b
	movwf    0x45 ,BANKED
	movlw    0xb1
	movwf    0x46 ,BANKED
	movlw    0xda
	movwf    0x47 ,BANKED
	movlw    0x6
	movwf    0x48 ,BANKED
	movlw    0x34
	movwf    0x49 ,BANKED
	movlw    0x65
	movwf    0x4a ,BANKED
	movlw    0x98
	movwf    0x4b ,BANKED
	movlw    0xcf
	movwf    0x4c ,BANKED
	movlw    0xa
	movwf    0x4d ,BANKED
	movlw    0x47
	movwf    0x4e ,BANKED
	movlw    0x88
	movwf    0x4f ,BANKED
	movlw    0xcd
	movwf    0x50 ,BANKED
	movlw    0x17
	movwf    0x51 ,BANKED
	movlw    0x64
	movwf    0x52 ,BANKED
	movlw    0xb6
	movwf    0x53 ,BANKED
	movlw    0xd
	movwf    0x54 ,BANKED
	movlb    0x01    ; bsr reset to bank 0
	return
    
    
Sine_Setup	    ; save sine values from 0 to 2pi at consectutive addresses
	movlb	 0x2		; save in BANK 2
	movlw    0x7f
	movwf    0x0 , BANKED
	movlw    0x82
	movwf    0x1 , BANKED
	movlw    0x85
	movwf    0x2 , BANKED
	movlw    0x88
	movwf    0x3 , BANKED
	movlw    0x8b
	movwf    0x4 , BANKED
	movlw    0x8f
	movwf    0x5 , BANKED
	movlw    0x92
	movwf    0x6 , BANKED
	movlw    0x95
	movwf    0x7 , BANKED
	movlw    0x98
	movwf    0x8 , BANKED
	movlw    0x9b
	movwf    0x9 , BANKED
	movlw    0x9e
	movwf    0xa , BANKED
	movlw    0xa1
	movwf    0xb , BANKED
	movlw    0xa4
	movwf    0xc , BANKED
	movlw    0xa7
	movwf    0xd , BANKED
	movlw    0xaa
	movwf    0xe , BANKED
	movlw    0xad
	movwf    0xf , BANKED
	movlw    0xb0
	movwf    0x10 , BANKED
	movlw    0xb2
	movwf    0x11 , BANKED
	movlw    0xb5
	movwf    0x12 , BANKED
	movlw    0xb8
	movwf    0x13 , BANKED
	movlw    0xbb
	movwf    0x14 , BANKED
	movlw    0xbe
	movwf    0x15 , BANKED
	movlw    0xc0
	movwf    0x16 , BANKED
	movlw    0xc3
	movwf    0x17 , BANKED
	movlw    0xc6
	movwf    0x18 , BANKED
	movlw    0xc8
	movwf    0x19 , BANKED
	movlw    0xcb
	movwf    0x1a , BANKED
	movlw    0xcd
	movwf    0x1b , BANKED
	movlw    0xd0
	movwf    0x1c , BANKED
	movlw    0xd2
	movwf    0x1d , BANKED
	movlw    0xd4
	movwf    0x1e , BANKED
	movlw    0xd7
	movwf    0x1f , BANKED
	movlw    0xd9
	movwf    0x20 , BANKED
	movlw    0xdb
	movwf    0x21 , BANKED
	movlw    0xdd
	movwf    0x22 , BANKED
	movlw    0xdf
	movwf    0x23 , BANKED
	movlw    0xe1
	movwf    0x24 , BANKED
	movlw    0xe3
	movwf    0x25 , BANKED
	movlw    0xe5
	movwf    0x26 , BANKED
	movlw    0xe7
	movwf    0x27 , BANKED
	movlw    0xe9
	movwf    0x28 , BANKED
	movlw    0xea
	movwf    0x29 , BANKED
	movlw    0xec
	movwf    0x2a , BANKED
	movlw    0xee
	movwf    0x2b , BANKED
	movlw    0xef
	movwf    0x2c , BANKED
	movlw    0xf0
	movwf    0x2d , BANKED
	movlw    0xf2
	movwf    0x2e , BANKED
	movlw    0xf3
	movwf    0x2f , BANKED
	movlw    0xf4
	movwf    0x30 , BANKED
	movlw    0xf5
	movwf    0x31 , BANKED
	movlw    0xf7
	movwf    0x32 , BANKED
	movlw    0xf8
	movwf    0x33 , BANKED
	movlw    0xf9
	movwf    0x34 , BANKED
	movlw    0xf9
	movwf    0x35 , BANKED
	movlw    0xfa
	movwf    0x36 , BANKED
	movlw    0xfb
	movwf    0x37 , BANKED
	movlw    0xfc
	movwf    0x38 , BANKED
	movlw    0xfc
	movwf    0x39 , BANKED
	movlw    0xfd
	movwf    0x3a , BANKED
	movlw    0xfd
	movwf    0x3b , BANKED
	movlw    0xfd
	movwf    0x3c , BANKED
	movlw    0xfe
	movwf    0x3d , BANKED
	movlw    0xfe
	movwf    0x3e , BANKED
	movlw    0xfe
	movwf    0x3f , BANKED
	movlw    0xfe
	movwf    0x40 , BANKED
	movlw    0xfe
	movwf    0x41 , BANKED
	movlw    0xfe
	movwf    0x42 , BANKED
	movlw    0xfe
	movwf    0x43 , BANKED
	movlw    0xfd
	movwf    0x44 , BANKED
	movlw    0xfd
	movwf    0x45 , BANKED
	movlw    0xfd
	movwf    0x46 , BANKED
	movlw    0xfc
	movwf    0x47 , BANKED
	movlw    0xfc
	movwf    0x48 , BANKED
	movlw    0xfb
	movwf    0x49 , BANKED
	movlw    0xfa
	movwf    0x4a , BANKED
	movlw    0xf9
	movwf    0x4b , BANKED
	movlw    0xf9
	movwf    0x4c , BANKED
	movlw    0xf8
	movwf    0x4d , BANKED
	movlw    0xf7
	movwf    0x4e , BANKED
	movlw    0xf5
	movwf    0x4f , BANKED
	movlw    0xf4
	movwf    0x50 , BANKED
	movlw    0xf3
	movwf    0x51 , BANKED
	movlw    0xf2
	movwf    0x52 , BANKED
	movlw    0xf0
	movwf    0x53 , BANKED
	movlw    0xef
	movwf    0x54 , BANKED
	movlw    0xee
	movwf    0x55 , BANKED
	movlw    0xec
	movwf    0x56 , BANKED
	movlw    0xea
	movwf    0x57 , BANKED
	movlw    0xe9
	movwf    0x58 , BANKED
	movlw    0xe7
	movwf    0x59 , BANKED
	movlw    0xe5
	movwf    0x5a , BANKED
	movlw    0xe3
	movwf    0x5b , BANKED
	movlw    0xe1
	movwf    0x5c , BANKED
	movlw    0xdf
	movwf    0x5d , BANKED
	movlw    0xdd
	movwf    0x5e , BANKED
	movlw    0xdb
	movwf    0x5f , BANKED
	movlw    0xd9
	movwf    0x60 , BANKED
	movlw    0xd7
	movwf    0x61 , BANKED
	movlw    0xd4
	movwf    0x62 , BANKED
	movlw    0xd2
	movwf    0x63 , BANKED
	movlw    0xd0
	movwf    0x64 , BANKED
	movlw    0xcd
	movwf    0x65 , BANKED
	movlw    0xcb
	movwf    0x66 , BANKED
	movlw    0xc8
	movwf    0x67 , BANKED
	movlw    0xc6
	movwf    0x68 , BANKED
	movlw    0xc3
	movwf    0x69 , BANKED
	movlw    0xc0
	movwf    0x6a , BANKED
	movlw    0xbe
	movwf    0x6b , BANKED
	movlw    0xbb
	movwf    0x6c , BANKED
	movlw    0xb8
	movwf    0x6d , BANKED
	movlw    0xb5
	movwf    0x6e , BANKED
	movlw    0xb2
	movwf    0x6f , BANKED
	movlw    0xb0
	movwf    0x70 , BANKED
	movlw    0xad
	movwf    0x71 , BANKED
	movlw    0xaa
	movwf    0x72 , BANKED
	movlw    0xa7
	movwf    0x73 , BANKED
	movlw    0xa4
	movwf    0x74 , BANKED
	movlw    0xa1
	movwf    0x75 , BANKED
	movlw    0x9e
	movwf    0x76 , BANKED
	movlw    0x9b
	movwf    0x77 , BANKED
	movlw    0x98
	movwf    0x78 , BANKED
	movlw    0x95
	movwf    0x79 , BANKED
	movlw    0x92
	movwf    0x7a , BANKED
	movlw    0x8f
	movwf    0x7b , BANKED
	movlw    0x8b
	movwf    0x7c , BANKED
	movlw    0x88
	movwf    0x7d , BANKED
	movlw    0x85
	movwf    0x7e , BANKED
	movlw    0x82
	movwf    0x7f , BANKED
	movlw    0x7f
	movwf    0x80 , BANKED
	movlw    0x7c
	movwf    0x81 , BANKED
	movlw    0x79
	movwf    0x82 , BANKED
	movlw    0x76
	movwf    0x83 , BANKED
	movlw    0x73
	movwf    0x84 , BANKED
	movlw    0x6f
	movwf    0x85 , BANKED
	movlw    0x6c
	movwf    0x86 , BANKED
	movlw    0x69
	movwf    0x87 , BANKED
	movlw    0x66
	movwf    0x88 , BANKED
	movlw    0x63
	movwf    0x89 , BANKED
	movlw    0x60
	movwf    0x8a , BANKED
	movlw    0x5d
	movwf    0x8b , BANKED
	movlw    0x5a
	movwf    0x8c , BANKED
	movlw    0x57
	movwf    0x8d , BANKED
	movlw    0x54
	movwf    0x8e , BANKED
	movlw    0x51
	movwf    0x8f , BANKED
	movlw    0x4e
	movwf    0x90 , BANKED
	movlw    0x4c
	movwf    0x91 , BANKED
	movlw    0x49
	movwf    0x92 , BANKED
	movlw    0x46
	movwf    0x93 , BANKED
	movlw    0x43
	movwf    0x94 , BANKED
	movlw    0x40
	movwf    0x95 , BANKED
	movlw    0x3e
	movwf    0x96 , BANKED
	movlw    0x3b
	movwf    0x97 , BANKED
	movlw    0x38
	movwf    0x98 , BANKED
	movlw    0x36
	movwf    0x99 , BANKED
	movlw    0x33
	movwf    0x9a , BANKED
	movlw    0x31
	movwf    0x9b , BANKED
	movlw    0x2e
	movwf    0x9c , BANKED
	movlw    0x2c
	movwf    0x9d , BANKED
	movlw    0x2a
	movwf    0x9e , BANKED
	movlw    0x27
	movwf    0x9f , BANKED
	movlw    0x25
	movwf    0xa0 , BANKED
	movlw    0x23
	movwf    0xa1 , BANKED
	movlw    0x21
	movwf    0xa2 , BANKED
	movlw    0x1f
	movwf    0xa3 , BANKED
	movlw    0x1d
	movwf    0xa4 , BANKED
	movlw    0x1b
	movwf    0xa5 , BANKED
	movlw    0x19
	movwf    0xa6 , BANKED
	movlw    0x17
	movwf    0xa7 , BANKED
	movlw    0x15
	movwf    0xa8 , BANKED
	movlw    0x14
	movwf    0xa9 , BANKED
	movlw    0x12
	movwf    0xaa , BANKED
	movlw    0x10
	movwf    0xab , BANKED
	movlw    0xf
	movwf    0xac , BANKED
	movlw    0xe
	movwf    0xad , BANKED
	movlw    0xc
	movwf    0xae , BANKED
	movlw    0xb
	movwf    0xaf , BANKED
	movlw    0xa
	movwf    0xb0 , BANKED
	movlw    0x9
	movwf    0xb1 , BANKED
	movlw    0x7
	movwf    0xb2 , BANKED
	movlw    0x6
	movwf    0xb3 , BANKED
	movlw    0x5
	movwf    0xb4 , BANKED
	movlw    0x5
	movwf    0xb5 , BANKED
	movlw    0x4
	movwf    0xb6 , BANKED
	movlw    0x3
	movwf    0xb7 , BANKED
	movlw    0x2
	movwf    0xb8 , BANKED
	movlw    0x2
	movwf    0xb9 , BANKED
	movlw    0x1
	movwf    0xba , BANKED
	movlw    0x1
	movwf    0xbb , BANKED
	movlw    0x1
	movwf    0xbc , BANKED
	movlw    0x0
	movwf    0xbd , BANKED
	movlw    0x0
	movwf    0xbe , BANKED
	movlw    0x0
	movwf    0xbf , BANKED
	movlw    0x0
	movwf    0xc0 , BANKED
	movlw    0x0
	movwf    0xc1 , BANKED
	movlw    0x0
	movwf    0xc2 , BANKED
	movlw    0x0
	movwf    0xc3 , BANKED
	movlw    0x1
	movwf    0xc4 , BANKED
	movlw    0x1
	movwf    0xc5 , BANKED
	movlw    0x1
	movwf    0xc6 , BANKED
	movlw    0x2
	movwf    0xc7 , BANKED
	movlw    0x2
	movwf    0xc8 , BANKED
	movlw    0x3
	movwf    0xc9 , BANKED
	movlw    0x4
	movwf    0xca , BANKED
	movlw    0x5
	movwf    0xcb , BANKED
	movlw    0x5
	movwf    0xcc , BANKED
	movlw    0x6
	movwf    0xcd , BANKED
	movlw    0x7
	movwf    0xce , BANKED
	movlw    0x9
	movwf    0xcf , BANKED
	movlw    0xa
	movwf    0xd0 , BANKED
	movlw    0xb
	movwf    0xd1 , BANKED
	movlw    0xc
	movwf    0xd2 , BANKED
	movlw    0xe
	movwf    0xd3 , BANKED
	movlw    0xf
	movwf    0xd4 , BANKED
	movlw    0x10
	movwf    0xd5 , BANKED
	movlw    0x12
	movwf    0xd6 , BANKED
	movlw    0x14
	movwf    0xd7 , BANKED
	movlw    0x15
	movwf    0xd8 , BANKED
	movlw    0x17
	movwf    0xd9 , BANKED
	movlw    0x19
	movwf    0xda , BANKED
	movlw    0x1b
	movwf    0xdb , BANKED
	movlw    0x1d
	movwf    0xdc , BANKED
	movlw    0x1f
	movwf    0xdd , BANKED
	movlw    0x21
	movwf    0xde , BANKED
	movlw    0x23
	movwf    0xdf , BANKED
	movlw    0x25
	movwf    0xe0 , BANKED
	movlw    0x27
	movwf    0xe1 , BANKED
	movlw    0x2a
	movwf    0xe2 , BANKED
	movlw    0x2c
	movwf    0xe3 , BANKED
	movlw    0x2e
	movwf    0xe4 , BANKED
	movlw    0x31
	movwf    0xe5 , BANKED
	movlw    0x33
	movwf    0xe6 , BANKED
	movlw    0x36
	movwf    0xe7 , BANKED
	movlw    0x38
	movwf    0xe8 , BANKED
	movlw    0x3b
	movwf    0xe9 , BANKED
	movlw    0x3e
	movwf    0xea , BANKED
	movlw    0x40
	movwf    0xeb , BANKED
	movlw    0x43
	movwf    0xec , BANKED
	movlw    0x46
	movwf    0xed , BANKED
	movlw    0x49
	movwf    0xee , BANKED
	movlw    0x4c
	movwf    0xef , BANKED
	movlw    0x4e
	movwf    0xf0 , BANKED
	movlw    0x51
	movwf    0xf1 , BANKED
	movlw    0x54
	movwf    0xf2 , BANKED
	movlw    0x57
	movwf    0xf3 , BANKED
	movlw    0x5a
	movwf    0xf4 , BANKED
	movlw    0x5d
	movwf    0xf5 , BANKED
	movlw    0x60
	movwf    0xf6 , BANKED
	movlw    0x63
	movwf    0xf7 , BANKED
	movlw    0x66
	movwf    0xf8 , BANKED
	movlw    0x69
	movwf    0xf9 , BANKED
	movlw    0x6c
	movwf    0xfa , BANKED
	movlw    0x6f
	movwf    0xfb , BANKED
	movlw    0x73
	movwf    0xfc , BANKED
	movlw    0x76
	movwf    0xfd , BANKED
	movlw    0x79
	movwf    0xfe , BANKED
	movlw    0x7c
	movwf    0xff , BANKED
	movlb	 0x00		; reset BSR to Bank 0
	return


    end
