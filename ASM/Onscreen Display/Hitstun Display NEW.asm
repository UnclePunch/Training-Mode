#To be inserted at 8006d990
.macro branchl reg, address
lis \reg, \address @h
ori \reg,\reg,\address @l
mtctr \reg
bctrl
.endm

.macro branch reg, address
lis \reg, \address @h
ori \reg,\reg,\address @l
mtctr \reg
bctr
.endm

.macro load reg, address
lis \reg, \address @h
ori \reg, \reg, \address @l
.endm

.macro loadf regf,reg,address
lis \reg, \address @h
ori \reg, \reg, \address @l
stw \reg,-0x4(sp)
lfs \regf,-0x4(sp)
.endm

.macro backup
mflr r0
stw r0, 0x4(r1)
stwu	r1,-0x100(r1)	# make space for 12 registers
stmw  r3,0x8(r1)
.endm

.macro restore
lmw  r3,0x8(r1)
lwz r0, 0x104(r1)
addi	r1,r1,0x100	# release the space
mtlr r0
.endm

.macro intToFloat reg,reg2
xoris    \reg,\reg,0x8000
lis    r18,0x4330
lfd    f16,-0x7470(rtoc)    # load magic number
stw    r18,0(r2)
stw    \reg,4(r2)
lfd    \reg2,0(r2)
fsubs    \reg2,\reg2,f16
.endm

.set ActionStateChange,0x800693ac
.set HSD_Randi,0x80380580
.set HSD_Randf,0x80380528
.set Wait,0x8008a348
.set Fall,0x800cc730
.set TextCreateFunction,0x80005928

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

backup

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
	li	r4,60			#display for 60 frames
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
.long 0x48697473
.long 0x74756e00

HitstunASCII2:
blrl
.long 0x4c656674
.long 0x3a202564
.long 0x66000000





HitlagASCII:
blrl
.long 0x4869746c
.long 0x61670000


##############################


Moonwalk_Exit:
restore
mr	r3,player
lmw	r25, 0x0034 (sp)
