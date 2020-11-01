#To be inserted at 8008f828
.include "../../../Globals.s"
.include "../../../../m-ex/Header.s"

.set playerdata,30
.set player,30

#Check If Not In Hitstun
lbz	r3, 0x221C (playerdata)
rlwinm.	r0, r3, 31, 31, 31
bne	Exit

#Increment PostHitstun Counter
lhz	r3,TM_PostHitstunFrameCount(playerdata)
addi	r3,r3,0x1
sth	r3,TM_PostHitstunFrameCount(playerdata)

Exit:
lbz	r3, 0x221C (playerdata)




