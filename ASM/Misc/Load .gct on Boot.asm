#To be inserted at 80375384
.macro branchl reg, address
lis \reg, \address @h
ori \reg,\reg,\address @l
mtctr \reg
bctrl
.endm

.macro branch reg, address
lis \reg, \address @h
ori \reg,\reg,\address @l
mtctr \reg
bctr
.endm

.macro load reg, address
lis \reg, \address @h
ori \reg, \reg, \address @l
.endm

.macro loadf regf,reg,address
lis \reg, \address @h
ori \reg, \reg, \address @l
stw \reg,-0x4(sp)
lfs \regf,-0x4(sp)
.endm

.macro backup
mflr r0
stw r0, 0x4(r1)
stwu	r1,-0x100(r1)	# make space for 12 registers
stmw  r20,0x8(r1)
.endm

 .macro restore
lmw  r20,0x8(r1)
lwz r0, 0x104(r1)
addi	r1,r1,0x100	# release the space
mtlr r0
.endm

.macro intToFloat reg,reg2
xoris    \reg,\reg,0x8000
lis    r18,0x4330
lfd    f16,-0x7470(rtoc)    # load magic number
stw    r18,0(r2)
stw    \reg,4(r2)
lfd    \reg2,0(r2)
fsubs    \reg2,\reg2,f16
.endm

.set ActionStateChange,0x800693ac
.set HSD_Randi,0x80380580
.set HSD_Randf,0x80380528
.set Wait,0x8008a348
.set Fall,0x800cc730

.set entity,31
.set player,31

.set GeckoCodehandler,0x8040a5e4


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
	CreateHeapBoundaries:
	addi	r0, r3, 31			#allign to something
	rlwinm	r4, r0, 0, 0, 26			#allign to something
	mr	r3,r25			#r3 = start of heap
	add	r25,r3,r4			#ArenaHi = ArenaLo+ .gct size
	addi	r25,r25,0x500			#ArenaHi = ArenaHi+ 0x500 (misc space for file loading)
	mr	r4,r25			#r4= end of heap
	branchl	r12,0x803440e8			#Create Heap
	stw	r3, -0x5688 (r13)			#Store Active Heap

	#Load File
	mr	r3, r29
	branchl r12,0x800163D8
	addi	r0, r3, 31
	rlwinm	r4, r0, 0, 0, 26
	li	r3, 0
	branchl	r12,0x80015BD0
	addi	r31, r3, 0
	li	r3, 0
	li	r4, 68
	branchl	r12,0x80015BD0
	addi	r30, r3, 0
	addi	r3, r29, 0
	addi	r4, r31, 0
	addi	r5, sp, 12
	branchl	r12,0x8001668C
	lwz	r5, 0x000C (sp)
	addi	r3, r31, 0
	addi	r4, r30, 0


	#Run Codehandler
	mr	r4,r3
	branchl	r12,GeckoCodehandler

	#Return End of Heap
	mr	r3,r25

	b exit

fileName:
blrl

/*
#TyChico.dat
.long 0x54794368
.long 0x69636f2e
.long 0x64617400
*/

#code.gct
.long 0x636f6465
.long 0x732e6763
.long 0x74000000


#EXIT
exit:
restore
mr	r31,r3		#r31 = start of next heap
addi	r3, r31, 31		#original codeline
