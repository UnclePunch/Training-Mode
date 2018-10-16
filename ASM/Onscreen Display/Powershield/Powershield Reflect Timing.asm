#To be inserted at 800776a0
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
stwu	r1,-0x100(r1)	# make space for 12 registers
stmw	r3,8(r1)	# push r20-r31 onto the stack
mflr r0
stw r0,0xFC(sp)
.endm

.macro restore
lwz r0,0xFC(sp)
mtlr r0
lmw	r3,8(r1)	# pop r20-r31 off the stack
addi	r1,r1,0x100	# release the space
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
.set projectile,30
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

	mr	playerdata,r5

	#CHECK IF ENABLED
	li	r0,9			#PowerShield ID
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

	#Check For PS Intent
	lwz	r3,0x10(playerdata)
	cmpwi	r3,0xB2			#All
	beq	LightShielding
	cmpwi	r3,0x155			#Yoshi
	beq	LightShielding
	cmpwi	r3,0xB6			#All
	beq	LatePS
	cmpwi	r3,0x159			#Yoshi
	beq	LatePS
	b	Moonwalk_Exit

	LatePS:
	CreateText:
	mr	r3,playerdata			#backup playerdata pointer
	li	r4,60			#display for 60 frames
	li	r5,0			#Area to Display (0-2)
	li	r6,9			#Window ID (Unique to This Display)
	branchl	r12,TextCreateFunction			#create text custom function

	mr	text,r3			#backup text pointer

	TopLine:
	bl	PowerShieldText
	mr 	r3,r29			#text pointer
	mflr	r4
	lfs	f1, -0x37B4 (rtoc)			#default text X/Y
	lfs	f2, -0x37B4 (rtoc)			#default text X/Y
	branchl r12,0x803a6b98

	BottomLine:
	#Check If Reflect Bubble is Active (Missed Powershield)
	lbz	r3,0x2218(playerdata)
	rlwinm.	r3,r3,0,27,27
	beq	NoReflect

	MissedReflect:
	lfs	f1,0x2340(playerdata)
	fctiwz	f1,f1
	stfd	f1,0xF0(sp)
	lwz	r5,0xF4(sp)
	addi	r5,r5,0x1
	bl	LateText
	b	BottomTextCont

	NoReflect:
	load	r3,0xffa2baff
	stw	r3,0x30(text)
	lfs	f1,0x2340(playerdata)
	fctiwz	f1,f1
	stfd	f1,0xF0(sp)
	lwz	r5,0xF4(sp)
	subi	r5,r5,0x1
	bl	ReflectEndedText
	
	BottomTextCont:
	mflr	r4
	mr	r3,text
	lfs	f1, -0x37B4 (rtoc)			#default text X/Y
	lfs	f2, -0x37B0 (rtoc)			#shift down on Y axis
	branchl r12,0x803a6b98
	b	Moonwalk_Exit





	LightShielding:
	#Create Text
	mr	r3,playerdata			#backup playerdata pointer
	li	r4,60			#display for 60 frames
	li	r5,0			#Area to Display (0-2)
	li	r6,9			#Window ID (Unique to This Display)
	branchl	r12,TextCreateFunction			#create text custom function
	mr	text,r3			#backup text pointer

	bl	PowerShieldText
	mr 	r3,r29			#text pointer
	mflr	r4
	lfs	f1, -0x37B4 (rtoc)			#default text X/Y
	lfs	f2, -0x37B4 (rtoc)			#default text X/Y
	branchl r12,0x803a6b98

	bl	NoHardPress
	mflr	r4
	mr	r3,text
	lfs	f1, -0x37B4 (rtoc)			#default text X/Y
	lfs	f2, -0x37B0 (rtoc)			#shift down on Y axis
	branchl r12,0x803a6b98
	b	Moonwalk_Exit


###################
## TEXT CONTENTS ##
###################

PowerShieldText:
blrl
.long 0x4d697373
.long 0x65642050
.long 0x53000000

LateText:
blrl
.long 0x25646620
.long 0x4561726c
.long 0x79000000

ReflectEndedText:
blrl
.long 0x5265666c
.long 0x65637420
.long 0x456e6465
.long 0x64202564
.long 0x66000000


NoHardPress:
blrl
.long 0x4e6f2048
.long 0x61726420
.long 0x50726573
.long 0x73000000

##############################


Moonwalk_Exit:
restore
mr	r28, r4




