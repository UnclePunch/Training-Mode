#To be inserted at 8008e52c
.include "../../Globals.s"

.set entity,31
.set playerdata,31
.set player,30
.set text,29
.set textprop,28
.set hitbool,27

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

mr	playerdata,r3

	#CHECK IF ENABLED
	li	r0,OSD.Powershield			#PowerShield ID
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

	SDICheck:
	#Check For SDI
	fcmpo	cr0,f1,f0
	cror	2, 1, 2
	bne	NoSDI

	#Check For SDI Cont.
	lbz	r0, 0x0670 (playerdata)
	lwz	r4, -0x514C (r13)
	lwz	r5, 0x04B4 (r4)
	cmpw	r0, r5
	blt	SuccessfulSDI

	#Check For SDI Cont..
	lbz	r0, 0x0671 (playerdata)
	cmpw	r0, r5
	bge	NoSDI

	SuccessfulSDI:
	#Increment Successful SDI
	lhz	r3,SuccessfulSDIInputs(playerdata)
	addi	r3,r3,0x1
	sth	r3,SuccessfulSDIInputs(playerdata)

	NoSDI:
	#Increment Total SDI
	lhz	r3,TotalSDIInputs(playerdata)
	addi	r3,r3,0x1
	sth	r3,TotalSDIInputs(playerdata)




		bl	CreateText

		#Change color to Green if SDI'd once
		lhz	r3,SuccessfulSDIInputs(playerdata)
		cmpwi	r3,0x0
		beq	RedText
		load	r3,0x8dff6eff
		b	Toptext

		RedText:
		load	r3,0xffa2baff

		Toptext:
		stw	r3,0x30(text)
		#Create Text
		bl	SDI1
		mr 	r3,r29			#text pointer
		mflr	r4
		lfs	f1, -0x37B4 (rtoc)			#default text X/Y
		lfs	f2, -0x37B4 (rtoc)			#default text X/Y
		branchl r12,0x803a6b98

		#Create Text2
		bl	SDI2
		mr 	r3,r29			#text pointer
		mflr	r4
		lhz	r5,SuccessfulSDIInputs(playerdata)
		lhz	r6,TotalSDIInputs(playerdata)
		lfs	f1, -0x37B4 (rtoc)			#default text X/Y
		lfs	f2, -0x37B0 (rtoc)			#shift down on Y axis
		branchl r12,0x803a6b98

		b Moonwalk_Exit


	CreateText:
	mflr	r0
	stw	r0, 0x0004 (sp)
	stwu	sp, -0x0008 (sp)

	mr	r3,playerdata			#backup playerdata pointer
	li	r4,60			#display for 60 frames
	li	r5,0			#Area to Display (0-2)
	li	r6,11			#Window ID (Unique to This Display)
	branchl	r12,TextCreateFunction			#create text custom function
	mr	text,r3			#backup text pointer

	lwz	r0, 0x000C (sp)
	addi	sp, sp, 8
	mtlr r0
	blr


###################
## TEXT CONTENTS ##
###################

SDI1:
blrl
.string "SDI Inputs"
.align 2

SDI2:
blrl
.string "%d/%d"
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
