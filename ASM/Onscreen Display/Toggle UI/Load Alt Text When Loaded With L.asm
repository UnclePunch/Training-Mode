#To be inserted at 80236b40
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
.set player,31
.set Text,30
.set TextProp,28


#CHECK FLAG IN RULES STRUCT
load	r4,0x804a04f0
lbz	r0, 0x0011 (r4)
cmpwi	r0,0x2
blt original

backup

#SPAWN TEXT

bl	TextProperties
mflr	TextProp



##########################
## Write Left Side Text ##
##########################

CreateText:
	#CREATE TEXT ABOVE PLAYERS HUD ELEMENT
	li 	r3,0x0
	lbz	r4, -0x4AEB (r13)
	branchl r12,0x803a6754

	#BACKUP TEXT POINTER
	mr	r30,r3
	stw	r3,0x40(r31)

	#INITALIZE TEXT ATTRIBUTES
	lfs	f1,0x0(TextProp)
	lfs	f2,0x4(TextProp)		#Y Base
	lfs	f3, -0x3B30 (rtoc)

	stfs	f1,0x0(Text)
	stfs	f2,0x4(Text)
	stfs	f3,0x8(Text)

	li 	r3,0x2
	li 	r4,0x1
	stb	r3,0x4A(r30)
	stb	r4,0x48(r30)
	stb	r4,0x49(Text)
	lfs	f2,0x8(TextProp)
	stfs	f2,0x24(Text)
	stfs	f2,0x28(Text)



#Write Text to the Left Side of the Screen
InitLoopLeft:
li	r29,0
LoopStartLeft:
mr	r3,Text		#text struct to write to
bl	TextASCIILeft
mflr	r4		#text ascii
mr	r5,r29		#text ID
lfs	f1, -0x35FC (rtoc)	#X offset
bl	WriteText
IncLoopLeft:
addi	r29,r29,0x1
cmpwi	r29,16
blt	LoopStartLeft



#####################
## Write FDD Title ##
#####################

#Create Text
mr	r3,r30
bl	FDDTitleText
mflr	r4
lfs	f1,0x14(TextProp)
lfs	f2,0x18(TextProp)
branchl r12,0x803a6b98

#Change Color
mr	r4,r3
mr	r3,r30
addi	r5,sp,0xF0
load	r6,0xff7575FF
stw	r6,0x0(r5)
branchl	r12,0x803a74f0

#########################
## Write Max OSD Count ##
#########################

#Create Text
mr	r3,r30
bl	MaxOSDText
mflr	r4
lwz	r5, -0x77C0 (r13)
lbz	r5, 0x1F28 (r5)
addi	r5,r5,1
lfs	f1,0x1C(TextProp)
lfs	f2,0x20(TextProp)
branchl r12,0x803a6b98
stb	r3,0x48(r31)

#Change Color
mr	r4,r3
mr	r3,r30
addi	r5,sp,0xF0
load	r6,0x8dff6eff
stw	r6,0x0(r5)
branchl	r12,0x803a74f0

#Create XY Text
mr	r3,r30
bl	XYText
mflr	r4
lfs	f1,0x24(TextProp)
lfs	f2,0x28(TextProp)
branchl r12,0x803a6b98

#Change Color
mr	r4,r3
mr	r3,r30
addi	r5,sp,0xF0
branchl	r12,0x803a74f0

###########################
## Write Right Side Text ##
###########################

	#CREATE TEXT ABOVE PLAYERS HUD ELEMENT
	li 	r3,0x0
	lbz	r4, -0x4AEB (r13)
	branchl r12,0x803a6754

	#BACKUP TEXT POINTER
	mr	r30,r3
	stw	r3,0x44(r31)

	#INITALIZE TEXT ATTRIBUTES
	lfs	f1,0x0(TextProp)
	lfs	f2,0x4(TextProp)		#Y Base
	lfs	f3, -0x3B30 (rtoc)

	stfs	f1,0x0(Text)
	stfs	f2,0x4(Text)
	stfs	f3,0x8(Text)

	li 	r3,0x2
	li 	r4,0x1
	stb	r3,0x4A(r30)
	stb	r4,0x48(r30)
	stb	r4,0x49(Text)
	lfs	f2,0x8(TextProp)
	stfs	f2,0x24(Text)
	stfs	f2,0x28(Text)

#Write Text to the Right Side of the Screen
InitLoopRight:
li	r29,0
LoopStartRight:
mr	r3,Text		#text struct to write to
bl	TextASCIIRight
mflr	r4		#text ascii
mr	r5,r29		#text ID
lfs	f1,0x10(TextProp)
bl	WriteText
IncLoopRight:
addi	r29,r29,0x1
cmpwi	r29,15
blt	LoopStartRight


restore
b exit







###############
## WriteText ##
###############
#r3= TextStruct
#r4= TextASCIIPointer
#r5= Text ID
#f1= X Offset

