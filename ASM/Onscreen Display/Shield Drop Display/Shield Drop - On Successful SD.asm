#To be inserted at 8009a10c
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
.set playerdata,30
.set player,31
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

lwz	playerdata,0x2C(player)


	#CHECK IF ENABLED
	li	r0,6			#ID
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
	li	r6,6			#Window ID (Unique to This Display)
	branchl	r12,TextCreateFunction			#create text custom function


	mr	text,r3			#backup text pointer


	#Determine If UCF or Vanilla SD
	lwz	r5, -0x514C (r13)			#PlCo Pointer
	lfs	f0, 0x0314 (r5)			#-0.7 (Shield Drop Vanilla
	lfs	f1, 0x0624 (playerdata)	#Get Y Coord
	fcmpo	cr0,f1,f0			#Check if Y Coord is Greater than -0.7
	bgt	VanillaSD

	UCFCheck2:
	lbz	r3, 0x0671 (playerdata)	#Frames Since Left Origin
	lwz	r4, 0x0318 (r5)			#Max Frames Since Left Origin (PlCo)
	cmpw	r3,r4			#If less than 4, its a UCF SD
	bge	VanillaSD

	UCFSD:
	#Change Color
	load	r3,0xFFFF33FF
	stw	r3,0x30(text)
	b	InitalizeTopText

	VanillaSD:
	#Change Color
	load	r3,0x8dff6eff
	stw	r3,0x30(text)

		InitalizeTopText:
		mr 	r3,r29			#text pointer
		bl	StickMovedText
		mflr	r4
		lbz	r5, 0x0671 (playerdata)	#Get Stick Moved Time
		addi	r5,r5,0x1
		lfs	f1, -0x37B4 (rtoc)			#default text X/Y
		lfs	f2, -0x37B4 (rtoc)			#default text X/Y
		branchl r12,0x803a6b98



		#Initialize Bottom Text
		InitalizeBottomText:
		#Init Function Call
		mr 	r3,r29			#text pointer
		bl	YCoord
		mflr	r4
		lfs	f1, -0x37B4 (rtoc)			#default text X/Y
		lfs	f2, -0x37B0 (rtoc)			#shift down on Y axis
		lfs	f3, 0x0624 (playerdata)	#Get Y Coord
		crset	6			#Output Float
		branchl r12,0x803a6b98

		b Moonwalk_Exit






###################
## TEXT CONTENTS ##
###################

StickMovedText:
blrl
.long 0x4672616d
.long 0x65202564
.long 0x815e3500


YCoord:
blrl
.long 0x59203d20
.long 0x25660000



##############################


Moonwalk_Exit:
restore
mr	r3,r31
