#To be inserted at 801c6160
.include "../Globals.s"


#Output
	lwz	r3, 0x0014 (sp)
	lwz	r3,0x20(r3)
	subi	r4,r3,0x20
	bl	String
	mflr	r3
	branchl	r12,OSReport
	b	Exit

String:
blrl
.string "Stage File at %X\n"
.align 2


Exit:
	lwz	r0, 0x0014 (sp)
