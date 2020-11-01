#To be inserted at 8001674c
.include "../../Globals.s"

.set  REG_Tick,20
.set  REG_FileSize,21
.set  REG_FileName,30

backup

#Get Prev Tick
	lwz	r3,-8(rtoc)
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
	divw	REG_Tick,r3,r4

#Get file size
  mr  r3,r30
  branchl r12,0x800163d8
  mr  REG_FileSize,r3

#OSReport Difference
	bl	OSReportString
	mflr	r3
  mr  r4,REG_FileName
  li  r5,1000
  divw  r5,REG_FileSize,r5
  mr  r6,REG_Tick
	branchl r12,0x803456a8
	b	Exit

OSReportString:
blrl
.string "%s (%dkb) loaded in %dms\n"
.align 2
#*************************************************
Exit:
restore
lmw	r27, 0x001C (sp)
