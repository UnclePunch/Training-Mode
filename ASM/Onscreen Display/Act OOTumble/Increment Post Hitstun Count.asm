#To be inserted at 8006ab60
.include "../../Globals.s"

.set entity,31
.set player,31
.set Text,30
.set TextProp,29

.set PostHistunFrames,0x240E

###################################
## Increment Post-Hitstun Frames ##
###################################

#Check If In Hitstun
lbz	r3, 0x221C (r31)
rlwinm.	r0, r3, 31, 31, 31
beq	NoHitstun

InHitstun:
li	r3,0
sth	r3,PostHistunFrames(r31)
b	Hitstun_End

NoHitstun:
lhz	r3,PostHistunFrames(r31)
addi	r3,r3,1
sth	r3,PostHistunFrames(r31)
b	Hitstun_End

Hitstun_End:

exit:
lwz	r12, 0x21A0 (r31)
