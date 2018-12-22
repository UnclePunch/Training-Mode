#To be inserted at 80005520
.include "D:/Users/Vin/Documents/GitHub/Training-Mode/ASM/Globals.s"

#CHECK IF CUSTOM EVENT
  cmpwi	r3,FirstCustomEvent
  blt	Vanilla
  cmpwi	r3,LastCustomEvent
  bgt	Vanilla

Custom:
li  r3,1
b Exit
Vanilla:
li  r3,0
Exit:
blr
