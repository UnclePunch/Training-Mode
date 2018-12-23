#To be inserted at 8008f914
.include "D:/Users/Vin/Documents/GitHub/Training-Mode/ASM/Globals.s"
.set entity,31
.set playerdata,31
.set player,30
.set text,29
.set textprop,28
.set hitbool,27

##############################8008f914############################
## 804a1f5c -> 804a1fd4 = Static Stock Icon Text Struct ##
## Is 0x80 long and is zero'd at the start              ##
##  of every VS Match				                        ##
## Store Text Info here                                 ##
##########################################################

#Branch to Interrupt Check With Interrupt Bool in r3 and player in r4
mr	r4,r31
branchl	r12,0x80005504

branch	r12,0x8008f920
