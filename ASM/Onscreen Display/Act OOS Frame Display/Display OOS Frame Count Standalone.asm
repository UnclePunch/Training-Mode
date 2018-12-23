#To be inserted at 80005508
.include "D:/Users/Vin/Documents/GitHub/Training-Mode/ASM/Globals.s"

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

backupall

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
restoreall
blr
