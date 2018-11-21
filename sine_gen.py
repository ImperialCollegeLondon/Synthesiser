import numpy as np
import matplotlib.pyplot as plt


pi=np.pi

n = 256   #how many values you want to produce
amp = 127    # amplitude of the sine wave


x = np.arange(0,2*pi,2*pi/n)
x = np.array(x)


sin = [amp*(np.sin(i)+1) for i in x]
round_sin = [int(round(i)) for i in sin]

plt.xlabel("x")
plt.ylabel("sin(x)")
plt.plot(x, sin, label="sin(x)")
plt.plot(x, round_sin, label="round(sin(x))")
plt.legend()

print(round_sin)

l=0
for s in round_sin:
    print('movlw   ',hex(s))
    print("movwf   ",hex(l),", BANKED")
    
    l+=1    
