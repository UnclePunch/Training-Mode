#To be inserted at 80092e68
.include "../../../Globals.s"

.set entity,31
.set playerdata,30
.set player,31
.set text,29
.set actionableFlag,28
.set hitbool,27

##########################################################
## 804a1f5c -> 804a1fd4 = Static Stock Icon Text Struct ##
## Is 0x80 long and is zero'd at the start              ##
##  of every VS Match				                        ##
## Store Text Info here                                 ##
##########################################################

##############################
## Init FrameAdvantageThink ##
##############################

#CHECK IF ENABLED
	li	r0,OSD.FrameAdvantage			#PowerShield ID
	#lwz	r4,-0xdbc(rtoc)			#get frame data toggle bits
	lwz	r4,-0x77C0(r13)
	lwz	r4, 0x1F24(r4)
	li	r3, 1
	slw	r0, r3, r0
	and.	r0, r0, r4
	beq	InjectionExit

		#Check If Entity That Hit Shield Was a Player
			lwz	r3, 0x002C (r30)
			lwz	r3, 0x19A8 (r3)
			branchl	r12,0x80086960
			cmpwi	r3,0x0
			beq	InjectionExit

		#Store Pointer to Frame Advantage Think
			bl	FrameAdvantageThink
			mflr	r3
			lwz	r4, 0x002C (r30)
			lwz	r4, 0x19A8 (r4)
			lwz	r4, 0x002C (r4)
			stw	r3, 0x2414 (r4)

b	InjectionExit


###########################
## Frame Advantage Think ##
###########################

FrameAdvantageThink:
blrl

backup



