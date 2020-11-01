#To be inserted at 8008eca4
.include "../Globals.s"

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

mr	player,r3
lwz	playerdata,0x2c(player)


	#CHECK IF ENABLED
	li	r0,OSD.ShieldPoke			#PowerShield ID
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

	#Check If Shield Was Active
	lbz	r3,0x221B(playerdata)
	rlwinm.	r3,r3,0,24,24
	beq	ADTCheck

	#Check If in a Shield State
	lwz	r3,0x10(playerdata)
	cmpwi	r3,0xB2			#GuardOn (LightShield)
	beq	ShieldPoke
	cmpwi	r3,0xB3			#Guard (Hold)
	beq	ShieldPoke
	cmpwi	r3,0xB6			#GuardReflect
	beq	ShieldPoke


	#Check If Hit During ADT
	ADTCheck:
	lwz	r3,0x10(playerdata)
	cmpwi	r3,0xB6
	bne	Moonwalk_Exit

	HitDuringADT:
		bl	CreateText

		#Change Text Color
		load	r3,0xffa2baff
		stw	r3,0x30(text)

		#Create Text
		bl	ADTText
		mr 	r3,r29			#text pointer
		mflr	r4
		lfs	f1, -0x37B4 (rtoc)			#default text X/Y
		lfs	f2, -0x37B4 (rtoc)			#default text X/Y
		branchl r12,0x803a6b98

		#Create Text
		bl	ADTText2
		mr 	r3,r29			#text pointer
		mflr	r4
		lfs	f1, -0x37B4 (rtoc)			#default text X/Y
		lfs	f2, -0x37B0 (rtoc)			#shift down on Y axis
		branchl r12,0x803a6b98

		b Moonwalk_Exit

	ShieldPoke:
		bl	CreateText

		#Change Text Color
		load	r3,0xffa2baff
		stw	r3,0x30(text)

		#Create Text
		bl	ShieldPokeText
		mr 	r3,r29			#text pointer
		mflr	r4
		lfs	f1, -0x37B4 (rtoc)			#default text X/Y
		lfs	f2, -0x37B4 (rtoc)			#default text X/Y
		branchl r12,0x803a6b98

		#Create Text
		bl	ShieldPokeText2
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
	li	r6,10			#Window ID (Unique to This Display)
	branchl	r12,TextCreateFunction			#create text custom function
	mr	text,r3			#backup text pointer
	lwz	r0, 0x000C (sp)
	addi	sp, sp, 8
	mtlr r0
	blr


###################
## TEXT CONTENTS ##
###################

ShieldPokeText:
blrl
.string "Hit By"
.align 2

ShieldPokeText2:
blrl
.string "Shield Poke"
.align 2

ADTText:
blrl
.string "Hit During"
.align 2

ADTText2:
blrl
.string "ADT"
.align 2

##############################


Moonwalk_Exit:
restoreall
mr	r31, r3
