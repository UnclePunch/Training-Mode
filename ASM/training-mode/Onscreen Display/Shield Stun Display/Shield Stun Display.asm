#To be inserted at 80093368
.include "../../Globals.s"

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

	mr	player,r3
	lwz	playerdata,0x2c(player)


	#CHECK IF ENABLED
	li	r0,OSD.ShieldStun			#wavedash ID
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
restoreall
mr	r3,player
mr	r30, r3
