#To be inserted at 8008d770
.include "../Globals.s"
.include "../../m-ex/Header.s"

.set entity,31
.set REG_FighterData,31
.set player,30
.set text,29
.set textprop,28
.set	REG_TextColor,27
.set	REG_String,26

##########################################################
## 804a1f5c -> 804a1fd4 = Static Stock Icon Text Struct ##
## Is 0x80 long and is zero'd at the start              ##
##  of every VS Match				                        ##
## Store Text Info here                                 ##
##########################################################

backupall
	lwz	REG_FighterData,0x2c(player)

	#CHECK IF ENABLED
	li	r0,OSD.LCancel			#wavedash ID
	#lwz	r4,-0xdbc(rtoc)			#get frame data toggle bits
	lwz	r4,-0x77C0(r13)
	lwz	r4,0x1F24(r4)
	li	r3, 1
	slw	r0, r3, r0
	and.	r0, r0, r4
	beq	Moonwalk_Exit

	CheckForFollower:
	mr	r3,REG_FighterData
	branchl	r12,0x80005510
	cmpwi	r3,0x1
	beq	Moonwalk_Exit

	# Check if succeeded
	lbz	r5,0x67F(REG_FighterData)			#get decimal to print
	cmpwi	r5,0x7
	blt	SuccessLCancel
	FailedLCancel:
	li	REG_TextColor,MSGCOLOR_RED
	mr	r3,REG_FighterData
	bl	DecLCRate 
	b	DetermineString
	SuccessLCancel:
	li	REG_TextColor,MSGCOLOR_GREEN
	mr	r3,REG_FighterData
	bl	IncLCRate
	b	DetermineString

	DetermineString:
	# If under 40 frames, qualify as an attempt
	lbz	r8,0x67F(REG_FighterData)			#get decimal to print
	cmpwi	r8,40
	bgt	DetermineString_NoPress
	bl	LCancel_Press
	mflr	REG_String
	b	PrintMessage
	
	DetermineString_NoPress:
	bl	LCancel_NoPress
	mflr	REG_String
	b	PrintMessage

	PrintMessage:
	mr	r7,r3		#LCancel Percent
	li	r3,1			#Message Kind
	lbz	r4,0xC(REG_FighterData)	#Message Queue
	mr	r5,REG_TextColor
	mr	r6,REG_String
	lbz	r8,0x67F(REG_FighterData)			#get decimal to print
	addi	r8,r8,1
	Message_Display

	
	# Make Top Line White
	lwz	r3,0x2C(r3)
	lwz	r3,MsgData_Text(r3)
	li	r4,0
	bl	Color_White
	mflr r5
	branchl	r12,Text_ChangeTextColor
	

b Moonwalk_Exit

#########################
### LC Rate Functions ###
#########################

IncLCRate:
stwu	r1,-0x100(r1)	# make space for 12 registers
mflr r0
stw r0,0xFC(sp)
lbz	r3,0xC(r3)		#get player slot
load	r4,0x804a1fa8		#get LC rate mem location
mulli	r3,r3,0x4		#length of players DB info
add	r8,r3,r4		#players LC info in r8
lhz	r3,0x0(r8)		#successful LCs
addi	r3,r3,0x1
sth	r3,0x0(r8)		#successful LCs
lhz	r3,0x2(r8)		#total LCs
addi	r3,r3,0x1
sth	r3,0x2(r8)		#total LCs
mr	r3,r8
bl	GetLCRate
lwz r0,0xFC(sp)
mtlr r0
addi	r1,r1,0x100	# release the space
blr

DecLCRate:
stwu	r1,-0x100(r1)	# make space for 12 registers
mflr r0
stw r0,0xFC(sp)
lbz	r3,0xC(r3)		#get player slot
load	r4,0x804a1fa8		#get DB rate mem location
mulli	r3,r3,0x4		#length of players DB info
add	r8,r3,r4		#players DB info in r8
lhz	r3,0x2(r8)		#total DBs
addi	r3,r3,0x1
sth	r3,0x2(r8)		#total DBs
mr	r3,r8
bl	GetLCRate
lwz r0,0xFC(sp)
mtlr r0
addi	r1,r1,0x100	# release the space
blr


GetLCRate:
#Get Values
lhz	r4,0x0(r3)		#successful LCs
lhz	r5,0x2(r3)		#total LCs
#Get as Floats (f1 = successful, f2 = total
lis	r0, 0x4330
lfd	f5, -0x6758 (rtoc)
xoris	r6, r4, 0x8000
xoris	r7, r5, 0x8000
stw	r0,0xF0(sp)
#Successful DB
stw	r6,0xF4(sp)
lfd	f1,0xF0(sp)
fsubs	f1,f1,f5
#Total DB
stw	r7,0xF4(sp)
lfd	f2,0xF0(sp)
fsubs	f2,f2,f5
#100f
li	r4,100
xoris	r4,r4,0x8000
stw	r4,0xF4(sp)
lfd	f3,0xF0(sp)
fsubs	f3,f3,f5
fdivs	f1,f1,f2		#successful LC / total LC
fmuls	f1,f1,f3		#times 100
#Back to Int
fctiwz	f1,f1
stfd	f1,0xF0(sp)
lwz	r3,0xF4(sp)
blr


LCancel_Press:
blrl
.string "L-Cancel %d%%\nFrame %d/7"
.align 2

LCancel_NoPress:
blrl
.string "L-Cancel %d%%\nNo Press"
.align 2

Color_White:
blrl
.long 0xFFFFFFFF

##############################

Moonwalk_Exit:
restoreall

lwz	r0, 0x0034 (sp)
