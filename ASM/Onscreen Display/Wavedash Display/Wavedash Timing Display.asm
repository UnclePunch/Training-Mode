#To be inserted at 80099d7c
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
	li	r0,OSD.Wavedash			#wavedash ID
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

	#CHECK IF IT WAS A WAVEDASH (compare with 20)
	lfs	f1,0x894(playerdata)
	lfs	f2,-0x7fac(rtoc)			#get fp 20
	fcmpo	cr0,f1,f2
	bgt	Moonwalk_Exit

	mr	r3,playerdata			#backup playerdata pointer
	li	r4,60			#display for 60 frames
	li	r5,0			#Area to Display (0-2)
	li	r6,0			#Window ID (Unique to This Display)
	branchl	r12,TextCreateFunction			#create text custom function

	mr	text,r3			#backup text pointer

	#Display Wavedash Frame
		mr 	r3,r29			#text pointer
		bl	TextASCII
		mflr 	r4			#get ASCII to print
		lfs	f1,0x894(playerdata)
		fctiwz	f1,f1
		stfd	f1,0xF0(sp)
		lwz	r5,0xF4(sp)
		lfs	f1, -0x37B4 (rtoc)			#default text X/Y
		lfs	f2, -0x37B4 (rtoc)			#default text X/Y
		branchl r12,0x803a6b98

	#Check if frame perfect
		lbz	r4,0x680(playerdata)
		cmpwi	r4,0x0
		bne DisplayWavedashAngle
	#Change Color
		mr	r4,r3				#subtext id
		mr 	r3,r29			#text pointer
		load	r5,0x8dff6eff
		stw	r5,0xF0(sp)
		addi r5,sp,0xF0
		branchl r12,0x803a74f0

	DisplayWavedashAngle:
	#Display Wavedash Angle
		mr 	r3,r29			#text pointer
		bl	TextASCII2
		mflr 	r4			#get ASCII to print
		lfs f3,AirdodgeAngle(playerdata)
		lfs	f1, -0x37B4 (rtoc)			#default text X/Y
		lfs	f2, -0x37B0 (rtoc)			#shift down on Y axis
		crset 6
		branchl r12,0x803a6b98

	#Check Angle
		lfs f1,AirdodgeAngle(playerdata)
		bl	Floats
		mflr r4
	#Check For Perfect Angle
		lfs f2,0x0(r4)
		fcmpo cr0,f1,f2
		beq PerfectAngle
	#Check For OK Angle
		lfs f2,0x4(r4)
		fcmpo cr0,f1,f2
		bgt Moonwalk_Exit
		lfs f2,0x8(r4)
		fcmpo cr0,f1,f2
		blt Moonwalk_Exit
	OKAngle:
		load	r5,0xfff000ff
		stw	r5,0xF0(sp)
		b ChangeAngleColor
	PerfectAngle:
		load	r5,0x8dff6eff
		stw	r5,0xF0(sp)
		b ChangeAngleColor
	ChangeAngleColor:
	#Change Color
		mr	r4,r3				#subtext id
		mr 	r3,r29			#text pointer
		addi r5,sp,0xF0
		branchl r12,0x803a74f0


b Moonwalk_Exit

#########################

TextASCII:
blrl
.string "Wavedash Frame: %d"
.align 2

TextASCII2:
blrl
.string "Angle: %4.4f"
.align 2

Floats:
blrl
.float -0.2875		#Perfect Angle
.float -0.3000   #Good Angle Max
.float -0.3375   #Good Angle Min

##############################

Moonwalk_Exit:
restoreall

lwz	r4, -0x514C (r13)
