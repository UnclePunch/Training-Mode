#To be inserted at 8006ab60
.include "../../Globals.s"
.include "../../../m-ex/Header.s"

.set entity,31
.set player,31
.set Text,30
.set TextProp,29

###################################
## Increment Post-Hitstun Frames ##
###################################

#Check If In Hitstun
lbz	r3, 0x221C (r31)
rlwinm.	r0, r3, 31, 31, 31
beq	NoHitstun

InHitstun:
li	r3,0
sth	r3,TM_PostHitstunFrameCount(r31)
b	Hitstun_End

NoHitstun:
lhz	r3,TM_PostHitstunFrameCount(r31)
addi	r3,r3,1
sth	r3,TM_PostHitstunFrameCount(r31)
b	Hitstun_End

Hitstun_End:

exit:
lwz	r12, 0x21A0 (r31)
