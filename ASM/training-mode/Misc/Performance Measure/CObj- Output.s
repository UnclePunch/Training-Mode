#To be inserted at 80391018
.include "../../Globals.s"
.include "../../../m-ex/Header.s"

.if debug==1
#Store Current tick
mftbl	r12
stw	r12,-0x49b4(r13)
.endif

blrl

#*************************************************
.if debug==1
#Get Prev Tick
	lwz	r3,-0x49b4(r13)
#Get Current Tick
	mftbl	r4
#Find Difference
	sub	r3,r4,r3

#Save
	lwz	r4,-0x49b8(r13)
	add r4,r4,r3
	stw	r4,-0x49b8(r13)

#Convert to us
#Get Clock Bus
	load 	r4,0x800000f8
	lwz 	r4,0x0(r4)
#Clock Bus / 4
	li	r5,4
	divw 	r4,r4,r5
#Divided by 1000
	load	r5,1000000
	divw	r4,r4,r5
#divided by ticks
	divw	r5,r3,r4

#OSReport Difference
	bl	OSReportString
	mflr	r3
    lwz	r4, 0x001C (r30)
	branchl r12,0x803456a8
	b	Exit

OSReportString:
blrl
.string "%x cobj in %dus\n"
.align 2
.endif
#*************************************************

Exit:

