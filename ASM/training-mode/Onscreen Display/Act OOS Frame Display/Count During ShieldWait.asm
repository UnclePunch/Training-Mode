#To be inserted at 80092a38
.include "../../Globals.s"
.include "../../../m-ex/Header.s"

.set entity,31
.set playerdata,4
.set player,30
.set text,29
.set textprop,28

##########################################################
## 804a1f5c -> 804a1fd4 = Static Stock Icon Text Struct ##
## Is 0x80 long and is zero'd at the start              ##
##  of every VS Match				                        ##
## Store Text Info here                                 ##
##########################################################


lwz	r4, 0x002C (r3)

lhz	r5,TM_ShieldFrames(playerdata)

cmpwi	r5,0xFF
beq	skipInc
addi	r5,r5,0x1
sth	r5,TM_ShieldFrames(playerdata)

skipInc:
