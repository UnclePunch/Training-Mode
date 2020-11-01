#To be inserted at 80236b40
.include "../../Globals.s"
.include "../../../m-ex/Header.s"

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

#####################
## Recommended OSD ##
#####################

#Get Options String
	lwz	r3,-0x77C0(r13)			#Get Memcard Data
  lbz	r3,OSDRecommended(r3)
  bl  FDDRecommendedOptions
  mflr  r4
  branchl r12,SearchStringTable

#Create Text
	mr	r5,r3
	mr	r3,r30
	bl	FDDRecommended
	mflr	r4
	lfs	f1,RecommendedX(TextProp)
	lfs	f2,RecommendedY(TextProp)
	branchl r12,Text_InitializeSubtext
	stb	r3,0x49(r31)			#Store Subtext ID

#Change Color
	mr	r4,r3
	mr	r3,r30
	addi	r5,TextProp,RecommendedColor
	branchl	r12,Text_ChangeTextColor

#Create Z Text
	mr	r3,r30
	bl	FDDRecommendedZ
	mflr	r4
	lfs	f1,RecommendedZX(TextProp)
	lfs	f2,0x28(TextProp)
	branchl r12,Text_InitializeSubtext

#Change Color
	mr	r4,r3
	mr	r3,r30
	addi	r5,TextProp,RecommendedColor
	branchl	r12,Text_ChangeTextColor

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
.set REG_TextGObj,31
.set REG_StringArray,30
.set REG_StringID,29
.set TextProp,28

#Backup args
	backup
	mr	REG_TextGObj,r3
	mr	REG_StringArray,r4
	mr	REG_StringID,r5
	bl	TextProperties
	mflr	TextProp
	stfs	f1,0xB0(sp)


	mr	r3,REG_StringID
	mr	r4,REG_StringArray
	branchl	r12,SearchStringTable

#GET Y VALUE
	xoris	r0, REG_StringID, 0x8000
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

	mr	r4,r3
	mr	r3,REG_TextGObj
	lfs	f1,0xB0(sp)
	branchl r12,Text_InitializeSubtext
	restore
	blr


TextProperties:
blrl
.set RecommendedX,0x2C
.set RecommendedY,0x30
.set RecommendedColor,0x34
.set RecommendedZX,0x38
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
.float 800
.float -43.0
.long 0x8dff6eff
.float 630

FDDRecommended:
blrl
.string "Suggested OSDs: %s"
.align 2

FDDRecommendedOptions:
blrl
.string "On"
.string "Off"
.align 2

FDDRecommendedZ:
blrl
.string "(Z)"
.align 2

TextASCIILeft:
blrl
.string ""
.string "Wavedash Info"
.string "L-Cancel"
.string "Missed Tech"
.string "Act OoS Frame"
.string "Meteor Cancel"
.string "Dashback"
.string "Shield Drop"
.string "Inputs Per Minute"
.string "Spacie Tech"
.string "Powershield Frame"
.string "Shield Poke + ADT"
.string "SDI Inputs"
.string "Grab Breakout"
.string "Ledgedash Info"
.string "Act OoHitstun"
.align 2

TextASCIIRight:
blrl

.string ""
.string "Hitstun/Hitlag"
.string "Shield Stun"
.string "State Frames Left"
.string ""
.string "Act OoLag"
.string "Crouch Cancel"
.string "Act OoJump"
.string "Act OoJumpSquat"
.string "Fastfall Timing"
.string "Frame Advantage"
.string "Combo Counter"
.string "DI Draw"
.string ""
.string "UniversalControllerFix"
.align 2

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
