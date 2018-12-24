#To be inserted at 8006c5d4
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
		addi r5,r5,1								#add 1 so earliest value is 21/20 and not 20/20

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
.string "Early Press"
.align 2

LateTextASCII2:
blrl
.string "Frame %d/20"
.align 2

LockoutTextASCII:
blrl
.string "Tech Lockout"
.align 2

LockoutTextASCII2:
blrl
.string "%df Early"
.align 2
NoPressASCII:
blrl
.string "Missed Tech"
.align 2
NoPressASCII2:
blrl
.string "No L/R Press"
.align 2

##############################

Moonwalk_Exit:
restoreall
lwz	r0, 0x003C (sp)
