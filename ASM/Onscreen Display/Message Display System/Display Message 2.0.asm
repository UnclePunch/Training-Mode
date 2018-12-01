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
.set messageStruct,30
.set text,29
.set textprop,28
.set texttimer,27
.set AreaID,26
.set overlayID,25
.set MaxWindows,24

.set messageAreaStructLength,0x100
.set messageStructLength,0x28

##########################################################
## 804a1f5c -> 804a1fd4 = Static Stock Icon Text Struct ##
## Is 0x80 long and is zero'd at the start              ##
##  of every VS Match				                    ##
## Store Text Info here                                 ##
##########################################################

#Message Area Struct Layout
##0x00 = P1 Area
##0x28 = P2 Area
##0x50 = P3 Area
##0x78 = P4 Area

	#PX Area
		#0x0 = 32-bit int, number of active windows in this area
		#0x4 = Start Individual Message Struct
			#0x0 = Text Pointer
			#0x4 = Countdown Until Expiration
			#0x6 = Unique Message ID (which text prompt this is)


backup

	mr	playerdata,r3
	mr	texttimer,r4
	mr	AreaID,r5			#custom window struct in the stock text match struct
	mr	overlayID,r6
	mr	textprop,r7

	#Load Max Number of Windows Variable From OSD Menu
  	lwz	r3,-0x77C0(r13)			#Get Memcard Data
	  lbz	MaxWindows,0x1f28(r3)

	#Get Window's Area in the Message Struct in r3
	  load	r3,0x804a1f58
	  lwz	r3,0x4(r3)
	  mulli	r4,AreaID,messageAreaStructLength
	  add	r3,r3,r4

	#Check If Area 3 (No Shift or anything Special)
	 cmpwi	AreaID,0x2
	 blt	GetPlayersArea
	 mr	messageStruct,r3

	#Remove Old Area 3 Window
	 lwz	r3,0x0(messageStruct)
	 branchl	r12,0x803a5cc4
	 b	CreateText

	GetPlayersArea:
	#Get to the player's area
	  lbz	r4,0xC(playerdata)
	  mulli	r4,r4,messageStructLength
	  add	messageStruct,r3,r4

	#Search Queue For This Text ID (Loop)
	  mr	r3,overlayID
	  mr	r4,MaxWindows
	  mr	r5,messageStruct
	  bl	CheckForDuplicates

	#Shift Queue To Make Room For New Message
	CallShiftFunction:
	  mr	r3,MaxWindows
	  bl	ShiftQueue

	CreateText:
	#CREATE TEXT ABOVE PLAYERS HUD ELEMENT
 	 li 	r3,0x2
	 load 	r4,0x804a1f58			#get text objects ID?
	 lwz 	r4,0x0(r4)
	 branchl r12,0x803a6754

	#STORE PLAYERS TEXT POINTER
	 mr	r29,r3					#backup text pointer
	 stw	r3,0x0(messageStruct)

	#STORE PLAYERS TEXT TIMEOUT
	 sth	texttimer,0x4(messageStruct)

	#STORE OVERLAY ID
	sth	overlayID,0x6(messageStruct)

	#SET TEXT TO CENTER AROUND X LOCATION AND BE CLOSE
	li	r3,0x1
	stb 	r3,0x4A(r29)
	stb 	r3,0x49(r29)

	#SET X AND Y VALUES
	#Get Area's Text Properties
	bl	TextProperties
	mflr	textprop
	mulli	r3,AreaID,0x1C
	add	textprop,textprop,r3

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

	GetYLocation:
	lfs 	 f2,0x4(textprop)			#players Y value
	stfs	f1,0x0(text)			#store X value to struct
	stfs	f2,0x4(text)			#store Y value to struct


	#SET TEXT SIZE
	lfs		f1,0xC(textprop)
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

#######################################################################

####################
## Shift Messages ##
####################

ShiftQueue:

 backup

 mr	r31,r3		#Max Windows

#Remove Last Message if Exists
 mulli	r3,r31,0x8
 lwzx	r3,r3,messageStruct
 cmpwi	r3,0x0
 beq	ShiftQueue_CheckForOneWindowOnly

#Remove Message
 branchl	r12,0x803a5cc4

#Zero Out Entry
 mulli	r4,r31,0x8
 add	r4,r4,messageStruct
 li	r3,0
 stw	r3,0x0(r4)
 stw	r3,0x4(r4)

ShiftQueue_CheckForOneWindowOnly:

#Check If Only 1 Message
 cmpwi	r31,0
 beq	ShiftQueue_Exit

ShiftQueue_Loop:

#Shift This Message Upwards in the Queue
 mulli	r3,r31,0x8
 add	r3,r3,messageStruct		#Get to the nth Message
 lwz	r4,0x0(r3)				#Load Text Pointer into r4
 lwz	r5,0x4(r3)				#Load Timer and ID into r5
 stw	r4,0x8(r3)				#Push up
 stw	r5,0xC(r3)				#Push up
 li	r4,0x0
 stw	r4,0x0(r3)				#Zero Out
 stw	r4,0x4(r3)	 			#Zero Out

#Move This Message Upwards Onscreen
 lwz	r4,0x8(r3)				#Text Pointer
 cmpwi	r4,0x0
 beq	ShiftQueue_IncLoop

