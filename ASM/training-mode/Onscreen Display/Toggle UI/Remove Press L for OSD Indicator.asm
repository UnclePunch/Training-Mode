#To be inserted at 80230974
.include "../../Globals.s"
.include "../../../m-ex/Header.s"

.set text,31
.set textproperties,30

Original:
	stw	r0, 0x0130 (r31)

#Get Pointer
	lwz r3,-0x4EB4(r13)
	cmpwi r3,0
	beq	Exit
#Remove Text
	branchl r12,Text_RemoveText

Exit:
