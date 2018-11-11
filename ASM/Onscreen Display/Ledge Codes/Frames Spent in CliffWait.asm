#To be inserted at 8009ab78
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
.set hitbool,27

##########################################################
## 804a1f5c -> 804a1fd4 = Static Stock Icon Text Struct ##
## Is 0x80 long and is zero'd at the start              ##
##  of every VS Match				                        ##
## Store Text Info here                                 ##
##########################################################

stw	r0, 0x2064 (r6)

backup

mr	playerdata,r6


	#CHECK IF ENABLED
	li	r0,0x1A			#PowerShield ID
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

		#Change Text Color
		lfs	f1,0x894(playerdata)
		fctiwz	f1,f1
		stfd	f1,0xF0(sp)
		lwz	r3,0xF4(sp)
		cmpwi	r3,0x1
		bne	RedText

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
		lfs	f1,0x894(playerdata)
		fctiwz	f1,f1
		stfd	f1,0xF0(sp)
		lwz	r5,0xF4(sp)
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

	#Display Up Top For Event
	load	r5,0x80479d30
	lbz	r5,0x0(r5)
	cmpwi	r5,0x2B
	bne	0xC
	li	r5,1
	b	0x8
	li	r5,0			#Area to Display (0-2)
	li	r6,13			#Window ID (Unique to This Display)
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
.long 0x4672616d
.long 0x65732069
.long 0x6e000000



BottomText:
blrl
.long 0x436c6966
.long 0x66576169
.long 0x743a2025
.long 0x64000000




##############################


Moonwalk_Exit:
restore
