#To be inserted at 8009029c
.include "../../../Globals.s"
.include "../../../../m-ex/Header.s"

.set entity,31
.set playerdata,29
.set player,30
.set text,29
.set textprop,28
.set hitbool,27

#Check If Not In Hitstun
lbz	r3, 0x221C (r29)
rlwinm.	r0, r3, 31, 31, 31
bne	Exit

#Increment PostHitstun Counter
lhz	r3,TM_PostHitstunFrameCount(playerdata)
addi	r3,r3,0x1
sth	r3,TM_PostHitstunFrameCount(playerdata)

Exit:
lbz	r3, 0x221C (r29)




