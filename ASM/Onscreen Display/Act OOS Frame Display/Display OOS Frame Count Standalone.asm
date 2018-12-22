#To be inserted at 80005508
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

.set entity,31
.set playerdata,31
.set player,30
.set text,29
.set textprop,28
.set TextCreateFunction,0x80005928

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

mr	player,r4
lwz	playerdata,0x2C(player)

	#####################
	## CHECK IF IASA'd ##
	#####################

	#CHECK IF ENABLED
	li	r0,3			#wavedash ID
	#lwz	r4,-0xdbc(rtoc)			#get frame data toggle bits
	lwz	r4,-0x77C0(r13)
	lwz	r4,0x1F24(r4)
	li	r5, 1
	slw	r0, r5, r0
	and.	r0, r0, r4
	beq	Moonwalk_Exit

	CheckForIASA:
	cmpwi	r3,0x1
	bne 	Moonwalk_Exit

	CheckForFollower:
	mr	r3,playerdata
	branchl	r12,0x80005510
	cmpwi	r3,0x1
	beq	Moonwalk_Exit

	CheckForGuardOff:
	lwz	r3,0x10(playerdata)
	cmpwi	r3,0xB4
	beq	Moonwalk_Exit

	ShieldWaitCheck:
	#CHECK IF 3RD MOST RECENT AS WAS SHIELD STUN
	lhz	r3,TwoASAgo(playerdata)
	cmpwi	r3,0xB5
	beq	CreateText

	GuardOffCheck:
	#CHECK IF 4TH MOST RECENT AS WAS SHIELD STUN
	lhz	r3,ThreeASAgo(playerdata)
	cmpwi	r3,0xB5
	beq 	CreateText
	b	Moonwalk_Exit

	CreateText:
	mr	r3,playerdata			#backup playerdata pointer
	li	r4,60			#display for 60 frames
	li	r5,0			#Area to Display (0-2)
	li	r6,3			#Window ID (Unique to This Display)
	branchl	r12,TextCreateFunction			#create text custom function


	mr	text,r3			#backup text pointer


	#CHECK IF FRAME PERFECT
	lhz	r3,0x23EE(playerdata)			#get shield stun frames left
	cmpwi	r3,0x0
	bgt	NotFramePerfect

		#SET TEXT COLOR TO GREEN
		load	r3,0x8dff6eff
		stw	r3, 0x0030 (text)


		NotFramePerfect:
		#INITALIZE TEXT 1
		mr 	r3,r29			#text pointer
		bl	DuringSSASCII
		mflr 	r4			#get ASCII to print
		lfs	f1, -0x37B4 (rtoc)			#default text X/Y
		lfs	f2, -0x37B4 (rtoc)			#default text X/Y
		branchl r12,0x803a6b98


		#INITALIZE TEXT 2
		mr 	r3,r29			#text pointer
		bl	DuringSSASCII2
		mflr 	r4			#get ASCII to print

		lhz	r5,0x23EE(playerdata)			#get shield stun frames left
		addi	r5,r5,0x1


		lfs	f1, -0x37B4 (rtoc)			#default text X/Y
		lfs	f2, -0x37B0 (rtoc)			#shift down on Y axis
		branchl r12,0x803a6b98

		b Moonwalk_Exit


###################
## TEXT CONTENTS ##
###################

DuringSSASCII:
blrl
.string "Act OoS"
.align 2

DuringSSASCII2:
blrl
.string "Frame %d"
.align 2

##############################

Moonwalk_Exit:
restore
blr
