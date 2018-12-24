#To be inserted at 80069774
.include "../../Globals.s"

.set entity,31
.set playerdata,31
.set player,30
.set text,29
.set textprop,28
.set hitbool,27
.set framenumber,26

stb	r0, 0x2218 (r26)
lbz	r0, 0x2218 (r26)
li	r4,0x0
rlwimi	r0, r4, 7, 24, 24
stb	r0, 0x2218 (r26)
