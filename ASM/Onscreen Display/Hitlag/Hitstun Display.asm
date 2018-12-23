#To be inserted at 8006d990
.include "D:/Users/Vin/Documents/GitHub/Training-Mode/ASM/Globals.s"

.set entity,31
.set playerdata,30
.set player,31
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

	#CHECK IF ENABLED
	li	r0,12			#wavedash ID
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

	#CHECK FOR HITLAG FIRST
	lbz	r3,0x2219(playerdata)
	rlwinm.	r3,r3,0,29,29
	beq	CheckHitstun
	li	hitbool,0x0			#isHitlag
	lwz	r3,0x195C(playerdata)
	cmpwi	r3,0x0		#check if in hitlag still
	beq	Moonwalk_Exit		#if not exit
	b	CreateText

	CheckHitstun:
	lbz	r3,0x221C(playerdata)
	rlwinm.	r0, r3, 31, 31, 31
	beq	Moonwalk_Exit

		Hitstun:
		li	hitbool,0x1
		lwz	r3,0x2340(playerdata)
		cmpwi	r3,0x0		#check if in hitstun still
		beq	Moonwalk_Exit		#if not exit


	CreateText:
	mr	r3,playerdata			#backup playerdata pointer
	li	r4,1			#display for 60 frames
	li	r5,1			#Area to Display (0-2)
	li	r6,16			#Window ID (Unique to This Display)
	branchl	r12,TextCreateFunction			#create text custom function



	mr	text,r3			#backup text pointer





		#########################
		## CHECK IF LAST FRAME ##
		#########################

		CheckIfLastFrame:
		cmpwi hitbool,0x0
		beq CheckIfLastFrame_Hitlag

		CheckIfLastFrame_Hitstun:
		lfs	f1,0x2340(playerdata)
		b	CheckIfLastFrame_CompareWithZero

		CheckIfLastFrame_Hitlag:
		lfs	f1,0x195C(playerdata)

		CheckIfLastFrame_CompareWithZero:
		lfs	f2, -0x757C (rtoc)
		fcmpo	cr0,f1,f2
		bgt	InitializeText

			ChangeColor:
			load	r3,0x00FF00FF
			stw	r3,0x30(text)




		InitializeText:
		#INITALIZE TEXT 1
		mr 	r3,r29			#text pointer

		#GET APPROPRIATE ASCII
		cmpwi	hitbool,0x0
		bne	loadHitstunASCII
		bl	HitlagASCII
		b	InitializeText_Continue
		loadHitstunASCII:
		bl	HitstunASCII

		InitializeText_Continue:
		mflr 	r4			#get ASCII to print
		lfs	f1, -0x37B4 (rtoc)			#default text X/Y
		lfs	f2, -0x37B4 (rtoc)			#default text X/Y
		branchl r12,0x803a6b98





		#INITALIZE TEXT 2
		mr 	r3,r29			#text pointer
		bl	HitstunASCII2
		mflr 	r4			#get ASCII to print

		#GET APPROPRIATE FLOAT
		cmpwi	hitbool,0x0
		bne	loadHitstunFrames
		lfs	f1,0x195C(playerdata)
		b	InitializeText_Continue2
		loadHitstunFrames:
		lfs	f1,0x2340(playerdata)

		InitializeText_Continue2:
		fctiwz	f1,f1
		stfd	f1,0xF0(sp)
		lwz	r5,0xF4(sp)
		cmpwi	r5,0x0
		beq	skipSub
		subi	r5,r5,0x1

		skipSub:
		lfs	f1, -0x37B4 (rtoc)			#default text X/Y
		lfs	f2, -0x37B0 (rtoc)			#shift down on Y axis
		branchl r12,0x803a6b98

		b Moonwalk_Exit



###################
## TEXT CONTENTS ##
###################

HitstunASCII:
blrl
.string "Hitstun"
.align 2

HitstunASCII2:
blrl
.string "Left: %df"
.align 2

HitlagASCII:
blrl
.string "Hitlag"
.align 2

##############################


Moonwalk_Exit:
restoreall
mr	r3,player
lmw	r25, 0x0034 (sp)
