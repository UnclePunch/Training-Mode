#To be inserted at 8006b678
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
.set framenumber,26

##########################################################
## 804a1f5c -> 804a1fd4 = Static Stock Icon Text Struct ##
## Is 0x80 long and is zero'd at the start              ##
##  of every VS Match				                        ##
## Store Text Info here                                 ##
##########################################################

backup

	mr	player,r30
	lwz	playerdata,0x2C(player)


	#CHECK IF ENABLED
	li	r0,7			#wavedash ID
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

	#Check if Timer Started
	load	r3,0x8046b6a0			#Get Time Passed
	lwz	r3,0x24(r3)
	cmpwi	r3,0x0
	beq	Moonwalk_Exit

	CreateText:
	mr	r3,playerdata			#backup playerdata pointer
	li	r4,1			#display for 1 frames
	li	r5,1			#Area to Display (0-2)
	li	r6,7			#Window ID (Unique to This Display)
	branchl	r12,TextCreateFunction			#create text custom function


	mr	text,r3			#backup text pointer



		InitializeText:
		#INITALIZE TEXT 1
		mr 	r3,r29			#text pointer
		bl	APMText
		mflr 	r4			#get ASCII to print
		lfs	f1, -0x37B4 (rtoc)			#default text X/Y
		lfs	f2, -0x37B4 (rtoc)			#default text X/Y
		branchl r12,0x803a6b98


		#INITALIZE TEXT 2
		mr	r3,playerdata
		bl	GetAPM
		mr	r5,r3

		#Change Color Based on APM
		cmpwi	r5,400
		blt	BelowAverage
		cmpwi	r5,600
		bgt	AboveAverage

		Average:
		load	r3,0xFFFFFFFF			#White
		b	InitalizeText2
		BelowAverage:
		load	r3,0xffa2baff			#Red
		b	InitalizeText2
		AboveAverage:
		load	r3,0x8dff6eff			#Green

		InitalizeText2:
		stw	r3,0x30(text)			#Store Color
		mr 	r3,r29			#text pointer
		bl	Decimal
		mflr 	r4			#get ASCII to print
		lfs	f1, -0x37B4 (rtoc)			#default text X/Y
		lfs	f2, -0x37B0 (rtoc)			#shift down on Y axis
		branchl r12,0x803a6b98

		b Moonwalk_Exit

#############
## Get APM ##
#############
GetAPM:
#Backup Playerdata to r9
mr	r9,r3

#Get Players Actions In r8
lbz	r3,0xC(r9)
load	r4,0x804a1fb8
mulli	r3,r3,0x4
add	r8,r3,r4

#Check for Unique Inputs
lwz	r3,0x668(r9)			#Get Instant Inputs
cmpwi	r3,0x0
beq	CalculateAPM

#Add to Action Count
lwz	r3,0x0(r8)
addi	r3,r3,0x1
stw	r3,0x0(r8)

CalculateAPM:
lwz	r3,0x0(r8)			#Get Total Actions
load	r4,0x8046b6a0			#Get Time Passed
lwz	r4,0x24(r4)
li	r5,3600			#1 Minute In Frames

#Get as Floats
lis	r0, 0x4330
lfd	f5, -0x6758 (rtoc)
xoris	r3, r3, 0x8000
xoris	r4, r4, 0x8000
stw	r0,0xF0(sp)
#Total Actions
stw	r3,0xF4(sp)
lfd	f1,0xF0(sp)
fsubs	f1,f1,f5
#Total Time Passed
stw	r4,0xF4(sp)
lfd	f2,0xF0(sp)
fsubs	f2,f2,f5
#3600f
xoris	r5,r5,0x8000
stw	r5,0xF4(sp)
lfd	f3,0xF0(sp)
fsubs	f3,f3,f5
#Calculate
fdivs	f2,f3,f2			#3600 / Time Passed
fmuls	f1,f1,f2			#Inputs * (3600 / Time Passed)
#Back to Int
fctiwz	f1,f1
stfd	f1,0xF0(sp)
lwz	r3,0xF4(sp)
blr


###################
## TEXT CONTENTS ##
###################

APMText:
blrl
.string "IPM"
.align 2

Decimal:
blrl
.string "%d"
.align 2

##############################


Moonwalk_Exit:
restore
lbz	r0, 0x221D (r31)
