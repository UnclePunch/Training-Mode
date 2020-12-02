#To be inserted at 80375384
.include "../Globals.s"

.set GeckoCodehandler,0x8040a5e4
.set HeaderSize,32


#########################
## LOAD FILE FROM DISC ##
#########################
	backup

#Backup ArenaLo to r25
	mr	r25,r31

#Get File Name
	bl fileName
	mflr r3

#Get File Length For Heap Creation
	mr	r29, r3
	branchl r12,0x800163D8

#Check If File Exists
	cmpwi	r3,-1
	bne	CreateHeapBoundaries
	mr	r3,r25
	b	exit

#Create Heap Boundaries
.set REG_FileSize,28
	CreateHeapBoundaries:
	addi r3,r3,HeaderSize				#add some extra space for the header
	addi	r0, r3, 31						#allign to something
	rlwinm	REG_FileSize, r0, 0, 0, 26			#allign to something
	mr	r3,r25			#r3 = start of heap
	add	r25,r3,REG_FileSize			#ArenaHi = ArenaLo+ .gct size
	addi	r25,r25,0x500			#ArenaHi = ArenaHi+ 0x500 (misc space for file loading)
	mr	r4,r25			#r4= end of heap
	branchl	r12,0x803440e8			#Create Heap
	stw	r3, -0x5688 (r13)			#Store Active Heap

#Allocate persistent file space
.set REG_Codeset,27
	li	r3, 0
	mr	r4,REG_FileSize
	branchl	r12,0x80015BD0
#Load File
	addi	REG_Codeset, r3, 0
	addi	r3, r29, 0
	addi	r4, REG_Codeset, HeaderSize
	addi	r5, sp, 12
	branchl	r12,0x8001668C

#Store codeset pointer and length
  stw REG_Codeset,CodesetPointer(rtoc)
  stw REG_FileSize,0x0(REG_Codeset)

#Run Codehandler
	addi	r4,REG_Codeset,HeaderSize
	branchl	r12,GeckoCodehandler

#Now flush the instruction cache
  lis r3,0x8000
  load r4,0x3b722c    #might be overkill but flush the entire dol file
  branchl r12,0x80328f50

#Return End of Heap
	mr	r3,r25

	b exit

fileName:
blrl

.string "codes.gct"
.align 2

#EXIT
exit:
restore
mr	r31,r3		#r31 = start of next heap
addi	r3, r31, 31		#original codeline
