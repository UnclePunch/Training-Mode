#To be inserted at 801a10e8
.include "../../Globals.s"
.include "../../../m-ex/Header.s"

.set text,31
.set textproperties,30
.set staticTextData,29
.set inputStruct,28
.set GObj,31

backup

#Only in Event Mode
  load r3,SceneController
  lbz r3,Scene.CurrentMajor(r3)
  cmpwi r3,Scene.EventMode
  bne Exit

load staticTextData,0x804a1f58

#CREATE TEXT OBJECT, RETURN POINTER TO STRUCT IN r3
	li r3,2
  lwz  r4,0x0(staticTextData)
	branchl r12,0x803a6754
  mr  text,r3

#Store pointer to text
  stw  r3,0x8(staticTextData)

#Get Properties
	bl Text_Properties
	mflr textproperties

#Check Who Paused
  load r3,0x8046b69c
  lbz  r3,0x5(r3)
#Get Inputs
  mulli r3,r3,68
  load r4,0x804c21cc
  add  inputStruct,r3,r4

#SET TEXT SPACING TO TIGHT
	li r4,0x0
	stb r4,0x49(text)

#SET TEXT TO NOT CENTER AROUND X LOCATION
	li r4,0x0
	stb r4,0x4A(text)

#Change Background Text Color
  li  r3,0x0
  stw r3,0x30(text)
#Init Background Text
  mr 	  r3,text		#struct pointer
  lfs 	f1,0x10(textproperties)		#X offset of text
  lfs 	f2,0x14(textproperties) 		#Y offset of text
  bl    TextBackground
  mflr  r4
  branchl r12,0x803a6b98
#set size/scaling
  mr  r4,r3
  mr	r3,text
  lfs	f1,0x18(textproperties) #get text scaling value from table
  lfs	f2,0x1C(textproperties) #get text scaling value from table
  branchl	r12,0x803a7548

#SET TEXT SPACING TO TIGHT
	li r4,0x1
	stb r4,0x49(text)

#Init Textline X
	mr 	  r3,text		#struct pointer
	lfs 	f1,0x0(textproperties)		#X offset of text
	lfs 	f2,0x4(textproperties) 		#Y offset of text
	bl    TextX
  mflr  r4
  lbz r5,0x18(inputStruct)
  lfs	f3,0x20(inputStruct)
  crset	6
	branchl r12,0x803a6b98
#set size/scaling
  mr  r4,r3
	mr	r3,text
	lfs	f1,0x8(textproperties) #get text scaling value from table
	lfs	f2,0x8(textproperties) #get text scaling value from table
	branchl	r12,0x803a7548

#Init Textline Y
  mr 	  r3,text		#struct pointer
  lfs 	f1,0x0(textproperties)		#X offset of text
  lfs 	f2,0xC(textproperties) 		#Y offset of text
  bl    TextY
  mflr  r4
  lbz r5,0x19(inputStruct)
  lfs	f3,0x24(inputStruct)
  crset	6
  branchl r12,0x803a6b98
#set size/scaling
  mr  r4,r3
	mr	r3,text
	lfs	f1,0x8(textproperties) #get text scaling value from table
	lfs	f2,0x8(textproperties) #get text scaling value from table
	branchl	r12,0x803a7548

###############################
## Schedule Updater Function ##
###############################

#Create GObj
	li	r3, 6
	li	r4, 0
	li	r5, 128
	branchl	r12,0x803901f0
	mr	GObj,r3

#Store Pointer
  stw GObj,0xC(staticTextData)

#Attach Per Frame Process
	mr	r3,GObj
	bl	TextUpdateFunction
	mflr	r4
	li	r5,10
	branchl	r12,0x8038fd54


b Exit

#**************************************************#

TextBackground:
blrl
.long 0x815B0000

TextX:
blrl
.long 0x583a2025
.long 0x342e3466
.long 0x20815e20
.long 0x25640000

TextY:
blrl
.long 0x593a2025
.long 0x342e3466
.long 0x20815e20
.long 0x25640000

#**************************************************#

Text_Properties:
blrl
.long 0xC1D80000 #X VALUE x offset (-27)
.long 0xC1B80000 #X VALUE y offset (-23)
.long 0x3D4CCCCD #XANDY text scaling
.long 0xC1A80000 #Y VALUE y offset (-21)
.long 0xC1E80000 #background x offset (-29)
.long 0xC1000000 #background y offset (-8)
.float 0.50      #background X text scaling #0.56
.float 1.08      #background Y text scaling #1.08

#***************************************************#

TextUpdateFunction:
  blrl
  backup

#Get Text Info
  load staticTextData,0x804a1f58
  lwz text,0x8(staticTextData)

#Check Who Paused
  load r3,0x8046b69c
  lbz  r3,0x5(r3)
#Get Inputs
  mulli r3,r3,68
  load r4,0x804c21cc
  add  inputStruct,r3,r4

#Update X Color
  lbz r6,0x18(inputStruct)
  extsb r6,r6
  cmpwi r6,0x0
  blt XNeg
  XPos:
	load	r3,0x8dff6eff
  b XUpdateColor
  XNeg:
	load	r3,0xffa2baff
  b XUpdateColor
XUpdateColor:
  stw r3,0xF8(sp)
  mr  r3,text
  li  r4,1
  addi  r5,sp,0xF8
  branchl r12,0x803a74f0

#Update Textline X
	mr 	  r3,text		#struct pointer
  li    r4,1
	bl    TextX
  mflr  r5
  lbz r6,0x18(inputStruct)
  extsb r6,r6
  cmpwi r6,0
  bge 0x8
  neg r6,r6
  lfs	f1,0x20(inputStruct)
  fabs  f1,f1
  crset	6
	branchl r12,0x803a70a0

#Update Y Color
  lbz r6,0x19(inputStruct)
  extsb r6,r6
  cmpwi r6,0x0
  blt YNeg
  YPos:
	load	r3,0x8dff6eff
  b YUpdateColor
  YNeg:
	load	r3,0xffa2baff
  b YUpdateColor
YUpdateColor:
  stw r3,0xF8(sp)
  mr  r3,text
  li  r4,2
  addi  r5,sp,0xF8
  branchl r12,0x803a74f0

#Update Textline Y
  mr 	  r3,text		#struct pointer
  li    r4,2
  bl    TextY
  mflr  r5
  lbz r6,0x19(inputStruct)
  extsb r6,r6
  cmpwi r6,0
  bge 0x8
  neg r6,r6
  lfs	f1,0x24(inputStruct)
  fabs  f1,f1
  crset	6
  branchl r12,0x803a70a0

  restore
  blr

  #***************************************************#

Exit:
restore
lmw	r26, 0x0018 (sp)
