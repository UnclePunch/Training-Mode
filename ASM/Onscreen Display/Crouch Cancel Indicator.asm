#To be inserted at 8008d978
.include "D:/Users/Vin/Documents/GitHub/Training-Mode/ASM/Globals.s"

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
stfs	f31,0x80(sp)

lfs	f31, 0x1850 (r31)			#Original KB Value
stfs	f0,  0x1850 (r31)			#Store New Value


	#CHECK IF ENABLED
	li	r0,0x11			#PowerShield ID
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

		bl	CreateText

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

		fctiwz	f1,f31			#Original KB Value
		stfd	f1,0xF0(sp)
		lwz	r5,0xF4(sp)
		lfs	f1, 0x1850(playerdata) #New KB Value
		fctiwz	f1,f1
		stfd	f1,0xF0(sp)
		lwz	r6,0xF4(sp)

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
	li	r6,20			#Window ID (Unique to This Display)
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
.string "Crouch Cancel"
.align 2

BottomText:
blrl
.string "%d -> %d KB"
.align 2

##############################


Moonwalk_Exit:
#Store Crouch Cancel Flag


lfs	f31,0x80(sp)
restoreall
lwz	r0, 0x001C (sp)