#Move Message Downwards/Upwards Depending On The Area
 bl	ShiftQueue_Floats
 mflr	r3
 mulli	r5,AreaID,0x4				#Area ID into offset
 lfsx	f1,r3,r5
 lfs	f2,0x4(r4)				#Get Text's Y Value
 fadds	f1,f1,f2
 stfs	f1,0x4(r4)				#Store Text's Y Value

#Next Message
ShiftQueue_IncLoop:
 subi	r31,r31,0x1
 cmpwi	r31,0x0
 bge	ShiftQueue_Loop

ShiftQueue_Exit:
 restore
 blr


################################################


#####################
## Check For Dupes ##
#####################

#Inputs:
#r3 = OverlayID
#r4 = Max Window Count
#r5 = Message Queue Start

CheckForDuplicates:

backup

mr	r31,r3
mr	r30,r4
mr	r29,r5

#Search Loop For Matching Window
#Init Loop
 li	r28,0x0		#Matching Window Loop Count

CheckForDuplicates_MatchingWindowLoop:
 mulli	r5,r28,0x8			#Get Message's Offset
 add	r4,r5,r29			#Get Message's Location in Memory
 lwz	r3,0x0(r4)			#Get Text Pointer
 cmpwi	r3,0x0				#Check If This Entry Exists
 beq	CheckForDuplicates_MatchingWindowIncLoop
 lhz	r3,0x6(r4)			#Get Window ID
 cmpw	r3,r31				#Check If They Match
 bne	CheckForDuplicates_MatchingWindowIncLoop

	#Upon Finding a Match
	#Remove This Window
	 lwz	r3,0x0(r4)
	 branchl	r12,0x803a5cc4

	#Zero Out Entry
	 mulli	r5,r28,0x8			#Get Message's Offset
	 add	r4,r5,r29			#Get Message's Location in Memory
	 li	r3,0x0
	 stw	r3,0x0(r4)
	 stw	r3,0x4(r4)

	#Init Shift Loop Count
	 addi	r27,r28,0x1			#Window After Matching Window ID = Shift Loop Count Starting Value

	#Loop - Move All Windows After This Down
	CheckForDuplicates_MatchingWindowShiftLoop:
	  mulli	r5,r27,0x8		#Get Message's Offset
	  add	r4,r5,r29		#Get Message's Location in Memory
	  lwz	r5,0x0(r4)		#Load Text Pointer
	  lwz	r6,0x4(r4)		#Load Text Timer and ID
	  stw	r5,-0x8(r4)		#Store Text Pointer
	  stw	r6,-0x4(r4)		#Store Text Timer and ID
	  li	r3,0x0
	  stw	r3,0x0(r4)		#Zero Out
	  stw	r3,0x4(r4)	 	#Zero Out

	#Move Message Downwards/Upwards Depending On The Area
	  lwz	r3,-0x8(r4)		#Get Text Pointer
	  cmpwi	r3,0x0			#Check If This Entry Is Active
	  beq	CheckForDuplicates_MatchingWindowShiftIncLoop
	  bl	CheckForDuplicates_Floats
	  mflr	r4
	  mulli	r5,AreaID,0x4				#Area ID into offset
	  lfsx	f1,r4,r5
	  lfs	f2,0x4(r3)				#Get Text's Y Value
	  fadds	f1,f1,f2
	  stfs	f1,0x4(r3)				#Store Text's Y Value

	  CheckForDuplicates_MatchingWindowShiftIncLoop:
	  addi	r27,r27,0x1
	  cmpw	r27,r30
	  blt	CheckForDuplicates_MatchingWindowShiftLoop

  	  b	CheckForDuplicates_Exit

CheckForDuplicates_MatchingWindowIncLoop:
addi	r28,r28,0x1
cmpw	r28,r30
blt	CheckForDuplicates_MatchingWindowLoop

CheckForDuplicates_Exit:
restore
blr

##############################

TextProperties:
blrl

#Area 1 (Above HUD)
.long 0xC1A80000 #X Base
.long 0x41300000 #Y Value
.long 0x41600000 #X Difference Between Players
.long 0x3D23D70A	#Text Size
.long 0xC3CD0000 #background Y position
.long 0x41400000 #background X stretch
.long 0x41E00000 #background Y stretch

#Area 2 (top of screen)
.long 0xC1A80000 #X Base
.long 0xC1A00000 #Y Value
.long 0x41600000 #X Difference Between Players
.long 0x3D23D70A	#Text Size
.long 0xC3CD0000 #background Y position
.long 0x41180000 #background X stretch
.long 0x41E00000 #background Y stretch

#Area 3 (Event Popup)
.long 0x00000000 #Whether to Use HUD Location, 0 = no
.float -15 #Y Value
.float 19 #X Value
.float 0.04	#Canvas Size
.float -410 #background Y position
.float 13.5 #background X stretch
.float 28 #background Y stretch


##############################

#******************#
ShiftQueue_Floats:
blrl
.long 0xC0900000			#Area 1
.long 0x40900000			#Area 2
#******************#

#******************#
CheckForDuplicates_Floats:
blrl
.long 0x40900000			#Area 1
.long 0xC0900000			#Area 2
#******************#

TextASCII3:
blrl
.long 0x815B0000



Moonwalk_Exit:
mr	r3,text		#return text pointer
restore
blr
