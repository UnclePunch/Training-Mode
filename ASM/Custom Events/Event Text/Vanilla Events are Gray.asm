#To be inserted at 8024d4a4
.include "../../Globals.s"

load r3,0xbbbbbbFF
stw r3,0x30(r24)

#Original
rlwinm	r3, r27, 0, 24, 31
