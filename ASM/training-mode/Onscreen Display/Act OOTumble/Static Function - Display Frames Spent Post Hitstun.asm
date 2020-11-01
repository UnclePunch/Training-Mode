#To be inserted at 80005504
.include "../../Globals.s"
.include "../../../m-ex/Header.s"

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

backup

mr	player,r4
lwz	REG_FighterData,0x2c(player)

#Check For Interrupt
cmpwi	r3,0x1
bne	Moonwalk_Exit



	#CHECK IF ENABLED
	li	r0,OSD.ActOoHitstun			#PowerShield ID
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

	#Check if frame 1
	lhz	r3,TM_PostHitstunFrameCount(REG_FighterData)
	cmpwi	r3,0
	bgt	WhiteText
	GreenText:
	li	REG_TextColor,MSGCOLOR_GREEN
	b	PrintMessage	

	WhiteText:
	li	REG_TextColor,MSGCOLOR_WHITE
	b	PrintMessage

	PrintMessage:
	li	r3,5						#Message Kind
	lbz	r4,0xC(REG_FighterData)		#Message Queue
	mr	r5,REG_TextColor
	bl	ActOoHitstun_String
	mflr r6
	lhz	r7,TM_PostHitstunFrameCount(REG_FighterData)
	addi r7,r7,1
	Message_Display

	b Moonwalk_Exit



/*
		bl	CreateText

		#Change Text Color
		lhz	r3,TM_PostHitstunFrameCount(REG_FighterData)
		cmpwi	r3,0x0
		bne	RedText

		GreenText:
		load	r3,0x8dff6eff			#green
		b	StoreTextColor

		RedText:
		load	r3,0xffa2baff

		StoreTextColor:
		stw	r3,0x30(text)

		#Create Text
		bl	TopText
		mr 	r3,r29			#text pointer
		mflr	r4
		lfs	f1, -0x37B4 (rtoc)			#default text X/Y
		lfs	f2, -0x37B4 (rtoc)			#default text X/Y
		branchl r12,0x803a6b98

		#Create Text2
		bl	BottomText
		mr 	r3,r29			#text pointer
		mflr	r4
		lhz	r5,TM_PostHitstunFrameCount(REG_FighterData)
		addi	r5,r5,1
		lfs	f1, -0x37B4 (rtoc)			#default text X/Y
		lfs	f2, -0x37B0 (rtoc)			#shift down on Y axis
		branchl r12,0x803a6b98



	CreateText:
  mflr	r0
	stw	r0, 0x0004 (sp)
	stwu	sp, -0x0008 (sp)
	mr	r3,REG_FighterData			#backup REG_FighterData pointer
	li	r4,60			#display for 60 frames
	li	r5,0			#Area to Display (0-2)
	li	r6,15			#Window ID (Unique to This Display)
	branchl	r12,TextCreateFunction			#create text custom function
	mr	text,r3			#backup text pointer
  lwz	r0, 0x000C (sp)
	addi	sp, sp, 8
	mtlr r0
	blr
*/


###################
## TEXT CONTENTS ##
###################

ActOoHitstun_String:
blrl
.string "Act OoHitstun\nFrame %d"
.align 2

##############################


Moonwalk_Exit:
restore
blr
