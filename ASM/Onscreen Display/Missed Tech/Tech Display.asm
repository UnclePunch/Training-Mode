#To be inserted at 8006c5d4
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

backup

	mr	player,r29
	lwz	playerdata,0x2c(player)

	#CHECK IF ENABLED
	li	r0,2			#wavedash ID
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

	#CHECK IF FAILED A TECH
	lwz	r3,0x10(playerdata)
	cmpwi	r3,0xBF
	beq FailedTech
	cmpwi	r3,0xF7
	beq FailedTech
	cmpwi	r3,0xB7
	beq FailedTech
	cmpwi	r3,0xF8
	beq FailedTech
	b	Moonwalk_Exit

	FailedTech:

	#CHECK IF FRAME 0
	lfs	f1,0x894(playerdata)
	lfs	f2, -0x75A8 (rtoc)
	fcmpo	cr0,f1,f2
	bne 	Moonwalk_Exit

	#CHECK IF 1 OR 0 FRAMES LEFT OF HITLAG
	lfs	f1,0x195C(playerdata)
	lfs	f2, -0x75A0 (rtoc)
	fcmpo	cr0,f1,f2
	bgt	Moonwalk_Exit

	mr	r3,playerdata			#backup playerdata pointer
	li	r4,60			#display for 60 frames
	li	r5,0			#Area to Display (0-2)
	li	r6,2			#Window ID (Unique to This Display)
	branchl	r12,TextCreateFunction			#create text custom function


	mr	text,r3			#backup text pointer



	#####################################
	## DETERMINE METHOD OF FAILED TECH ##
	#####################################

	#Make Text Red
	load	r3,0xffa2baff			#Red
	stw	r3,0x30(text)			#Store Color

	#CHECK IF PRESSED WITHIN LAST 20 FRAMES
	lbz	r3, 0x680 (playerdata)
	cmpwi	r3,60
	bge	NoPress
	cmpwi	r3,20
	bge	EarlyPress
	b	Lockout


		EarlyPress:
		#INITALIZE TEXT 1
		mr 	r3,r29			#text pointer
		bl	LateTextASCII
		mflr 	r4			#get ASCII to print
		lfs	f1, -0x37B4 (rtoc)			#default text X/Y
		lfs	f2, -0x37B4 (rtoc)			#default text X/Y
		branchl r12,0x803a6b98


		#INITALIZE TEXT 2
		mr 	r3,r29			#text pointer
		bl	LateTextASCII2
		mflr 	r4			#get ASCII to print

		#Get How Many Frames Early
		lbz	r5, 0x680 (playerdata)

		lfs	f1, -0x37B4 (rtoc)			#default text X/Y
		lfs	f2, -0x37B0 (rtoc)			#shift down on Y axis
		branchl r12,0x803a6b98

		b Moonwalk_Exit


	#######################################################################


		Lockout:
		#INITALIZE TEXT 1
		mr 	r3,r29			#text pointer
		bl	LockoutTextASCII
		mflr 	r4			#get ASCII to print
		lfs	f1, -0x37B4 (rtoc)			#default text X/Y
		lfs	f2, -0x37B4 (rtoc)			#default text X/Y
		branchl r12,0x803a6b98


		#INITALIZE TEXT 2
		mr 	r3,r29			#text pointer
		bl	LockoutTextASCII2
		mflr 	r4			#get ASCII to print

		lbz	r5, 0x680 (playerdata)
		addi	r5,r5,0x1

		lfs	f1, -0x37B4 (rtoc)			#default text X/Y
		lfs	f2, -0x37B0 (rtoc)			#shift down on Y axis
		branchl r12,0x803a6b98

		b Moonwalk_Exit


	#######################################################################


		NoPress:
		#INITALIZE TEXT 1
		mr 	r3,r29			#text pointer
		bl	NoPressASCII
		mflr 	r4			#get ASCII to print
		lfs	f1, -0x37B4 (rtoc)			#default text X/Y
		lfs	f2, -0x37B4 (rtoc)			#default text X/Y
		branchl r12,0x803a6b98


		#INITALIZE TEXT 2
		mr 	r3,r29			#text pointer
		bl	NoPressASCII2
		mflr 	r4			#get ASCII to print
		lfs	f1, -0x37B4 (rtoc)			#default text X/Y
		lfs	f2, -0x37B0 (rtoc)			#shift down on Y axis
		branchl r12,0x803a6b98

		b Moonwalk_Exit



###################
## TEXT CONTENTS ##
###################

LateTextASCII:
blrl
.long 0x4561726c
.long 0x79205072
.long 0x65737300



LateTextASCII2:
blrl
.long 0x4672616d
.long 0x65202564
.long 0x815e3230
.long 0x00000000





LockoutTextASCII:
blrl
.long 0x54656368
.long 0x204c6f63
.long 0x6b6f7574
.long 0x00000000


LockoutTextASCII2:
blrl
.long 0x25646620
.long 0x4561726c
.long 0x79000000



NoPressASCII:
blrl
.long 0x4d697373
.long 0x65642054
.long 0x65636800


NoPressASCII2:
blrl
.long 0x4e6f204c
.long 0x815e5220
.long 0x50726573
.long 0x73000000





##############################

Moonwalk_Exit:
restore
lwz	r0, 0x003C (sp)
