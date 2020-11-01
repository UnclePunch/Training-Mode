#To be inserted at 80005518
.include "../../Globals.s"
.include "../../../m-ex/Header.s"

.set entity,31
.set REG_FighterData,31
.set player,30
.set REG_DBBool, 29
.set REG_String, 28
.set REG_DBRate,27
.set REG_TextColor,26
.set REG_Text,25

##########################################################
## 804a1f5c -> 804a1fd4 = Static Stock Icon Text Struct ##
## Is 0x80 long and is zero'd at the start              ##
##  of every VS Match				                        ##
## Store Text Info here                                 ##
##########################################################

backupall

mr	player,r3
lwz	REG_FighterData,0x2C(player)
mr	REG_DBBool,r4				#Dashback Bool

	#CHECK IF ENABLED
	li	r0,OSD.Dashback			#wavedash ID
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

	#Change color to Green if frame perfect act oos
		cmpwi	REG_DBBool,0x0
		beq	FailedDB
	#Check If UCF DB or Vanilla DB
		lwz	r3,0x2350(REG_FighterData)		 #get turn flag
		cmpwi	r3,0x0			#if 0, was a smash turn
		bne	UCFDB
		VanillaDB:
		mr	r3,REG_FighterData
		bl	IncDBRate
		mr	REG_DBRate,r3
		bl	DBVanilla_String
		mflr REG_String
		li	REG_TextColor,MSGCOLOR_GREEN
		b	PrintMessage	
		UCFDB:
		mr	r3,REG_FighterData
		bl	IncDBRate
		mr	REG_DBRate,r3
		bl	DBUCF_String
		mflr REG_String
		li	REG_TextColor,MSGCOLOR_YELLOW
		b	PrintMessage
		FailedDB:
		mr	r3,REG_FighterData
		bl	DecDBRate
		mr	REG_DBRate,r3
		bl	DBFailed_String
		mflr REG_String
		li	REG_TextColor,MSGCOLOR_RED
		b	PrintMessage

		PrintMessage:
		li	r3,4			#Message Kind
		lbz	r4,0xC(REG_FighterData)	#Message Queue
		li	r5,MSGCOLOR_WHITE
		mr	r6,REG_String
		mr	r7,REG_DBRate
		Message_Display
		lwz	r3,0x2C(r3)
		lwz	REG_Text,MsgData_Text(r3)

		# adjust top line color
		bl	Colors
		mflr	r3
		cmpwi	REG_TextColor,MSGCOLOR_GREEN
		beq	GreenText
		cmpwi	REG_TextColor,MSGCOLOR_RED
		beq	RedText	
		YellowText:
		addi r5,r3,0x4
		b	ChangeColor
		GreenText:
		addi r5,r3,0x0
		b	ChangeColor
		RedText:
		addi r5,r3,0x8
		b	ChangeColor

		ChangeColor:
		mr	r3,REG_Text
		li	r4,0
		branchl r12,Text_ChangeTextColor

		b Moonwalk_Exit

#########################
### DB Rate Functions ###
#########################

IncDBRate:
stwu	r1,-0x100(r1)	# make space for 12 registers
mflr r0
stw r0,0xFC(sp)
lbz	r3,0xC(r3)		#get player slot
load	r4,0x804a1fc8		#get DB rate mem location
mulli	r3,r3,0x4		#length of players DB info
add	r8,r3,r4		#players DB info in r8
lhz	r3,0x0(r8)		#successful DBs
addi	r3,r3,0x1
sth	r3,0x0(r8)		#successful DBs
lhz	r3,0x2(r8)		#total DBs
addi	r3,r3,0x1
sth	r3,0x2(r8)		#total DBs
mr	r3,r8
bl	GetDBRate
lwz r0,0xFC(sp)
mtlr r0
addi	r1,r1,0x100	# release the space
blr

DecDBRate:
stwu	r1,-0x100(r1)	# make space for 12 registers
mflr r0
stw r0,0xFC(sp)
lbz	r3,0xC(r3)		#get player slot
load	r4,0x804a1fc8		#get DB rate mem location
mulli	r3,r3,0x4		#length of players DB info
add	r8,r3,r4		#players DB info in r8
lhz	r3,0x2(r8)		#total DBs
addi	r3,r3,0x1
sth	r3,0x2(r8)		#total DBs
mr	r3,r8
bl	GetDBRate
lwz r0,0xFC(sp)
mtlr r0
addi	r1,r1,0x100	# release the space
blr


GetDBRate:
#Get Values
lhz	r4,0x0(r3)		#successful DBs
lhz	r5,0x2(r3)		#total DBs
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
fdivs	f1,f1,f2		#successful DB / total DB
fmuls	f1,f1,f3		#times 100
#Back to Int
fctiwz	f1,f1
stfd	f1,0xF0(sp)
lwz	r3,0xF4(sp)
blr


###################
## TEXT CONTENTS ##
###################

DBVanilla_String:
blrl
.string "Vanilla Dashback\nSuccession: %d%"
.align 2

DBUCF_String:
blrl
.string "UCF Dashback\nSuccession: %d%"
.align 2

DBFailed_String:
blrl
.string "Failed Dashback\nSuccession: %d%"
.align 2

Colors:
blrl
.long 0x8dff6eff	#green
.long 0xfff000ff 	#yellow
.byte 255, 162, 186, 255 	#red
##############################


Moonwalk_Exit:
restoreall
blr
