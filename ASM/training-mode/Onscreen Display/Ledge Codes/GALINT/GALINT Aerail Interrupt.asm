#To be inserted at 8008d6f4
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


#Check For CliffWait
lhz	r4, TM_ThreeASAgo (r5)
cmpwi	r4,0xFD
bne	Moonwalk_Exit

li  r4,1
branchl	r12,0x80005514





Moonwalk_Exit:
restoreall
branchl	r12,0x800d5bf8
