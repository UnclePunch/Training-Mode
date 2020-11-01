#To be inserted at 8007d550
.include "../../../Globals.s"
.include "../../../../m-ex/Header.s"

.set entity,31
.set player,31
.set Text,30
.set TextProp,29

#Increment FastFall Variable
lhz	r6,TM_CanFastfallFrameCount(r3)
addi	r6,r6,0x1
sth	r6,TM_CanFastfallFrameCount(r3)

#Original Codeline
lwz	r6, -0x514C (r13)
