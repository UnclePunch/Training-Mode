#To be inserted at 8016e91c
.include "D:/Users/Vin/Documents/GitHub/Training-Mode/ASM/Globals.s"

#*************************************************
.if debug==1
#Get Prev Tick
	lwz	r3,-0x49b4(r13)
#Get Current Tick
	mftbl	r4
#Find Difference
	sub	r3,r4,r3

#Convert to ms
#Get Clock Bus
	load 	r4,0x800000f8
	lwz 	r4,0x0(r4)
#Clock Bus / 4
	li	r5,4
	divw 	r4,r4,r5
#Divided by 1000
	li	r5,1000
	divw	r4,r4,r5
#divided by ticks
	divw	r4,r3,r4

#OSReport Difference
	bl	OSReportString
	mflr	r3
	branchl r12,0x803456a8
	b	Exit

OSReportString:
blrl
.string "Match loaded in: %dms"
.align 2
.endif
#*************************************************

Exit:
lwz	r0, 0x0024 (sp)
