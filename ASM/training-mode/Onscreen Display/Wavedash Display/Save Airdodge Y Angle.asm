#To be inserted at 80099b74
.include "../../Globals.s"
.include "../../../m-ex/Header.s"

#Get Airdodge Angle
	mr	r3,r31
	branchl r12,Joystick_Angle_Retrieve
#Save angle
	stfs f1,TM_AirdodgeAngle(r31)

Exit:
addi	r3, r29, 0
