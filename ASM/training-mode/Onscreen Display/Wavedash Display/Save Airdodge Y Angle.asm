#To be inserted at 80099b74
.include "../../Globals.s"

.set entity,31
.set playerdata,31
.set player,30
.set text,29
.set textprop,28

#Get Airdodge Angle
	mr	r3,r31
	branchl r12,Joystick_Angle_Retrieve
#Save angle
	stfs f1,AirdodgeAngle(r31)

Exit:
addi	r3, r29, 0
