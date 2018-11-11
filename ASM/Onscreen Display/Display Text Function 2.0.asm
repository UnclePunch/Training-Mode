#To be inserted at 80005928
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
stmw  r20,0x8(r1)
.endm

.macro restore
lmw  r20,0x8(r1)
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
.set texttimer,27
.set windowID,26
.set overlayID,25

##########################################################
## 804a1f5c -> 804a1fd4 = Static Stock Icon Text Struct ##
## Is 0x80 long and is zero'd at the start              ##
##  of every VS Match				                        ##
## Store Text Info here                                 ##
##########################################################

#Window ID1 = Above Percent.

  #Window ID Struct:
    #0x0 =

backup

	mr	playerdata,r3
	mr	texttimer,r4
	mr	windowID,r5			#custom window struct in the stock text match struct
	mr	overlayID,r6
	mr	textprop,r7

	#Check Window ID (Location onscreen)


	#REMOVE CURRENT TASK
	lwz 	r3,0x14(windowID)			#get pointer to task
	cmpwi 	r3,0			#check if it exists
	beq 	Moonwalk_AllocateTask			#if it doesnt exist, make new task

	Moonwalk_UnAllocateTask:
	branchl r12,0x80390228				#remove old one

	Moonwalk_AllocateTask:
	#ALLOCATE HEAP SPACE FOR TASK
	li	r3,0xE
	li	r4,0x7
	li	r5,0x0
	branchl r12,0x803901f0

	#STORE TEXT INFO TABLE TO UPDATE TASK'S STRUCT
	#load	r30,0x804a1f5c
	stw	windowID,0x10(r3)			#store pointer to give to task

	#STORE TASK STRUCT POINTER TO INDEX
	stw 	r3,0x14(windowID)			#store pointer to task

	#GET TASK FUNCTION ADDRESS
	bl UpdateText
	mflr 	r4			#get address

	#SCHEDULE TASK
	li 	r5,0x0
	branchl r12,0x8038fd54

	#REMOVE OLD TEXT IF IT STILL EXISTS
	lbz	r4,0xC(playerdata)
	mulli	r4,r4,0x4
	add	r4,r4,windowID
	lwz	r3,0x0(r4)
	cmpwi	r3,0x0
	beq	CreateText

	#REMOVE OLD TEXT
	branchl r12,0x803a5cc4

	CreateText:
	#CREATE TEXT ABOVE PLAYERS HUD ELEMENT
	li 	r3,0x2
	load 	r4,0x804a1f58			#get text objects ID?
	lwz 	r4,0x0(r4)
	branchl r12,0x803a6754

	#STORE PLAYERS TEXT POINTER
	mr	r29,r3			#backup text pointer
	lbz	r4,0xC(playerdata)
	mulli	r4,r4,0x4
	stwx	r3,r4,windowID

	#STORE PLAYERS TEXT TIMEOUT
	lbz	r4,0xC(playerdata)
	addi	r5,windowID,0x10
	stbx	texttimer,r4,r5

	#SET TEXT TO CENTER AROUND X LOCATION AND BE CLOSE
	li	r3,0x1
	stb 	r3,0x4A(r29)
	stb 	r3,0x49(r29)


	#SET X AND Y VALUES

	#Check To Override HUD Location
	lwz	r3,0x0(textprop)			#base X value
	cmpwi	r3,0x0
	bne	GetHUDLocation
	lfs	f1,0x8(textprop)			#base X value
	b	GetYLocation

	#Get HUD Location
	GetHUDLocation:
	lbz	r3,0xC(playerdata)
	load	r4,0x804a0ff0
	mulli	r3,r3,0xC			#HUD Info is 0xC Long Per Player
	lfsx	f1,r3,r4			#Get This Players HUD Info
/*
	#convert player number into float (f3)
	lbz	 r5,0xC(playerdata)
	xoris    r5,r5,0x8000
	lis   	 r6,0x4330
	stw   	 r6,0xF0(sp)
	stw   	 r5,0xF4(sp)
	lfd   	 f1,0xF0(sp)
	lfd	 f2,-0x7470(rtoc)    			#load magic number
	fsubs    f3,f1,f2
	lfs	 f1,0x0(textprop)			#base X value
	lfs	 f2,0x8(textprop)			#X difference
	fmuls	 f2,f2,f3
	fadds 	 f1,f1,f2			#player's X value
*/

	GetYLocation:
	lfs 	 f2,0x4(textprop)			#players Y value
	stfs	f1,0x0(text)			#store X value to struct
	stfs	f2,0x4(text)			#store Y value to struct


	#SET TEXT SIZE
	lfs	f1,0xC(textprop)
	stfs	f1,0x24(text)			#X stretch
	stfs	f1,0x28(text)			#Y stretch


	#INIT BACKGROUND (HYPHEN)
	mr 	r3,r29			#text pointer
	bl	TextASCII3
	mflr 	r4			#get ASCII to print
	lfs	f1, -0x37B4 (rtoc)			#default text X/Y
	lfs	f2,  0x10   (textprop)		#background Y
	branchl r12,0x803a6b98

		#CHANGE TEXT COLOR TO BLACK
		mr	r3,text
		li	r4,0x0
		li	r5,0x0
		stw	r5,0xF0(sp)
		addi	r5,sp,0xF0
		branchl r12,0x803a74f0

		#CHANGE TEXT SIZE
		mr	r3,text
		li	r4,0x0
		lfs	f1, 0x14 (textprop)			#stretch X (12)
		lfs	f2, 0x18 (textprop)			#stretch Y (30)
		branchl r12,0x803a7548



b Moonwalk_Exit

###############################
## UPDATE TEXT TASK FUNCTION ##
###############################

UpdateText:
blrl

backup

mr	r31,r3

#INIT LOOP
li 	r29,0x0
lwz	r30,0x10(r3)		#text pointers

UpdateTextLoop:
mulli 	r4,r29,0x4
add	r4,r4,r30
lwz 	r3,0x0(r4)		#get text pointer
cmpwi r3,0x0
beq IncrementUpdateTextLoop

CheckTimer:
addi	r3,r30,0x10		#timer bytes
lbzx	r3,r29,r3		#get timer
cmpwi	r3,0x1
bgt	DecrementTextTimer

RemovePlayersText:
lwz 	r3,0x0(r4)		#get text pointer
branchl r12,0x803a5cc4
li	r3,0x0
mulli 	r4,r29,0x4
add	r4,r4,r30
stw 	r3,0x0(r4)		#zero text pointer
addi	r4,r30,0x10		#timer bytes
stbx	r3,r29,r4
b 	IncrementUpdateTextLoop

DecrementTextTimer:
addi	r4,r30,0x10		#timer bytes
subi	r3,r3,0x1
stbx	r3,r29,r4

IncrementUpdateTextLoop:
addi r29,r29,0x1
cmpwi r29,0x4
beq ExitUpdateTextLoop
b UpdateTextLoop

ExitUpdateTextLoop:
restore
blr

##############################

OSDStructSizes:
blrl
.long 0x000
.long 0x100
.long 0x200

##############################

TextASCII3:
blrl
.long 0x815B0000



Moonwalk_Exit:
mr	r3,text		#return text pointer
restore
blr
