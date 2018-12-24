#To be inserted at 80099b74
.include "../../Globals.s"

.set entity,31
.set playerdata,31
.set player,30
.set text,29
.set textprop,28

#Save Airdodge Angle
	lfs f1,0x624(r31)
	stfs f1,AirdodgeAngle(r31)

Exit:
addi	r3, r29, 0
