#To be inserted at 8000550C
.include "../../Globals.s"

.set entity,31
.set REG_PlayerData,31
.set REG_PlayerGObj,30
.set REG_TextGObj,29
.set textprop,28
.set hitbool,27

##########################################################
## 804a1f5c -> 804a1fd4 = Static Stock Icon Text Struct ##
## Is 0x80 long and is zero'd at the start              ##
##  of every VS Match				                        ##
## Store Text Info here                                 ##
##########################################################

backupall

lwz	REG_PlayerData,0x2c(r4)

#CHECK IF ENABLED
	li	r0,OSD.GrabBreakout			#PowerShield ID
	lwz	r4,-0x77C0(r13)
	lwz	r4,0x1F24(r4)
	li	r3, 1
	slw	r0, r3, r0
	and.	r0, r0, r4
	beq	Moonwalk_Exit

bl	CreateText

#Create Text 1
	mr 	r3,REG_TextGObj			#text pointer
	bl	GrabMashOut_TopText
	mflr	r4
	lfs	f1, -0x37B4 (rtoc)			#default text X/Y
	lfs	f2, -0x37B4 (rtoc)			#default text X/Y
	crset 6
	branchl r12,Text_InitializeSubtext

#Calculate quickest possible mashout (ceil(mashout/13))
	li	r3,13
	bl	IntToFloat
	lfs	f2,0x2354(REG_PlayerData)
	fdivs f1,f2,f1
	fctiwz f1,f1
	stfd f1,0x80(sp)
	lwz r3,0x84(sp)
	addi	r20,r3,1				#get min frame count
	mr	r3,r20
	bl	IntToFloat
	stfs f1,0x80(sp)
#Create Text 2
	mr 	r3,REG_TextGObj			#text pointer
	bl	GrabMashOut_BottomText
	mflr	r4
	lhz r5,FramesinCurrentAS(REG_PlayerData)
	addi r5,r5,1
	mr	r6,r20
	lfs	f1, -0x37B4 (rtoc)			#default text X/Y
	lfs	f2, -0x37B0 (rtoc)			#default text X/Y
	crset 6
	branchl r12,Text_InitializeSubtext

#Check if will break out this frame
	lfs f1,0x1A4C(REG_PlayerData)
	lfs	f2, -0x37B4 (rtoc)				#default text X/Y
	fcmpo cr0,f1,f2
	bgt Moonwalk_Exit
#Score breakout
	bl	Floats
	mflr r20
	li	r3,15
	bl	IntToFloat
	lfs f2,0x80(sp)
	lfs f3,0x0(r20)
	fmuls f3,f2,f3
	fadds f3,f2,f3
	fadds f3,f1,f3
	fctiwz f3,f3
	stfd f3,0x80(sp)
	lwz r3,0x84(sp)
	lhz r4,FramesinCurrentAS(REG_PlayerData)
	addi r4,r4,1
	cmpw r4,r3
	ble GreatMash
	lfs f3,0x4(r20)
	fmuls f3,f2,f3
	fadds f3,f2,f3
	fadds f3,f1,f3
	fctiwz f3,f3
	stfd f3,0x80(sp)
	lwz r3,0x84(sp)
	cmpw r4,r3
	ble	GoodMash
	b Moonwalk_Exit
GreatMash:
	load	r3,0x8dff6eff
	b	ChangeColor
GoodMash:
	load	r3,0xfff000ff
ChangeColor:
	stw r3,0x80(sp)
	mr	r3,REG_TextGObj
	li	r4,2
	addi r5,sp,0x80
	branchl r12,Text_ChangeTextColor

	b Moonwalk_Exit

#########################################
CreateText:
	mflr	r0
	stw	r0, 0x0004 (sp)
	stwu	sp, -0x0008 (sp)

	mr	r3,REG_PlayerData				#backup REG_PlayerData pointer
	li	r4,90										#display for 60 frames
	li	r5,0										#Area to Display (0-2)
	li	r6,OSD.GrabBreakout			#Window ID (Unique to This Display)
	branchl	r12,TextCreateFunction			#create text custom function

	mr	REG_TextGObj,r3			#backup text pointer

	lwz	r0, 0x000C (sp)
	addi	sp, sp, 8
	mtlr r0
	blr
##########################################
IntToFloat:
	backup
	mr	r4,r3
	li	r3,0
	branchl r12,0x80322da0
	restore
	blr
##########################################

###################
## TEXT CONTENTS ##
###################

GrabMashOut_TopText:
blrl
.string "Grab Breakout"
.align 2

GrabMashOut_BottomText:
blrl
.string "Frame %d/%d"
.align 2
##############################
Floats:
blrl
.float 0.5
.float 1
##############################
Moonwalk_Exit:
restoreall
blr
