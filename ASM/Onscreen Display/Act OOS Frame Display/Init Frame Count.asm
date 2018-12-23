#To be inserted at 80093388
.include "D:/Users/Vin/Documents/GitHub/Training-Mode/ASM/Globals.s"
.set entity,31
.set playerdata,31
.set player,30
.set text,29
.set textprop,28

##########################################################
## 804a1f5c -> 804a1fd4 = Static Stock Icon Text Struct ##
## Is 0x80 long and is zero'd at the start              ##
##  of every VS Match				                        ##
## Store Text Info here                                 ##
##########################################################


#init count
li	r0,0
sth	r0,0x23EE(r29)

lwz	r0, 0x234C (r29)