WriteText:

	#SEND ASCII TO TEXT STRUCT
	backup
	mulli	r6,r5,0x10
	add	r4,r4,r6		#get text

		#GET Y VALUE
		xoris	r0, r5, 0x8000
		stw	r0, 0xF4 (sp)
		lis	r0, 0x4330
		stw	r0, 0xF0 (sp)
		lfd	f0, 0xF0 (sp)
		lfd	f3, -0x3B20 (rtoc)
		fsubs	f0,f3,f0
		lfs	f2,0x4(TextProp)		#Y Base
		lfs	f3,0xC(TextProp)		#Y DIff
		fmuls	f0,f0,f3
		fsubs	f2,f2,f0

	branchl r12,0x803a6b98
	restore
	blr




TextProperties:
blrl
.long 0xC0900000	#Text X Location
.long 0xC0E80000 #Text Y Base
.long 0x3CB43958 #Text Scaling
.long 0x42480000 #Text Y Difference
.long 0x4423C000 #Right Text X Offset
.long 0x43960000 #Center Title X
.long 0xC22C0000 #Center Title Y
.long 0xC3200000 #Max Windows X
.long 0xC22C0000 #Max Windows Y
.long 0xC3700000 #XYText X
.long 0xC0E80000 #XYText Y

TextASCIILeft:
blrl

#Info Codes
.long 0x496e666f
.long 0x20436f64
.long 0x65730000
.long 0x00000000

#Wavedash Timing
.long 0x57617665
.long 0x64617368
.long 0x2054696d
.long 0x696e6700

#L-Cancel Timing and %
.long 0x4c2d4361
.long 0x6e63656c
.long 0x00000000
.long 0x00000000

#Missed Tech Info
.long 0x4d697373
.long 0x65642054
.long 0x65636800
.long 0x00000000

#Act OOS Frame
.long 0x41637420
.long 0x4f6f5320
.long 0x4672616d
.long 0x65000000

#Meteor Cancel
.long 0x4d657465
.long 0x6f722043
.long 0x616e6365
.long 0x6c000000

#Dashback
.long 0x44617368
.long 0x6261636b
.long 0x00000000
.long 0x00000000

#Shield Drop
.long 0x53686965
.long 0x6c642044
.long 0x726f7000
.long 0x00000000

#APM
.long 0x496e7075
.long 0x74732050
.long 0x6572204d
.long 0x696e2e00

#Fox Tech Codes
.long 0x53706163
.long 0x69652054
.long 0x65636800
.long 0x00000000

#Powershield
.long 0x506f7765
.long 0x72736869
.long 0x656c6400
.long 0x00000000

#Shield Poke+ADT
.long 0x53686965
.long 0x6c64506f
.long 0x6b65817B
.long 0x41445400

#SDI Display
.long 0x53444920
.long 0x44697370
.long 0x6c617900
.long 0x00000000

#Grab Breakout
.long 0x47726162
.long 0x20427265
.long 0x616b6f75
.long 0x74000000

#Ledgedash Codes
.long 0x4c656467
.long 0x65646173
.long 0x6820436f
.long 0x64657300

#Act OoHitstun
.long 0x41637420
.long 0x4f6f4869
.long 0x74737475
.long 0x6e000000



TextASCIIRight:
blrl

#Labbing Codes
.long 0x4c616262
.long 0x696e6720
.long 0x436f6465
.long 0x73000000


#Hitstun/Hitlag
.long 0x48697473
.long 0x74756e81
.long 0x5e486974
.long 0x6c616700


#Shield Stun
.long 0x53686965
.long 0x6c642053
.long 0x74756e00
.long 0x00000000

#AS Frames Left
.long 0x41532046
.long 0x72616d65
.long 0x73204c65
.long 0x66740000

#Blank
.long 0x00000000
.long 0x00000000
.long 0x00000000
.long 0x00000000

#Act OoTech
.long 0x41637420
.long 0x4f6f5761
.long 0x69740000
.long 0x00000000

#Crouch Cancel
.long 0x43726f75
.long 0x63682043
.long 0x616e6365
.long 0x6c000000

#Act OoJump
.long 0x41637420
.long 0x4f6f4a75
.long 0x6d700000
.long 0x00000000

#Act OoJumpSquat
.long 0x41637420
.long 0x4f6f4a75
.long 0x6d705371
.long 0x75617400

#Fastfall Timing
.long 0x46617374
.long 0x66616c6c
.long 0x2054696d
.long 0x696e6700

#Frame Advantage
.long 0x4672616d
.long 0x65204164
.long 0x76616e74
.long 0x61676500

#Combo Count
.long 0x436f6d62
.long 0x6f20436f
.long 0x756e7465
.long 0x72000000

#PlaceHolder
.long 0x00000000
.long 0x00000000
.long 0x00000000
.long 0x00000000

#PlaceHolder
.long 0x00000000
.long 0x00000000
.long 0x00000000
.long 0x00000000

#UCF
.long 0x556e6976
.long 0x65727361
.long 0x6c436f6e
.long 0x74726f6c
.long 0x6c657246
.long 0x69780000


FDDTitleText:
blrl
.long 0x4f534420
.long 0x4d656e75
.long 0x00000000

MaxOSDText:
blrl
.long 0x4d617820
.long 0x4f534427
.long 0x733a2025
.long 0x64000000

XYText:
blrl
.long 0x81695881
.long 0x5e59816A
.long 0x00000000

original:
branchl	r4,0x802359c8
exit:
