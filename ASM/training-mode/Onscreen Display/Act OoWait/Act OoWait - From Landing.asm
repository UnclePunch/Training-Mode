#To be inserted at 800d5efc
.include "../../Globals.s"
.include "../../../m-ex/Header.s"

.set entity,31
.set playerdata,30
.set player,29
.set text,29
.set FramesSince,28
.set ASBeforeLanding,27

##########################################################
## 804a1f5c -> 804a1fd4 = Static Stock Icon Text Struct ##
## Is 0x80 long and is zero'd at the start              ##
##  of every VS Match				                        ##
## Store Text Info here                                 ##
##########################################################

backupall

#Check if Interrupted
	cmpwi r3,0x1
	bne	Moonwalk_Exit

	#CHECK IF ENABLED
	li	r0,0x10			#PowerShield ID
	#lwz	r4,-0xdbc(rtoc)			#get frame data toggle bits
	lwz	r4,-0x77C0(r13)
	lwz	r4,0x1F24(r4)
	li	r3, 1
	slw	r0, r3, r0
	and.	r0, r0, r4
	beq	Moonwalk_Exit

	CheckForFollower:
	mr	r3,playerdata
	branchl	r12,0x80005510
	cmpwi	r3,0x1
	beq	Moonwalk_Exit

#Ensure I'm Actually Coming from Landing (Wait interrupt is used for certain IASA)
	lhz	r3,TM_OneASAgo(playerdata)
	cmpwi	r3,ASID_Landing
	bne	Moonwalk_Exit

#Make Sure Player Didn't Buffer Crouch, Shield, or Walk
	lwz	r3,0x10(playerdata)
	cmpwi	r3,0xF
	beq	Moonwalk_Exit
	cmpwi	r3,0x10
	beq	Moonwalk_Exit
	cmpwi	r3,0x11
	beq	Moonwalk_Exit
	cmpwi	r3,0x27
	beq	Moonwalk_Exit
	cmpwi	r3,0xB2
	beq	Moonwalk_Exit
	cmpwi r3,ASID_SquatWait
	beq	Moonwalk_Exit

#Ensure player came from aerial attack landing or special move
CheckForAerial:
	lhz r3,TM_TwoASAgo(playerdata)
	cmpwi r3,ASID_AttackAirN
	blt	CheckForSpecialMove
	cmpwi r3,ASID_AttackAirLw
	bgt CheckForSpecialMove
	b	LandingSearch
CheckForSpecialMove:
	cmpwi r3,ASID_BarrelCannonWait
	ble	Moonwalk_Exit

LandingSearch:
#Calculate Frames Since Wait and Get AS Before Wait
	li	r5,0		#Loop Count
	li	r4,TM_PrevASStart
LandingSearchLoop:
	mulli	r3,r5,0x2
	add	r3,r3,r4
	lhzx	r3,r3,playerdata
	cmpwi	r3,ASID_Landing
	beq	LandingSearchExit
	addi	r5,r5,1
	cmpwi	r5,6
	bge	Moonwalk_Exit
	b	LandingSearchLoop
LandingSearchExit:
#Get AS Before Wait
	addi	r3,r5,1
	mulli	r3,r3,0x2
	add	r3,r3,r4
	lhzx	ASBeforeLanding,r3,playerdata
#Get Frames In Wait
	li	r4,TM_FramesInPrevASStart		#Frame Count Start
	li	FramesSince,0		#Init Frame Count
FrameCountLoop:
	cmpwi	r5,0
	beq	FrameCountLoopFinish
	mulli	r3,r5,0x2
	add	r3,r3,r4
	lhzx	r3,r3,playerdata
	add	FramesSince,r3,FramesSince
	subi	r5,r5,1
	b	FrameCountLoop
FrameCountLoopFinish:
	lhz	r3,TM_FramesInPrevASStart(playerdata)			#Frames spent in Wait
	add	FramesSince,r3,FramesSince			#Get Total Frames Since
#Minus in-actionable frames
	lfs	f1, 0x01F4 (playerdata)
	fctiwz f1,f1
	stfd f1,0xB0(sp)
	lwz r3,0xB4(sp)
	sub	FramesSince,FramesSince,r3

#Change Text Color
	cmpwi	FramesSince,0x0
	bne	RedText
GreenText:
	load	r3,0x8dff6eff			#green
	b	StoreTextColor
RedText:
	load	r3,0xffa2baff
	StoreTextColor:
	stw	r3,0x80(sp)


		#Create Text
		li	r3,5					#Message Kind
		lbz	r4,0xC(playerdata)	#Message Queue
		li	r5,MSGCOLOR_WHITE
		bl	Text
		mflr  r6
		addi	r7,FramesSince,1
		Message_Display
		
		ChangeColor:
		lwz	r3,0x2C(r3)
		lwz	r3,MsgData_Text(r3)
		li	r4,1
		addi r5,sp,0x80
		branchl r12,Text_ChangeTextColor



	b Moonwalk_Exit

###################
## TEXT CONTENTS ##
###################

Text:
blrl
.string "Act OoAutoCancel\nFrame: %d"
.align 2

##############################


Moonwalk_Exit:
restoreall
lwz	r0, 0x002C (sp)
