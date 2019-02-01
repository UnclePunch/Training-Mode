#To be inserted at 800998a8
.include "../../Globals.s"

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

backupall

mr	player,r3
lwz	playerdata,0x2C(player)


	#CHECK IF ENABLED
	li	r0,OSD.ShieldDrop			#ID
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

	#Check If On a Platform
	addi	r3,playerdata,1776
	branchl	r12,0x8004cbc0
	cmpwi	r3,0x0
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


		InitalizeTopText:
		#Change Color
		load	r3,0xffa2baff
		stw	r3,0x30(text)
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
.string "Frame %d/5"
.align 2

YCoord:
blrl
.string "Y = %f"
.align 2

##############################


Moonwalk_Exit:
restoreall
lwz	r0, 0x0004 (r4)
