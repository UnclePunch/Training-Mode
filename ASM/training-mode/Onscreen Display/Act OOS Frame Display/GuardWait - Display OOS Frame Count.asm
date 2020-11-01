#To be inserted at 80092b58
.include "../../Globals.s"
.include "../../../m-ex/Header.s"
.set entity,31
.set playerdata,31
.set player,30
.set text,29
.set textprop,28
.set TextCreateFunction,0x80005928


##########################################################
## 804a1f5c -> 804a1fd4 = Static Stock Icon Text Struct ##
## Is 0x80 long and is zero'd at the start              ##
##  of every VS Match				                        ##
## Store Text Info here                                 ##
##########################################################

mr	r4,r30
branchl	r12,0x80005508

lwz	r0, 0x001C (sp)
