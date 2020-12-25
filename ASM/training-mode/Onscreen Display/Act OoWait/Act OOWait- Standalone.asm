#To be inserted at 8000551c
.include "../../Globals.s"
.include "../../../m-ex/Header.s"

.set entity,31
.set playerdata,31
.set player,30
.set text,29
.set FramesSince,28
.set ASBeforeWait,27
.set REG_Color,26

##########################################################
## 804a1f5c -> 804a1fd4 = Static Stock Icon Text Struct ##
## Is 0x80 long and is zero'd at the start              ##
##  of every VS Match				                        ##
## Store Text Info here                                 ##
##########################################################

backupall

#Get Player Pointers
	mr	player,r3
	lwz	playerdata,0x2c(player)

	#CHECK IF ENABLED
	li	r0,OSD.ActOoWait			#PowerShield ID
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

#Calculate Frames Since Wait and Get AS Before Wait
	li	r5,0		#Loop Count
	li	r4,TM_PrevASStart
WaitSearchLoop:
	mulli	r3,r5,0x2
	add	r3,r3,r4
	lhzx	r3,r3,playerdata
	cmpwi	r3,0xE
	beq	WaitSearchExit
	addi	r5,r5,1
	cmpwi	r5,6
	bge	Moonwalk_Exit
	b	WaitSearchLoop
WaitSearchExit:
#Get AS Before Wait
	addi	r3,r5,1
	mulli	r3,r3,0x2
	add	r3,r3,r4
	lhzx	ASBeforeWait,r3,playerdata
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


#Check If Under 13 Frames
	cmpwi	FramesSince,13
	bgt	Moonwalk_Exit

#Only Coming from Throws, Aerial Landing, and Teching/Getups
#Aerial Landing
	cmpwi	ASBeforeWait,0x46
	blt	NotThrow
	cmpwi	ASBeforeWait,0x4A
	bgt	NotThrow
	b	ComingFromWhitelist
	NotThrow:
#Throws
	cmpwi	ASBeforeWait,0xDB
	blt	NotAerialLanding
	cmpwi	ASBeforeWait,0xDE
	bgt	NotAerialLanding
	b	ComingFromWhitelist
	NotAerialLanding:
#Teching/Getups
#Aerial Landing
	cmpwi	ASBeforeWait,0xB7
	blt	NotTeching
	cmpwi	ASBeforeWait,0xC9
	bgt	NotTeching
	b	ComingFromWhitelist
	NotTeching:
#Wavedash
	cmpwi	ASBeforeWait,ASID_LandingFallSpecial
	bne	NotWavedash 
	b	ComingFromWhitelist
NotWavedash:
	b	Moonwalk_Exit
ComingFromWhitelist:

		SpawnText:
		#Change Text Color
		cmpwi	FramesSince,0x1
		bne	RedText
		GreenText:
		load	r3,0x8dff6eff			#green
		b	StoreTextColor
		RedText:
		load	r3,0xffa2baff
		StoreTextColor:
		stw r3,0x80(sp)

		#Create Text
		li	r3,5					#Message Kind
		lbz	r4,0xC(playerdata)	#Message Queue
		li	r5,MSGCOLOR_WHITE
		bl	TechText
		mflr  r6
		mr	r7,FramesSince
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

TechText:
blrl
.string "Act OoWait\nFrame: %d"
.align 2

##############################


Moonwalk_Exit:
restoreall
blr
