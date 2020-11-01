#To be inserted at 800d5d5c
.include "../../../Globals.s"
.include "../../../../m-ex/Header.s"

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

backupall

lwz	r5,0x2C(r31)

#Check If Coming From Airdodge
lhz	r3, TM_OneASAgo (r5)
cmpwi	r3,0xEC
bne	Moonwalk_Exit
#Check For CliffWait
lhz	r3, TM_FourASAgo (r5)
cmpwi	r3,0xFD
bne	Moonwalk_Exit

mr	r3,r31
li  r4,0
branchl	r12,0x80005514





Moonwalk_Exit:
restoreall
mr	r3, r31
