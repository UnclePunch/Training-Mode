#To be inserted at 801abb1c
.include "../../Globals.s"
.include "../../../m-ex/Header.s"

.set entity,31
.set player,31
.set playerdata,31

load	r3,SceneController
lbz	r3,0x0(r3)
cmpwi	r3,0x1
bne	exit

branch	r12,0x801abdf4

exit:
lwz	r3, 0 (r23)
