#To be inserted at 80005514
.include "../../../Globals.s"

.set entity,31
.set playerdata,31
.set player,30
.set text,29
.set textprop,28
.set hitbool,27

.set PrevASStart,0x23F0
.set CurrentAS,0x10
.set OneASAgo,PrevASStart+0x0
.set TwoASAgo,PrevASStart+0x2
.set ThreeASAgo,PrevASStart+0x4
.set FourASAgo,PrevASStart+0x6
.set FiveASAgo,PrevASStart+0x8
.set SixASAgo,PrevASStart+0xA


##########################################################
## 804a1f5c -> 804a1fd4 = Static Stock Icon Text Struct ##
## Is 0x80 long and is zero'd at the start              ##
##  of every VS Match				                        ##
## Store Text Info here                                 ##
##########################################################

backupall

mr	player,r3
lwz	playerdata,0x2c(player)


	#CHECK IF ENABLED
	li	r0,OSD.Ledge			#PowerShield ID
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

	#Check if Over 20 Frames past GALINT
		lwz	r3,0x2408(playerdata)
		cmpwi r3,20
		bgt Moonwalk_Exit

		bl	CreateText

		#Change Text Color
		lwz	r3, 0x1990 (playerdata)
		cmpwi	r3,0x0
		beq	RedText

		GreenText:
		load	r3,0x8dff6eff			#green
		b	StoreTextColor

		RedText:
		load	r3,0xffa2baff

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
		lwz	r5, 0x1990 (playerdata)
		cmpwi	r5,0x0
		bgt	SkipShowingTangibleFrames

		#Show Tangible Frames
		lwz	r5,0x2408(playerdata)
		addi	r5,r5,0x1
		neg	r5,r5

		SkipShowingTangibleFrames:
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
	li	r6,14			#Window ID (Unique to This Display)
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
.string "Ledgedash GALINT"
.align 2

BottomText:
blrl
.string "Frames: %d"
.align 2

##############################


Moonwalk_Exit:
restoreall
blr
