#To be inserted at 8000551c
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
.set FramesSince,28
.set ASBeforeWait,27

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

backup

#Get Player Pointers
	mr	player,r3
	lwz	playerdata,0x2c(player)

	#CHECK IF ENABLED
	li	r0,0x10			#PowerShield ID
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

#Calculate Frames Since Wait and Get AS Before Wait
	li	r5,0		#Loop Count
	li	r4,PrevASStart
WaitSearchLoop:
	mulli	r3,r5,0x2
	add	r3,r3,r4
	lhzx	r3,r3,playerdata
	cmpwi	r3,0xE
	beq	WaitSearchExit
	addi	r5,r5,1
	cmpwi	r5,6
	bge	Moonwalk_Exit
	b	WaitSearchLoop
WaitSearchExit:
#Get AS Before Wait
	addi	r3,r5,1
	mulli	r3,r3,0x2
	add	r3,r3,r4
	lhzx	ASBeforeWait,r3,playerdata
#Get Frames In Wait
	li	r4,0x23FC		#Frame Count Start
	li	FramesSince,0		#Init Frame Count
FrameCountLoop:
	cmpwi	r5,0
	beq	FrameCountLoopFinish
	mulli	r3,r5,0x2
	add	r3,r3,r4
	lhzx	r3,r3,playerdata
	add	FramesSince,r3,FramesSince
	subi	r5,r5,1
	b	FrameCountLoop
FrameCountLoopFinish:
	lhz	r3,0x23FC(playerdata)			#Frames spent in Wait
	add	FramesSince,r3,FramesSince			#Get Total Frames Since




#Check If Under 13 Frames
	cmpwi	FramesSince,13
	bgt	Moonwalk_Exit

#Only Coming from Throws, Aerial Landing, and Teching/Getups
#Aerial Landing
	cmpwi	ASBeforeWait,0x46
	blt	NotThrow
	cmpwi	ASBeforeWait,0x4A
	bgt	NotThrow
	b	ComingFromWhitelist
	NotThrow:
#Throws
	cmpwi	ASBeforeWait,0xDB
	blt	NotAerialLanding
	cmpwi	ASBeforeWait,0xDE
	bgt	NotAerialLanding
	b	ComingFromWhitelist
	NotAerialLanding:
#Teching/Getups
#Aerial Landing
	cmpwi	ASBeforeWait,0xB7
	blt	NotTeching
	cmpwi	ASBeforeWait,0xC9
	bgt	NotTeching
	b	ComingFromWhitelist
	NotTeching:
	b	Moonwalk_Exit
ComingFromWhitelist:

		SpawnText:
		bl	CreateText

		#Change Text Color
		cmpwi	FramesSince,0x1
		bne	RedText
		GreenText:
		load	r3,0x8dff6eff			#green
		b	StoreTextColor
		RedText:
		load	r3,0xffa2baff
		StoreTextColor:
		stw	r3,0x30(text)

		#Create Text


		/*
		cmpwi	r20,0x0
		bne	GetTechText
		GetGetupText:
		bl	GetupText
		b	ResumeTopText
		*/


		GetTechText:
		bl	TechText
		ResumeTopText:
		mr 	r3,r29			#text pointer
		mflr	r4
		lfs	f1, -0x37B4 (rtoc)			#default text X/Y
		lfs	f2, -0x37B4 (rtoc)			#default text X/Y
		branchl r12,0x803a6b98

		#Create Text2
		bl	BottomText
		mr 	r3,r29			#text pointer
		mflr	r4
		mr	r5,FramesSince
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
	li	r6,18			#Window ID (Unique to This Display)
	branchl	r12,TextCreateFunction			#create text custom function

	mr	text,r3			#backup text pointer
  lwz	r0, 0x000C (sp)
	addi	sp, sp, 8
	mtlr r0
	blr


###################
## TEXT CONTENTS ##
###################

TechText:
blrl
.string "Act OoWait"
.align 2

GetupText:
blrl
.string "Act OoGetup"
.align 2

BottomText:
blrl
.string "Frame: %d"
.align 2

##############################


Moonwalk_Exit:
restore
blr
