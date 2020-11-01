#To be inserted at 800902c4
.include "../../../Globals.s"
.include "../../../../m-ex/Header.s"

.set entity,31
.set playerdata,29
.set player,30
.set text,29
.set textprop,28
.set hitbool,27

stb	r3, 0x221C (r29)

#Initialize Counter at 0x2354
sth	r0,TM_PostHitstunFrameCount(playerdata)





