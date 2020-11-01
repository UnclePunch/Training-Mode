#To be inserted at 80092e68
.include "../../../Globals.s"
.include "../../../../m-ex/Header.s"

.set entity,31
.set REG_FighterData,30
.set player,31
.set text,29
.set actionableFlag,28
.set hitbool,27
.set REG_FrameAdvantage,26
.set REG_TextColor,25

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
			stw	r3, TM_AnimCallback (r4)

b	InjectionExit


###########################
## Frame Advantage Think ##
###########################

FrameAdvantageThink:
blrl

.set REG_VictimData, 20

backup



mr	player,r3
lwz	REG_FighterData,0x2c(player)

	#Get Entity Who Shielded Attack
		lwz	REG_VictimData,TM_PlayerWhoShieldedAttack(REG_FighterData)

	#Self Destruct If Player was Hit or Grabbed
	#Check Hitstun
		lbz	r3, 0x221C (REG_FighterData)
		rlwinm.	r0, r3, 31, 31, 31
		bne	SelfDestruct
	#Check Grabbed AS's
		lwz	r3,0x10(REG_FighterData)
		cmpwi	r3,0xDF
		blt	SkipGrabCheck
		cmpwi	r3,0xE8
		bgt	SkipGrabCheck
		b	SelfDestruct
		SkipGrabCheck:

	#Check If ShieldStun Ended
		#lwz	r3,0x10(REG_VictimData)
		#cmpwi	r3,0xB5
		#beq	Moonwalk_Exit

	#########################
	## Check If Actionable ##
	#########################

	#Am I in Non-IASA Landing?
		lwz	r3,0x10 (REG_FighterData)
		cmpwi	r3,0x2A
		bne	SkipIASALandingCheck
		lfs	f1, 0x0894 (REG_FighterData)
		lfs	f0, 0x01F4 (REG_FighterData)
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
		lwz	r4,0x4(REG_FighterData)
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
		lbz	r3,0x2218(REG_FighterData)
		rlwinm.	r3,r3,0,24,24
		beq	Moonwalk_Exit


	##########################
	## Get Frame Advantages ##
	##########################


	Actionable:
	#Check If Still in ShieldStun
		lwz	r3,0x10(REG_VictimData)
		cmpwi	r3,0xB5
		bne	CheckFramesPassed


	####################################
	## Get Frames of Shield Stun Left ##
	####################################

	#Check Frames Left of Shield Stun
		lwz 	r3,0x590(REG_VictimData)			#get anim data
		lfs	f1,0x008(r3)			#get anim length (float)
		lfs	f2,0x89C(REG_VictimData)			#get anim speed
		lfs	f3,0x894(REG_VictimData)			#get current AS
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
				subi	REG_FrameAdvantage,r5,0x1			#backup frame number


	b	CreateTextGObj


	########################################
	## Get Frames Since Shield Stun Ended ##
	########################################

	CheckFramesPassed:
	#Check How Long Since Opponent's Shield Stun Ended
	#Search For Shield Stun In Opponent's Previous Actions
		li	r5,0		#loop count init
		addi	r4,REG_VictimData,TM_PrevASStart		#Beginning of Prev Actions
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
		li	REG_FrameAdvantage,0		#total frame count init
		addi	r4,REG_VictimData,TM_FramesInPrevASStart		#Beginning of Prev AS Frames
		subi	r4,r4,0x2		#Adjust for lhzu instruction
	ShieldStunFrameCountLoop:
		cmpwi	r5,0		#Check If Done
		ble	ShieldStunAddCurrentAS
		lhzu	r3,0x2(r4)		#Get Frame Count
		sub	REG_FrameAdvantage,REG_FrameAdvantage,r3		#Add to Total
		subi	r5,r5,1
		b	ShieldStunFrameCountLoop
	ShieldStunAddCurrentAS:
		lhz	r3,TM_FramesinCurrentAS(REG_VictimData)		#Add Current AS's Frame Count as Well
		sub	REG_FrameAdvantage,REG_FrameAdvantage,r3

	CreateTextGObj:

	#Check if frame 1
	cmpwi	REG_FrameAdvantage,-6
	blt	WhiteText
	GreenText:
	li	REG_TextColor,MSGCOLOR_GREEN
	b	PrintMessage	

	WhiteText:
	li	REG_TextColor,MSGCOLOR_WHITE
	b	PrintMessage

	PrintMessage:
	li	r3,6						#Message Kind
	lbz	r4,0xC(REG_FighterData)		#Message Queue
	mr	r5,REG_TextColor
	bl	FrameAdvantage_String
	mflr r6
	mr	r7,REG_FrameAdvantage

	Message_Display

	#Self Destruct
	SelfDestruct:
		li	r3,0
		stw	r3,TM_AnimCallback(REG_FighterData)

	#Exit
		b Moonwalk_Exit

###################
## TEXT CONTENTS ##
###################

FrameAdvantage_String:
blrl
.string "Frame Advantage\n%d Frames"
.align 2

##############################


Moonwalk_Exit:
restore
blr


############################################################################


InjectionExit:
lwz	r3, 0x002C (r30)
