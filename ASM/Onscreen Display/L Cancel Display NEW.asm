#To be inserted at 8008d770
.include "../Globals.s"

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

backupall
	lwz	playerdata,0x2c(player)

	#CHECK IF ENABLED
	li	r0,1			#wavedash ID
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

	mr	r3,playerdata			#backup playerdata pointer
	li	r4,60			#display for 60 frames
	li	r5,0			#Area to Display (0-2)
	li	r6,1			#Window ID (Unique to This Display)
	branchl	r12,TextCreateFunction			#create text custom function

	mr	text,r3			#backup text pointer



	#CHANGE TEXT COLOR
	lbz	r5,0x67F(playerdata)			#get decimal to print
	cmpwi	r5,0x7
	blt	SuccessLCancel

	#SET TEXT COLOR TO PINK
	load	r3,0xffa2baff
	stw	r3, 0x0030 (text)
	mr	r3,playerdata
	bl	DecLCRate
	mr	r25,r3
	b	InitializeText
	SuccessLCancel:
	#SET TEXT COLOR TO GREEN
	load	r3,0x8dff6eff
	stw	r3, 0x0030 (text)
	mr	r3,playerdata
	bl	IncLCRate
	mr	r25,r3
	b	InitializeText

	#INITALIZE TEXT 1
	InitializeText:
	mr 	r3,r29			#text pointer
	lbz	r5,0x67F(playerdata)			#get decimal to print
	cmpwi	r5,60
	ble	0xC
	bl	TextASCII3
	b	0x8
	bl	TextASCII
	mflr 	r4			#get ASCII to print
	addi	r5,r5,0x1
	lfs	f1, -0x37B4 (rtoc)			#default text X/Y
	lfs	f2, -0x37B4 (rtoc)			#default text X/Y
	branchl r12,0x803a6b98



	#INITALIZE TEXT 2
	mr 	r3,r29			#text pointer
	bl	TextASCII2
	mflr 	r4			#get ASCII to print
	mr	r5,r25
	lfs	f1, -0x37B4 (rtoc)			#default text X/Y
	lfs	f2, -0x37B0 (rtoc)			#shift down on Y axis
	branchl r12,0x803a6b98

b Moonwalk_Exit

#########################
### LC Rate Functions ###
#########################

IncLCRate:
stwu	r1,-0x100(r1)	# make space for 12 registers
mflr r0
stw r0,0xFC(sp)
lbz	r3,0xC(r3)		#get player slot
load	r4,0x804a1fa8		#get LC rate mem location
mulli	r3,r3,0x4		#length of players DB info
add	r8,r3,r4		#players LC info in r8
lhz	r3,0x0(r8)		#successful LCs
addi	r3,r3,0x1
sth	r3,0x0(r8)		#successful LCs
lhz	r3,0x2(r8)		#total LCs
addi	r3,r3,0x1
sth	r3,0x2(r8)		#total LCs
mr	r3,r8
bl	GetLCRate
lwz r0,0xFC(sp)
mtlr r0
addi	r1,r1,0x100	# release the space
blr

DecLCRate:
stwu	r1,-0x100(r1)	# make space for 12 registers
mflr r0
stw r0,0xFC(sp)
lbz	r3,0xC(r3)		#get player slot
load	r4,0x804a1fa8		#get DB rate mem location
mulli	r3,r3,0x4		#length of players DB info
add	r8,r3,r4		#players DB info in r8
lhz	r3,0x2(r8)		#total DBs
addi	r3,r3,0x1
sth	r3,0x2(r8)		#total DBs
mr	r3,r8
bl	GetLCRate
lwz r0,0xFC(sp)
mtlr r0
addi	r1,r1,0x100	# release the space
blr


GetLCRate:
#Get Values
lhz	r4,0x0(r3)		#successful LCs
lhz	r5,0x2(r3)		#total LCs
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
fdivs	f1,f1,f2		#successful LC / total LC
fmuls	f1,f1,f3		#times 100
#Back to Int
fctiwz	f1,f1
stfd	f1,0xF0(sp)
lwz	r3,0xF4(sp)
blr


TextASCII:
blrl

#Last L/R/Z
.string "Frame %d/7"
.align 2

TextASCII2:
blrl
.string "L-Cancel %d%"
.align 2

TextASCII3:
blrl
.string "No Press"
.align 2

##############################

Moonwalk_Exit:
restoreall

lwz	r0, 0x0034 (sp)
