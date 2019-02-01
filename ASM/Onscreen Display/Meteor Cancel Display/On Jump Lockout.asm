#To be inserted at 8008fa18
.include "../../Globals.s"

.set entity,31
.set playerdata,31
.set player,30
.set text,29
.set textprop,28

##########################################################
## 804a1f5c -> 804a1fd4 = Static Stock Icon Text Struct ##
## Is 0x80 long and is zero'd at the start              ##
##  of every VS Match				                        ##
## Store Text Info here                                 ##
##########################################################

backupall

	#CHECK IF ENABLED
	li	r0,OSD.MeteorCancel			#wavedash ID
	#lwz	r4,-0xdbc(rtoc)			#get frame data toggle bits
	lwz	r4,-0x77C0(r13)
	lwz	r4,0x1F24(r4)
	li	r3, 1
	slw	r0, r3, r0
	and.	r0, r0, r4
	beq	Moonwalk_Exit

	#CHECK IF METEOR CANCEL IS AVAILABLE
	lbz	r0, 0x235A (playerdata)
	cmplwi	r0, 0
	beq	Moonwalk_Exit

	MC_Continue:
	#CHECK IF FIRST FRAME OF LOCKOUT
	lwz	r3,0x2354 (r31)
	cmpwi	r3,0x0
	bne	Moonwalk_Exit

	JumpLockout:
	mr	r3,playerdata			#backup playerdata pointer
	li	r4,60			#display for 60 frames
	li	r5,0			#Area to Display (0-2)
	li	r6,4			#Window ID (Unique to This Display)
	branchl	r12,TextCreateFunction			#create text custom function


	mr	text,r3			#backup text pointer


		LatePress:
		#INITALIZE TEXT 1
		mr 	r3,r29			#text pointer

	###################################
	## DETERMINE METHOD OF FAILED MC ##
	###################################

		lwz	r5, -0x514C (r13)
		lfs	f0, 0x0070 (r5)
		lfs	f1, 0x0624 (playerdata)
		fcmpo	cr0,f1,f0
		cror	2, 1, 2
		bne	XY

		TapJump:
		bl	TapJumpLockoutASCII
		mflr	r4
		b	DisplayLockoutFrames
		XY:
		bl	XYLockoutASCII
		mflr 	r4			#get ASCII to print		#get ASCII to print

		DisplayLockoutFrames:
		lfs	f1, -0x37B4 (rtoc)			#default text X/Y
		lfs	f2, -0x37B4 (rtoc)			#default text X/Y
		branchl r12,0x803a6b98





		mr 	r3,r29			#text pointer
		bl	EarlyASCII
		mflr	r4
		lbz	r5, 0x235B (playerdata)	#get how many frames early

		lfs	f1, -0x37B4 (rtoc)			#default text X/Y
		lfs	f2, -0x37B0 (rtoc)			#shift down on Y axis
		branchl r12,0x803a6b98

		b Moonwalk_Exit


###################
## TEXT CONTENTS ##
###################

XYLockoutASCII:
blrl
.string "XY Lockout"
.align 2

TapJumpLockoutASCII:
blrl
.string "TapJmp Lockout"
.align 2

EarlyASCII:
blrl
#%df Early
.string "%df Early"
.align 2

##############################

Moonwalk_Exit:
restoreall
lfs	f0, 0x2340 (r31)
