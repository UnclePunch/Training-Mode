#To be inserted at 800da9d4
.include "D:/Users/Vin/Documents/GitHub/Training-Mode/ASM/Globals.s"

.set entity,31
.set playerdata,31
.set player,30
.set text,29
.set textprop,28
.set hitbool,27

##########################################################
## 804a1f5c -> 804a1fd4 = Static Stock Icon Text Struct ##
## Is 0x80 long and is zero'd at the start              ##
##  of every VS Match				                        ##
## Store Text Info here                                 ##
##########################################################

fmadds	f1,f1,f0,f2
stfs	f1, 0x2354 (r3)			#Store Initial Countdown
