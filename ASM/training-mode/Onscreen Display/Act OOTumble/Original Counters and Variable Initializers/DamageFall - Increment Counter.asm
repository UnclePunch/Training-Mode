#To be inserted at 80090824
.include "../../../Globals.s"
.include "../../../../m-ex/Header.s"

.set entity,31
.set playerdata,4
.set player,30
.set text,29
.set textprop,28
.set hitbool,27

lwz	playerdata,0x2c(r3)

#Increment PostHitstun Counter
lhz	r3,TM_PostHitstunFrameCount(playerdata)
addi	r3,r3,0x1
sth	r3,TM_PostHitstunFrameCount(playerdata)

Exit:
blr




