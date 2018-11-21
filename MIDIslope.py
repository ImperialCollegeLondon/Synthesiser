a = 36  # address, midi codes start at 36 (0x24)

samp = 44077.13499    # sampling rate (Hz)

# note frequencies in correct order for keyboard
freqs = [65.41,69.3,73.42,77.78,82.41,87.31,92.5,98,103.83,110,116.54,123.47,
         130.81,138.59,146.83,155.56,164.81,174.61,185,196,207.65,220,233.08,
         246.94,261.63,277.18,293.66,311.13,329.63,349.23,369.99,392,415.3,
         440,466.16,493.88,523.25,554.37,587.33,622.25,659.25,698.46,739.99,
         783.99,830.61,880,932.33,987.77,1046.5]

slope = [f*255/samp for f in freqs]     # unrounded slopes

slopeh = [hex(int(s)) for s in slope]        # slope high byte

slopel = [hex(int(255*(s-int(s)))) for s in slope]      # slope low byte

print('movlb    0x01    ; slope low bytes stored in bank 1')
for s in slopeh:
	print('movlw   ',s)           
	print('movwf   ',hex(a),',BANKED')
	a+=1
    
print('\n\n')       # gap
a = 36              # address, midi codes start at 36 (0x24)

print('movlb    0x03    ; slope high bytes stored in bank 3')
for s in slopel:
	print('movlw   ',s)           
	print('movwf   ',hex(a),',BANKED')
	a+=1
print('movlb    0x01    ; bsr reset to bank 0')