mr	player,r3
lwz	playerdata,0x2c(player)

	#Get Entity Who Shielded Attack
		lwz	r20,0x2410(playerdata)

	#Self Destruct If Player was Hit or Grabbed
	#Check Hitstun
		lbz	r3, 0x221C (playerdata)
		rlwinm.	r0, r3, 31, 31, 31
		bne	SelfDestruct
	#Check Grabbed AS's
		lwz	r3,0x10(playerdata)
		cmpwi	r3,0xDF
		blt	SkipGrabCheck
		cmpwi	r3,0xE8
		bgt	SkipGrabCheck
		b	SelfDestruct
		SkipGrabCheck:

	#Check If ShieldStun Ended
		#lwz	r3,0x10(r20)
		#cmpwi	r3,0xB5
		#beq	Moonwalk_Exit

	#########################
	## Check If Actionable ##
	#########################

	#Am I in Non-IASA Landing?
		lwz	r3,0x10 (playerdata)
		cmpwi	r3,0x2A
		bne	SkipIASALandingCheck
		lfs	f1, 0x0894 (playerdata)
		lfs	f0, 0x01F4 (playerdata)
		fcmpo	cr0,f1,f0
		bge	Actionable
		SkipIASALandingCheck:
	#Check For Any Form of Jumping/Falling
		cmpwi	r3,0x19
		blt	SkipJumpFallCheck
		cmpwi	r3,0x22
		bgt	SkipJumpFallCheck
		b	Actionable
		SkipJumpFallCheck:
	#Check For AS Wait
		cmpwi	r3,0xE
		beq	Actionable
	#Check For AS CrouchWait
		cmpwi	r3,0x28
		beq	Actionable
	#Check For Peach Float
		lwz	r4,0x4(playerdata)
		cmpwi	r4,0x9
		bne	SkipPeachFloat
		cmpwi	r3,0x155
		beq	Actionable
		SkipPeachFloat:

	###########################
	## Check For IASA States ##
	###########################

	#Check Jabs Tilts Aerials Smash Attacks
		cmpwi	r3,0x2C
		blt	SkipAttackCheck
		cmpwi	r3,0x45
		bgt	SkipAttackCheck
		b	CheckIASA
		SkipAttackCheck:
	#Check Throws
		cmpwi	r3,0xDB
		blt	SkipThrowCheck
		cmpwi	r3,0xDE
		bgt	SkipThrowCheck
		b	CheckIASA
		SkipThrowCheck:

	b	Moonwalk_Exit


	#########################
	## Check for IASA Flag ##
	#########################

	CheckIASA:
		lbz	r3,0x2218(playerdata)
		rlwinm.	r3,r3,0,24,24
		beq	Moonwalk_Exit


	##########################
	## Get Frame Advantages ##
	##########################


	Actionable:
	#Check If Still in ShieldStun
		lwz	r3,0x10(r20)
		cmpwi	r3,0xB5
		bne	CheckFramesPassed


	####################################
	## Get Frames of Shield Stun Left ##
	####################################

	#Check Frames Left of Shield Stun
		lwz 	r3,0x590(r20)			#get anim data
		lfs	f1,0x008(r3)			#get anim length (float)
		lfs	f2,0x89C(r20)			#get anim speed
		lfs	f3,0x894(r20)			#get current AS
		fdivs	f4,f1,f2			#get calculated AS length in f4
		fdivs	f1,f3,f1			#yields percentage of animation finished
		fmuls	f1,f4,f1			#(DEFINED_LENGTH)*(PERCENTAGE)
		fsubs	f3,f4,f1			#SUBTRACT FROM DEFINED

				ConvertASFrameToInt:
				#ROUND APPROX FRAMES LEFT UP
				#GET FRAME NUMBER IN F1 WITHOUT DECIMAL POINT
				fctiwz	f1,f3
				stfd	f1,0xF0(sp)
				lwz	r3,0xF4(sp)
				xoris    r4,r3,0x8000
				lis   	 r5,0x4330
				stw   	 r5,0xF0(sp)
				stw   	 r4,0xF4(sp)
				lfd   	 f1,0xF0(sp)
				lfd	 f2,-0x7470(rtoc)    			#load magic number
				fsubs    f1,f1,f2

				#SUBTRACT ROUNDED DOWN NUMBER FROM ORIGINAL TO GET DECIMAL POINT
				fsubs	f1,f3,f1
				lfs	f2, -0x6B00 (rtoc)			#get 0 float

				#CHECK IF GREATER THAN 0.0
				fcmpo	cr0,f1,f2
				beq	RoundDown

				RoundUp:
				addi	r5,r3,0x1
				b	SubFrameCount

				RoundDown:
				mr	r5,r3

				SubFrameCount:
				subi	r21,r5,0x1			#backup frame number


	b	CreateTextGObj


	########################################
	## Get Frames Since Shield Stun Ended ##
	########################################

	CheckFramesPassed:
	#Check How Long Since Opponent's Shield Stun Ended
	#Search For Shield Stun In Opponent's Previous Actions
		li	r5,0		#loop count init
		addi	r4,r20,0x23F0		#Beginning of Prev Actions
		subi	r4,r4,0x2		#Adjust for lhzu instruction
	ShieldStunSearchLoop:
		lhzu	r3,0x2(r4)		#Get AS
		cmpwi	r3,0xB5		#Is this shield stun?
		beq	ShieldStunFound
		addi	r5,r5,1
		cmpwi	r5,6		#6 Total Prev Actions
		bgt	SelfDestruct		#Self Destruct if not Found
		b	ShieldStunSearchLoop

	ShieldStunFound:
		li	r21,0		#total frame count init
		addi	r4,r20,0x23FC		#Beginning of Prev AS Frames
		subi	r4,r4,0x2		#Adjust for lhzu instruction
	ShieldStunFrameCountLoop:
		cmpwi	r5,0		#Check If Done
		ble	ShieldStunAddCurrentAS
		lhzu	r3,0x2(r4)		#Get Frame Count
		add	r21,r21,r3		#Add to Total
		subi	r5,r5,1
		b	ShieldStunFrameCountLoop
	ShieldStunAddCurrentAS:
		lhz	r3,0x23EC(r20)		#Add Current AS's Frame Count as Well
		add	r21,r21,r3

	CreateTextGObj:
	#Create Text GObj
		bl	CreateText

	#Change Text Color
	#Check If Still in ShieldStun
		lwz	r3,0x10(r20)
		cmpwi	r3,0xB5
		beq	GreenText
		load	r3,0xffa2baff			#red
		b	StoreTextColor
	GreenText:
		load	r3,0x8dff6eff			#green
		neg	r21,r21			#Make Positive When Displaying
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
		neg	r5,r21
		lfs	f1, -0x37B4 (rtoc)			#default text X/Y
		lfs	f2, -0x37B0 (rtoc)			#shift down on Y axis
		branchl r12,0x803a6b98

	#Self Destruct
	SelfDestruct:
		li	r3,0
		stw	r3,0x2414(playerdata)

	#Exit
		b Moonwalk_Exit


CreateText:
	mflr	r0
	stw	r0, 0x0004 (sp)
	stwu	sp, -0x0008 (sp)
	mr	r3,playerdata
	li	r4,60			#display for 60 frames
	li	r5,0			#Area to Display (0-2)
	li	r6,22			#Window ID (Unique to This Display)
	branchl	r12,TextCreateFunction			#create text custom function
	mr	text,r3			#backup text pointer
	lwz	r0, 0x000C (sp)
	addi	sp, sp, 8
	mtlr r0
	blr

###################
## TEXT CONTENTS ##
###################

TopText:
blrl
.string "Frame Advantage"
.align 2

BottomText:
blrl
.string "%d Frames"
.align 2

##############################


Moonwalk_Exit:
restore
blr


############################################################################


InjectionExit:
lwz	r3, 0x002C (r30)
