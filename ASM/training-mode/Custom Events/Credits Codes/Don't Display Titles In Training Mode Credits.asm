#To be inserted at 801aae50
.include "../../Globals.s"
.include "../../../m-ex/Header.s"

.set entity,31
.set player,31
.set playerdata,31
.set text,31

load	r5,SceneController
lbz	r5,0x0(r5)
cmpwi	r5,0x1		#Main Menu
beq	Skip
branchl	r12,0x803a6368

Skip:
