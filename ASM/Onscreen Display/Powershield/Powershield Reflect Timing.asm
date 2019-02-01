#To be inserted at 800776a0
.include "../../Globals.s"

.set entity,31
.set playerdata,31
.set projectile,30
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

	mr	playerdata,r5

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

	#Check For PS Intent
	lwz	r3,0x10(playerdata)
	cmpwi	r3,0xB2			#All
	beq	LightShielding
	cmpwi	r3,0x155			#Yoshi
	beq	LightShielding
	cmpwi	r3,0xB6			#All
	beq	LatePS
	cmpwi	r3,0x159			#Yoshi
	beq	LatePS
	b	Moonwalk_Exit

	LatePS:
	CreateText:
	mr	r3,playerdata			#backup playerdata pointer
	li	r4,60			#display for 60 frames
	li	r5,0			#Area to Display (0-2)
	li	r6,9			#Window ID (Unique to This Display)
	branchl	r12,TextCreateFunction			#create text custom function

	mr	text,r3			#backup text pointer

	TopLine:
	bl	PowerShieldText
	mr 	r3,r29			#text pointer
	mflr	r4
	lfs	f1, -0x37B4 (rtoc)			#default text X/Y
	lfs	f2, -0x37B4 (rtoc)			#default text X/Y
	branchl r12,0x803a6b98

	BottomLine:
	#Check If Reflect Bubble is Active (Missed Powershield)
	lbz	r3,0x2218(playerdata)
	rlwinm.	r3,r3,0,27,27
	beq	NoReflect

	MissedReflect:
	lfs	f1,0x2340(playerdata)
	fctiwz	f1,f1
	stfd	f1,0xF0(sp)
	lwz	r5,0xF4(sp)
	addi	r5,r5,0x1
	bl	LateText
	b	BottomTextCont

	NoReflect:
	load	r3,0xffa2baff
	stw	r3,0x30(text)
	lfs	f1,0x2340(playerdata)
	fctiwz	f1,f1
	stfd	f1,0xF0(sp)
	lwz	r5,0xF4(sp)
	subi	r5,r5,0x1
	bl	ReflectEndedText

	BottomTextCont:
	mflr	r4
	mr	r3,text
	lfs	f1, -0x37B4 (rtoc)			#default text X/Y
	lfs	f2, -0x37B0 (rtoc)			#shift down on Y axis
	branchl r12,0x803a6b98
	b	Moonwalk_Exit





	LightShielding:
	#Create Text
	mr	r3,playerdata			#backup playerdata pointer
	li	r4,60			#display for 60 frames
	li	r5,0			#Area to Display (0-2)
	li	r6,9			#Window ID (Unique to This Display)
	branchl	r12,TextCreateFunction			#create text custom function
	mr	text,r3			#backup text pointer

	bl	PowerShieldText
	mr 	r3,r29			#text pointer
	mflr	r4
	lfs	f1, -0x37B4 (rtoc)			#default text X/Y
	lfs	f2, -0x37B4 (rtoc)			#default text X/Y
	branchl r12,0x803a6b98

	bl	NoHardPress
	mflr	r4
	mr	r3,text
	lfs	f1, -0x37B4 (rtoc)			#default text X/Y
	lfs	f2, -0x37B0 (rtoc)			#shift down on Y axis
	branchl r12,0x803a6b98
	b	Moonwalk_Exit


###################
## TEXT CONTENTS ##
###################

PowerShieldText:
blrl
.string "Missed Powershield"
.align 2

LateText:
blrl
.string "%df Early"
.align 2

ReflectEndedText:
blrl
.string "Reflect Ended %df"
.align 2

NoHardPress:
blrl
.string "No Hard Press"
.align 2

##############################


Moonwalk_Exit:
restoreall
mr	r28, r4
