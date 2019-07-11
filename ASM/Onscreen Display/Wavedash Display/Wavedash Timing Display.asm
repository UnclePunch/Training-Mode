#To be inserted at 80099d7c
.include "../../Globals.s"

.set playerdata,29
.set player,27
.set text,28

backup

#Get Pointers
	mr	player,r3
	lwz playerdata,0x2C(player)


#CHECK IF OSD IS ENABLED
	li	r0,OSD.Wavedash			#wavedash ID
	lwz	r4,-0x77C0(r13)
	lwz	r4,0x1F24(r4)
	li	r3, 1
	slw	r0, r3, r0
	and.	r0, r0, r4
	beq	Injection_Exit

#Check if player is a subcharacter
	mr	r3,playerdata
	branchl	r12,0x80005510
	cmpwi	r3,0x1
	beq	Injection_Exit

#CHECK IF IT WAS A WAVEDASH (landed within 20 frames)
	lhz	r3,FramesinCurrentAS(playerdata)
	cmpwi r3,20
	bgt	Injection_Exit

#Create OSD Popup
	mr	r3,playerdata			#backup playerdata pointer
	li	r4,60			#display for 60 frames
	li	r5,0			#Area to Display (0-2)
	li	r6,0			#Window ID (Unique to This Display)
	branchl	r12,TextCreateFunction			#create text custom function

	mr	text,r3			#backup text pointer

###########################
## Print Wavedash Timing ##
###########################

#Write out top line
	mr 	r3,text			#text pointer
	bl	TextASCII
	mflr 	r4			#get ASCII to print
	lhz	r5,FramesinCurrentAS(playerdata)
	addi r5,r5,1								#1-index number
	lfs	f1, -0x37B4 (rtoc)			#default text X/Y
	lfs	f2, -0x37B4 (rtoc)			#default text X/Y
	crset 6
	branchl r12,0x803a6b98

#Check if frame perfect
	lbz	r4,0x680(playerdata)
	cmpwi	r4,0x0
	bne DisplayWavedashAngle
#Change Color
	mr	r4,r3				#subtext id
	mr 	r3,text			#text pointer
	load	r5,0x8dff6eff
	stw	r5,0xF0(sp)
	addi r5,sp,0xF0
	branchl r12,0x803a74f0

###########################
## Print Wavedash Angle  ##
###########################

DisplayWavedashAngle:
#Convert angle to degrees
	lfs	f1,AirdodgeAngle(playerdata)
	lfs	f2, -0x3D10 (rtoc)			#0.017453
	fdivs f2,f1,f2
#Multiply by 10 to preserve 1 decimal point
	li	r3,10
	bl	IntToFloat
	fmuls f2,f1,f2
#Cast to int to floor
	fctiwz f1,f2
	stfd f1,-0x4(sp)
	lwz r3,0x0(sp)
#Cast back to float
	bl	IntToFloat
#Divide by 10 to get decimal point back
	fmr f2,f1
	li	r3,10
	bl	IntToFloat
	fdivs f2,f2,f1
#Normalize to 0-90, definitely could have handled this better but its w/e
	li	r3,0
	bl	IntToFloat
	fcmpo cr0,f2,f1
	bge TopQuadrant
BottomQuadrant:
	li	r3,-90
	bl	IntToFloat
	fcmpo cr0,f2,f1
	bgt Quadrant4
Quadrant3:
	li	r3,180
	bl	IntToFloat
	fadds f2,f1,f2
	b	SaveAngle
Quadrant4:
	fneg f2,f2
	b	SaveAngle
TopQuadrant:
	li	r3,90
	bl	IntToFloat
	fcmpo cr0,f2,f1
	bgt Quadrant2
Quadrant1:
	b	SaveAngle
Quadrant2:
	fneg f2,f2
	li	r3,180
	bl	IntToFloat
	fadds f2,f1,f2
	b	SaveAngle

SaveAngle:
	stfs f2,0x80(sp)			#place on stack for safe keeping

#Display Wavedash Angle
	mr 	r3,text			#text pointer
	bl	TextASCII2
	mflr 	r4			#get ASCII to print
	lfs	f1, -0x37B4 (rtoc)			#default text X/Y
	lfs	f2, -0x37B0 (rtoc)			#shift down on Y axis
	lfs f3,	0x80(sp)
	crset 6
	branchl r12,0x803a6b98

#Get Angle and Float Pointer
	bl	Floats
	mflr r4
	lfs f1,	0x80(sp)
#Check For Perfect Angle
	lfs f2,0x0(r4)
	fcmpo cr0,f1,f2
	blt Injection_Exit
	lfs f2,0x4(r4)
	fcmpo cr0,f1,f2
	blt PerfectAngle
	lfs f2,0x8(r4)
	fcmpo cr0,f1,f2
	bgt Injection_Exit
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
	mr 	r3,text			#text pointer
	addi r5,sp,0xF0
	branchl r12,0x803a74f0

b Injection_Exit

#########################

TextASCII:
blrl
.string "Wavedash Frame: %d"
.align 2

TextASCII2:
blrl
.string "Angle: %2.1f"
.align 2

Floats:
blrl
.float 16.8		#Great Angle Min
.float 23.7		#Great Angle Max
.float 30.5		#Good Angle Max

##############################

IntToFloat:
mflr r0
stw r0, 0x4(r1)
stwu	r1,-0x100(r1)	# make space for 12 registers
stmw  r20,0x8(r1)
stfs  f2,0x38(r1)

lis	r0, 0x4330
lfd	f2, -0x6758 (rtoc)
xoris	r3, r3,0x8000
stw	r0,0xF0(sp)
stw	r3,0xF4(sp)
lfd	f1,0xF0(sp)
fsubs	f1,f1,f2		#Convert To Float

lfs  f2,0x38(r1)
lmw  r20,0x8(r1)
lwz r0, 0x104(r1)
addi	r1,r1,0x100	# release the space
mtlr r0
blr

##############################

Injection_Exit:
mr	r3,player
restore

lwz	r4, -0x514C (r13)
