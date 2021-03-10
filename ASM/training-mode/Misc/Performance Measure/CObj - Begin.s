#To be inserted at 801a5044
.include "../../Globals.s"
.include "../../../m-ex/Header.s"

.if debug==1
#OSReport
	bl	OSReportBegin
	mflr	r3
	branchl r12,0x803456a8
	li r3,0
	stw	r3,-0x49b8(r13)
.endif

branchl r12,0x80390fc0


.if debug==1
#*************************************************
#Get Tick total
	lwz	r3,-0x49b8(r13)

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
	divw	r4,r3,r4

#OSReport Difference
	bl	OSReportEnd
	mflr	r3
	branchl r12,0x803456a8
	b	Exit

OSReportBegin:
blrl
.string "\n## CObj BEGIN ##\n"
.align 2

OSReportEnd:
blrl
.string "Total: %dus\n## CObj Proc END ##\n"
.align 2
.endif
#*************************************************

Exit:

