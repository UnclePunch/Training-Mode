#To be inserted at 8006c600
.include "D:/Users/Vin/Documents/GitHub/Training-Mode/ASM/Globals.s"

.set entity,31
.set playerdata,31
.set player,30
.set text,29
.set textprop,28
.set hitbool,27
.set framenumber,26

##########################################################
## 804a1f5c -> 804a1fd4 = Static Stock Icon Text Struct ##
## Is 0x80 long and is zero'd at the start              ##
##  of every VS Match				                        ##
## Store Text Info here                                 ##
##########################################################

backupall

	mr	player,r3
	lwz	playerdata,0x2C(player)


	#CHECK IF ENABLED
	li	r0,14			#wavedash ID
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

	CheckStates:
	#CHECK IF IN NONO STATES
	bl	IgnoreStates
	mflr	r4
	subi	r4,r4,0x2
	lwz	r3,0x10(playerdata)

		DamageCheckLoopStart:
		lhzu	r5,0x2(r4)
		cmplwi	r5,0xFFFF
		beq 	CreateText
		cmpw	r3,r5
		beq	Moonwalk_Exit
		b	DamageCheckLoopStart

	CreateText:
	mr	r3,playerdata			#backup playerdata pointer
	li	r4,1			#display for 60 frames
	li	r5,1			#Area to Display (0-2)
	li	r6,18			#Window ID (Unique to This Display)
	branchl	r12,TextCreateFunction			#create text custom function


	mr	text,r3			#backup text pointer





		#####################
		## GET FRAMES LEFT ##
		#####################


		#CHECK FOR AERIAL LAND, JS, DASH
		lwz	r3,0x10(playerdata)
		cmpwi	r3,0x46		#nair land
		blt	CheckForJS
		cmpwi	r3,0x4A		#fair land
		bgt	GetFramesLeft
		b	AerialLand

		CheckForJS:
		cmpwi	r3,0x18
		beq	JumpSquat
		b	GetFramesLeft


			AerialLand:
			lwz	framenumber,0x2340(playerdata)
			subi	framenumber,framenumber,0x1
			stw	framenumber,0x2340(playerdata)
			b 	GetFramesLeft_ExceptionAerialLand




			JumpSquat:
			lfs	f1,0x148(playerdata)			#get JS frames
			b 	GetFramesLeft_ExceptionJumpSquat



		GetFramesLeft:
		lwz 	r5,0x590(playerdata)			#get anim data
		lfs	f1,0x008(r5)			#get anim length (float)

		GetFramesLeft_ExceptionJumpSquat:
		lfs	f2,0x89C(playerdata)			#get anim speed
		lfs	f3,0x894(playerdata)			#get current AS

		#CHECK IF ANIM SPEED IS 0
		lfs	f4, -0x6B00 (rtoc)
		fcmpo	cr0,f2,f4
		bne	CheckIfAnimLengthIsZero
		fsubs	f3,f1,f3
		b	ConvertASFrameToInt

		CheckIfAnimLengthIsZero:
		fcmpo	cr0,f1,f4
		bne	ContinueFrameCalculation
		lfs	f1, -0x7584 (rtoc)		#0
		lfs	f2, -0x7584 (rtoc)		#0
		lfs	f3, -0x6B00 (rtoc)		#1



		ContinueFrameCalculation:
		fdivs	f4,f1,f2			#get calculated AS length in f4
		fdivs	f1,f3,f1			#yields percentage of animation finished
		fmuls	f1,f4,f1			# (DEFINED_LENGTH)*(PERCENTAGE)
		fsubs	f3,f4,f1			#SUBTRACT FROM DEFINED

				ConvertASFrameToInt:
				#ROUND APPROX FRAMES LEFT UP
				#GET FRAME NUMBER IN F1 WITHOUT DECIMAL POINT
				fctiwz	f1,f3
				stfd	f1,-0x14(sp)
				lwz	r3,-0x10(sp)
				xoris    r4,r3,0x8000
				lis   	 r5,0x4330
				stw   	 r5,-0x14(sp)
				stw   	 r4,-0x10(sp)
				lfd   	 f1,-0x14(sp)
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
				subi	framenumber,r5,0x1			#backup frame number

		GetFramesLeft_ExceptionAerialLand:


			####################
			## CHECK FOR IASA ##
			####################

			lbz	r3, 0x2218 (playerdata)
			rlwinm.	r3, r3, 25, 31, 31
			beq	CheckIfLastFrame

				#CHANGE COLOR TO CYAN
				load	r3,0x00FFFFFF
				stw	r3,0x30(text)

			#########################
			## CHECK IF LAST FRAME ##
			#########################
			CheckIfLastFrame:
			cmpwi	framenumber,0x0
			bne	InitializeText

				#CHANGE COLOR TO GREEN
				load	r3,0x00FF00FF
				stw	r3,0x30(text)


		InitializeText:
		#INITALIZE TEXT 1
		mr 	r3,r29			#text pointer
		bl	HitstunASCII
		mflr 	r4			#get ASCII to print
		lfs	f1, -0x37B4 (rtoc)			#default text X/Y
		lfs	f2, -0x37B4 (rtoc)			#default text X/Y
		branchl r12,0x803a6b98


		#INITALIZE TEXT 2
		InitalizeText2:
		mr 	r3,r29			#text pointer
		bl	HitstunASCII2
		mflr 	r4			#get ASCII to print
		mr	r5,framenumber
		lfs	f1, -0x37B4 (rtoc)			#default text X/Y
		lfs	f2, -0x37B0 (rtoc)			#shift down on Y axis
		branchl r12,0x803a6b98

		b Moonwalk_Exit


###################
## TEXT CONTENTS ##
###################

HitstunASCII:
blrl
.string "AS Frames"
.align 2

HitstunASCII2:
blrl
.string "Left: %df"
.align 2

IgnoreStates:
blrl
.long 0x0142000E
.long 0x0000000C
.long 0x000D0143
.long 0x01440014
.long 0x000BFFFF

##############################


Moonwalk_Exit:
restoreall
lwz	r4, 0x002C (r3)
