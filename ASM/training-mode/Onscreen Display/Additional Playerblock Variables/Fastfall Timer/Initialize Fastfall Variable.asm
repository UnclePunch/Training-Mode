#To be inserted at 800698c8
.include "../../../Globals.s"
.include "../../../../m-ex/Header.s"

.set entity,31
.set player,31
.set Text,30
.set TextProp,29

#Store IsFastFalling Bit (Original Line)
stb	r0, 0x221A (r26)

#Initialize FastFall Variable
li	r0,0
sth	r0,TM_CanFastfallFrameCount(r26)
