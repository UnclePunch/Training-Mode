#To be inserted at 80005518
.include "../../Globals.s"

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
lwz	playerdata,0x2C(player)
mr	r20,r4				#Dashback Bool

	#CHECK IF ENABLED
	li	r0,OSD.Dashback			#wavedash ID
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

	#Check If Player is a Follower Subchar
	lbz	r3, 0x221F (playerdata)
	#Check If Subchar
	rlwinm.	r0, r3, 29, 31, 31
	beq	CreateText
	#Check If Follower
	lbz	r3,0xC(playerdata)			#get slot
	branchl	r12,0x80032330			#get external character ID
	load	r4,0x803bcde0			#pdLoadCommonData table
	mulli	r0, r3, 3			#struct length
	add	r3,r4,r0			#get characters entry
	lbz	r0, 0x2 (r3)			#get subchar functionality
	cmpwi	r0,0x0			#if not a follower, exit
	beq	Moonwalk_Exit

	CreateText:
	mr	r3,playerdata			#backup playerdata pointer
	li	r4,60			#display for 60 frames
	li	r5,0			#Area to Display (0-2)
	li	r6,5			#Window ID (Unique to This Display)
	branchl	r12,TextCreateFunction			#create text custom function



	mr	text,r3			#backup text pointer


	#Check If Failed Or Succeeded
	cmpwi	r20,0x1
	beq	SucceededDB

		FailedDB:
		load	r3,0xffa2baff
		stw	r3,0x30(text)

		bl	FailedText
		mr 	r3,r29			#text pointer
		mflr	r4
		lfs	f1, -0x37B4 (rtoc)			#default text X/Y
		lfs	f2, -0x37B4 (rtoc)			#default text X/Y
		branchl r12,0x803a6b98


		#Percetange Text
		#Update + Get DB Rate in r5
		mr	r3,playerdata
		bl	DecDBRate
		mr	r5,r3

		bl	FailedTextPercent
		mflr	r4
		mr	r3,text
		lfs	f1, -0x37B4 (rtoc)			#default text X/Y
		lfs	f2, -0x37B0 (rtoc)			#shift down on Y axis
		branchl r12,0x803a6b98
		b	Moonwalk_Exit


		SucceededDB:

		#Change Color
		load	r3,0x8dff6eff
		stw	r3,0x30(text)
		bl	SuccessText
		mr 	r3,r29			#text pointer
		mflr	r4
		lfs	f1, -0x37B4 (rtoc)			#default text X/Y
		lfs	f2, -0x37B4 (rtoc)			#default text X/Y
		branchl r12,0x803a6b98



		#Initialize Bottom Text

		#Update + Get DB Rate in r5
		mr	r3,playerdata
		bl	IncDBRate
		mr	r5,r3

		#Check If UCF DB or Vanilla DB
			lwz	r3,0x2350(playerdata)		 #get turn flag
			cmpwi	r3,0x0			#if 0, was a smash turn
			bne	UCFDB

		VanillaDB:
			#Get Text
			bl	VanillaDBText
			mflr	r4
			load	r20,0xFFFFFFFF		#Color to store
			b	InitalizeBottomText

		UCFDB:
			#Get Text
			bl	UCFDBText
			mflr	r4
			load	r20,0xFFFF33FF		#Color to store
			b	InitalizeBottomText

		InitalizeBottomText:

		#Change Text Color
		stw	r20,0x30(text)

		#Init Function Call
		mr 	r3,r29			#text pointer
		lfs	f1, -0x37B4 (rtoc)			#default text X/Y
		lfs	f2, -0x37B0 (rtoc)			#shift down on Y axis
		branchl r12,0x803a6b98

		b Moonwalk_Exit


#########################
### DB Rate Functions ###
#########################

IncDBRate:
stwu	r1,-0x100(r1)	# make space for 12 registers
mflr r0
stw r0,0xFC(sp)
lbz	r3,0xC(r3)		#get player slot
load	r4,0x804a1fc8		#get DB rate mem location
mulli	r3,r3,0x4		#length of players DB info
add	r8,r3,r4		#players DB info in r8
lhz	r3,0x0(r8)		#successful DBs
addi	r3,r3,0x1
sth	r3,0x0(r8)		#successful DBs
lhz	r3,0x2(r8)		#total DBs
addi	r3,r3,0x1
sth	r3,0x2(r8)		#total DBs
mr	r3,r8
bl	GetDBRate
lwz r0,0xFC(sp)
mtlr r0
addi	r1,r1,0x100	# release the space
blr

DecDBRate:
stwu	r1,-0x100(r1)	# make space for 12 registers
mflr r0
stw r0,0xFC(sp)
lbz	r3,0xC(r3)		#get player slot
load	r4,0x804a1fc8		#get DB rate mem location
mulli	r3,r3,0x4		#length of players DB info
add	r8,r3,r4		#players DB info in r8
lhz	r3,0x2(r8)		#total DBs
addi	r3,r3,0x1
sth	r3,0x2(r8)		#total DBs
mr	r3,r8
bl	GetDBRate
lwz r0,0xFC(sp)
mtlr r0
addi	r1,r1,0x100	# release the space
blr


GetDBRate:
#Get Values
lhz	r4,0x0(r3)		#successful DBs
lhz	r5,0x2(r3)		#total DBs
#Get as Floats (f1 = successful, f2 = total
lis	r0, 0x4330
lfd	f5, -0x6758 (rtoc)
xoris	r6, r4, 0x8000
xoris	r7, r5, 0x8000
stw	r0,0xF0(sp)
#Successful DB
stw	r6,0xF4(sp)
lfd	f1,0xF0(sp)
fsubs	f1,f1,f5
#Total DB
stw	r7,0xF4(sp)
lfd	f2,0xF0(sp)
fsubs	f2,f2,f5
#100f
li	r4,100
xoris	r4,r4,0x8000
stw	r4,0xF4(sp)
lfd	f3,0xF0(sp)
fsubs	f3,f3,f5
fdivs	f1,f1,f2		#successful DB / total DB
fmuls	f1,f1,f3		#times 100
#Back to Int
fctiwz	f1,f1
stfd	f1,0xF0(sp)
lwz	r3,0xF4(sp)
blr


###################
## TEXT CONTENTS ##
###################

SuccessText:
blrl
.string "Successful DB"
.align 2

FailedText:
blrl
.string "Failed DB"
.align 2

VanillaDBText:
blrl
.string "Vanilla - %d%"
.align 2

UCFDBText:
blrl
.string "UCF - %d%"
.align 2

FailedTextPercent:
blrl
.string "Failed - %d%"
.align 2

##############################


Moonwalk_Exit:
restoreall
blr
