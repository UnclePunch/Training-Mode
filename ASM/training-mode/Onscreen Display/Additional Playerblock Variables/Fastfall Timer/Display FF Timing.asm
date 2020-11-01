#To be inserted at 8007d57c
.include "../../../Globals.s"
.include "../../../../m-ex/Header.s"

.set entity,31
.set REG_FighterData,31
.set player,30
.set REG_TextColor,29
.set REG_Text,28
		
##########################################################
## 804a1f5c -> 804a1fd4 = Static Stock Icon Text Struct ##
## Is 0x80 long and is zero'd at the start              ##
##  of every VS Match				                        ##
## Store Text Info here                                 ##
##########################################################

backupall

mr	REG_FighterData,r3


	#CHECK IF ENABLED
	li	r0,OSD.Fastfall			#PowerShield ID
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

	#Check If Falling Off Ledge and Respawn Platform
	lhz	r3,TM_OneASAgo(REG_FighterData)
#	cmpwi	r3,0xFD			#CliffWait
#	beq	Moonwalk_Exit
	cmpwi	r3,0xD			#RebirthWait
	beq	Moonwalk_Exit

	PrintMessage:
	li	r3,7						#Message Kind
	lbz	r4,0xC(REG_FighterData)		#Message Queue
	li	r5,MSGCOLOR_WHITE
	bl	Fastfall_String
	mflr r6
	lhz	r7,TM_CanFastfallFrameCount(REG_FighterData)
	Message_Display
	lwz	r3,0x2C(r3)
	lwz	REG_Text,MsgData_Text(r3)

	#Check if frame 1
	lhz	r3,TM_CanFastfallFrameCount(REG_FighterData)
	cmpwi	r3,1
	bne	Moonwalk_Exit
	mr	r3,REG_Text
	li	r4,1
	bl	Colors
	mflr	r5
	branchl r12,Text_ChangeTextColor

	b Moonwalk_Exit

###################
## TEXT CONTENTS ##
###################

Fastfall_String:
blrl
.string "Fastfall\nFrame %d"
.align 2

Colors:
blrl
.long 0x8dff6eff	#green

##############################


Moonwalk_Exit:
restoreall
li	r0, 1
