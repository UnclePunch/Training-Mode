#To be inserted at 8000550C
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

lwz	playerdata,0x2c(r4)

	#CHECK IF ENABLED
	li	r0,OSD.GrabBreakout			#PowerShield ID
	lwz	r4,-0x77C0(r13)
	lwz	r4,0x1F24(r4)
	li	r3, 1
	slw	r0, r3, r0
	and.	r0, r0, r4
	beq	Moonwalk_Exit


		bl	CreateText


		#Create TopText
		bl	GrabBreoutText
		mr 	r3,r29			#text pointer
		mflr	r4
		lfs	f1, -0x37B4 (rtoc)			#default text X/Y
		lfs	f2, -0x37B4 (rtoc)			#default text X/Y
		branchl r12,0x803a6b98

		#Create Text2

		#Get Float as String w/ Decimal
		lfs	f1,0x1A4C(playerdata)		 #Remaining Breakout Timer
		lfs	f2,0x2354(playerdata)		 #Total Breakout Timer
		fsubs	f1,f2,f1			#Breakout Remaining
		fctiwz	f1,f1
		stfd	f1,0xF0(sp)
		lwz	r5,0xF4(sp)			#Get as Integer

		#Get Total Breakout Float as Int
		lfs	f1,0x2354(playerdata)		 #Total Breakout Timer
		fctiwz	f1,f1
		stfd	f1,0xF0(sp)
		lwz	r6,0xF4(sp)			#Get as Integer
		#addi	r6,r6,0x1

		#Change Color If You Broke Out
		cmpw	r5,r6
		blt	BottomText
		load	r3,0x8dff6eff			#green
		stw	r3,0x30(text)

		BottomText:
		bl	GrabBreoutText2
		mr 	r3,r29			#text pointer
		mflr	r4
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
	li	r6,12			#Window ID (Unique to This Display)
	branchl	r12,TextCreateFunction			#create text custom function

	mr	text,r3			#backup text pointer

	lwz	r0, 0x000C (sp)
	addi	sp, sp, 8
	mtlr r0
	blr


###################
## TEXT CONTENTS ##
###################

GrabBreoutText:
blrl
.string "Grab Breakout"
.align 2

GrabBreoutText2:
blrl
.string "%d/%d"
.align 2

##############################


Moonwalk_Exit:
restoreall
blr
