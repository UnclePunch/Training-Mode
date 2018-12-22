#To be inserted at 80093368
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

##########################################################
## 804a1f5c -> 804a1fd4 = Static Stock Icon Text Struct ##
## Is 0x80 long and is zero'd at the start              ##
##  of every VS Match				                        ##
## Store Text Info here                                 ##
##########################################################

backup

	mr	player,r3
	lwz	playerdata,0x2c(player)


	#CHECK IF ENABLED
	li	r0,13			#wavedash ID
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

	#####################################
	## CHECK IF SHIELD STUN IS OVER    ##
	#####################################
	CheckAndSubStun:
	#CHECK IF IN SHIELD STUN STILL
	lwz	r3,0x23FC(playerdata)			#get shield stun frames left
	cmpwi	r3,0x0
	bgt	DecStunCount
	b	Moonwalk_Exit

	DecStunCount:
	#SUBTRACT FROM SHIELD STUN COUNT
	subi	r3,r3,0x1
	stw	r3,0x23FC(playerdata)			#store shield stun frames left

	CreateText:
	mr	r3,playerdata			#backup playerdata pointer
	li	r4,60			#display for 60 frames
	li	r5,1			#Area to Display (0-2)
	li	r6,17			#Window ID (Unique to This Display)
	branchl	r12,TextCreateFunction			#create text custom function

	mr	text,r3			#backup text pointer


	#CHECK IF IN SHIELD STUN STILL (MAKE TEXT GREEN) WHEN IASA AVAILABLE
	lwz	r3,0x23FC(playerdata)			#get shield stun frames left
	cmpwi	r3,0x0
	bgt	DuringShieldStun

		#SET TEXT COLOR TO GREEN
		load	r3,0x00FF000E
		stw	r3, 0x0030 (text)


		DuringShieldStun:
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

		lwz	r5,0x23FC(playerdata)			#get shield stun frames left

		lfs	f1, -0x37B4 (rtoc)			#default text X/Y
		lfs	f2, -0x37B0 (rtoc)			#shift down on Y axis
		branchl r12,0x803a6b98

		b Moonwalk_Exit


	#######################################################################


		ShieldStunOver:
		#INITALIZE TEXT 1
		mr 	r3,r29			#text pointer
		bl	SSOverASCII
		mflr 	r4			#get ASCII to print
		lfs	f1, -0x37B4 (rtoc)			#default text X/Y
		lfs	f2, -0x37B4 (rtoc)			#default text X/Y
		branchl r12,0x803a6b98


		#INITALIZE TEXT 2
		mr 	r3,r29			#text pointer
		bl	SSOverASCII2
		mflr 	r4			#get ASCII to print

		lbz	r5, 0x680 (playerdata)
		#lbz	r5, 0x0684 (r31)

		lfs	f1, -0x37B4 (rtoc)			#default text X/Y
		lfs	f2, -0x37B0 (rtoc)			#shift down on Y axis
		branchl r12,0x803a6b98

		b Moonwalk_Exit

###################
## TEXT CONTENTS ##
###################

DuringSSASCII:
blrl
.string "Shield Stun"
.align 2

DuringSSASCII2:
blrl
.string "Left: %df"
.align 2

SSOverASCII:
blrl
.string "Shield Stun"
.align 2

SSOverASCII2:
blrl
.string "Left: %df"
.align 2

##############################

Moonwalk_Exit:
restore
mr	r3,player
mr	r30, r3
