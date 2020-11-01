#To be inserted at 8008e52c
.include "../../Globals.s"
.include "../../../m-ex/Header.s"

.set REG_FighterData,31
.set player,30
.set REG_TextColor,29

##########################################################
## 804a1f5c -> 804a1fd4 = Static Stock Icon Text Struct ##
## Is 0x80 long and is zero'd at the start              ##
##  of every VS Match				                        ##
## Store Text Info here                                 ##
##########################################################

backupall
stfs	f0,0x80(sp)
stfs	f1,0x84(sp)
stfs	f2,0x8C(sp)
stfs	f3,0x88(sp)

mr	REG_FighterData,r3

	#CHECK IF ENABLED
	li	r0,OSD.SDI			#PowerShield ID
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

	SDICheck:
	#Check For SDI
	fcmpo	cr0,f1,f0
	cror	2, 1, 2
	bne	NoSDI

	#Check For SDI Cont.
	lbz	r0, 0x0670 (REG_FighterData)
	lwz	r4, -0x514C (r13)
	lwz	r5, 0x04B4 (r4)
	cmpw	r0, r5
	blt	SuccessfulSDI

	#Check For SDI Cont..
	lbz	r0, 0x0671 (REG_FighterData)
	cmpw	r0, r5
	bge	NoSDI

	SuccessfulSDI:
	#Increment Successful SDI
	lhz	r3,TM_SuccessfulSDIInputs(REG_FighterData)
	addi	r3,r3,0x1
	sth	r3,TM_SuccessfulSDIInputs(REG_FighterData)

	NoSDI:
	#Increment Total SDI
	lhz	r3,TM_TotalSDIInputs(REG_FighterData)
	addi	r3,r3,0x1
	sth	r3,TM_TotalSDIInputs(REG_FighterData)




	#Change color to Green if SDI'd once
		lhz	r3,TM_SuccessfulSDIInputs(REG_FighterData)
		cmpwi	r3,0x0
		beq	RedText
		li	REG_TextColor,MSGCOLOR_GREEN
		b	PrintMessage
		RedText:
		li	REG_TextColor,MSGCOLOR_RED
		b	PrintMessage

		PrintMessage:
		li	r3,2			#Message Kind
		lbz	r4,0xC(REG_FighterData)	#Message Queue
		mr	r5,REG_TextColor
		bl	SDI_String
		mflr r6
		lhz	r7,TM_SuccessfulSDIInputs(REG_FighterData)
		lhz	r8,TM_TotalSDIInputs(REG_FighterData)
		Message_Display

		b Moonwalk_Exit

###################
## TEXT CONTENTS ##
###################

SDI_String:
blrl
.string "SDI Inputs\n%d/%d"
.align 2

############
## Floats ##
############
Floats:
blrl
.long 0x41300000
##############################

Moonwalk_Exit:
lfs	f0,0x80(sp)
lfs	f1,0x84(sp)
lfs	f2,0x8C(sp)
lfs	f3,0x88(sp)
restoreall
fcmpo	cr0,f1,f0
