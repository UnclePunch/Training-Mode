#To be inserted at 80080e40
.include "../../Globals.s"

.set StackSize,0x300
.set Stack_BackedUpReg,0x8
  .set Stack_BackedUpReg_Length,0x30
.set Stack_BackedUpFloats, (Stack_BackedUpReg+Stack_BackedUpReg_Length)
  .set Stack_BackedUpFloats_Length,0x14
.set Stack_ECBBoneStruct, (Stack_BackedUpFloats+Stack_BackedUpFloats_Length)
  .set Stack_ECBBoneStruct_Length,0x18
.set Stack_ECBStruct, (Stack_ECBBoneStruct+Stack_ECBBoneStruct_Length)
  .set Stack_ECBStruct_Length,0x1AC
.set Stack_MiscSpace, (Stack_ECBStruct+Stack_ECBStruct_Length)

.set  REG_P2Data,30
.set  REG_EventConstants,31

mflr r0
stw r0, 0x4(r1)
stwu	r1,-StackSize(r1)	# make space for 12 registers
stmw  r20,Stack_BackedUpReg(r1)

#check for renderpass 2
  cmpwi r29,2
  bne Exit

#Get Floats
  bl  Constants
  mflr  REG_EventConstants

#Check if fox or falco
  lwz r3,0x4(REG_P2Data)
  cmpwi r3,Fox.Int
  beq isSpacie
  cmpwi r3,Falco.Int
  beq isSpacie
  b Exit
isSpacie:
#Check if in up b hold
  lwz r3,0x10(REG_P2Data)
  cmpwi r3,353
  beq isFirefoxHold
  cmpwi r3,354
  beq isFirefoxHold
  b Exit
isFirefoxHold:
#Check if spacie codes are enabled
	li	r0,OSD.SpacieTech			#Fox Training Codes ID
	lwz	r4,-0x77C0(r13)
	lwz	r4,0x1F24(r4)
	li	r3, 1
	slw	r0, r3, r0
	and.	r0, r0, r4
	beq	Exit

#region ecb test code
.set REG_arctan,31
.set REG_XComp,30
.set REG_YComp,31
.set REG_XPerFrame,29
.set REG_YPerFrame,28
.set REG_CurrXPos,27
.set REG_CurrYPos,26
.set REG_ECBStruct,20
.set REG_ECBBoneStruct,21
.set REG_LoopCount,22
.set REG_GX,23
.set REG_CObjBackup,24
.set REG_Interrupt,25

.set RandomAngleRange,20

#If game is paused or this is a CPU, use playerblock inputs
  li  r3,1
  branchl r12,0x801a45e8
  cmpwi r3,2
  beq PBInputs
  lbz r3,0xC(REG_P2Data)
  branchl r12,0x8003241c
  cmpwi r3,0x0
  bne PBInputs
HWInputs:
  load  r3,HSD_InputStructStart
  lbz r4,0x618(REG_P2Data)
  mulli r4,r4,68
  add r3,r3,r4
	lfs	REG_XComp,InputStruct_LeftAnalogXFloat(r3)
	lfs	REG_YComp,InputStruct_LeftAnalogYFloat(r3)
#Now apply deadzone
  lfs	f0, -0x778C (rtoc)
  lwz	r3, -0x514C (r13)
  lfs	f1, 0 (r3)
  fmr f2,REG_XComp
  fcmpo cr0,f2,f0
  bge 0x8
  fneg  f2,f2
  fcmpo cr0,f2,f1
  bge 0x8
  lfs	REG_XComp, -0x778C (rtoc)
  fmr f2,REG_YComp
  fcmpo cr0,f2,f0
  bge 0x8
  fneg  f2,f2
  fcmpo cr0,f2,f1
  bge 0x8
  lfs	REG_YComp, -0x778C (rtoc)
  b GetInputsEnd
PBInputs:
	lfs	REG_XComp,0x620(REG_P2Data)
	lfs	REG_YComp,0x624(REG_P2Data)
GetInputsEnd:
#Get atan2
	fmr	f1,REG_YComp
	lfs	f2,0x2C(REG_P2Data)
	fmuls	f2,f2,REG_XComp
	branchl	r12,0x80022c30
	fmr	REG_arctan,f1
#Get XComp
	fmr	f1,REG_arctan
	branchl	r12,0x80326240
	fmr	REG_XComp,f1
	fmr	f1,REG_arctan
	branchl	r12,0x803263d4
	fmr	REG_YComp,f1
#Get Firefox distance per frame
	lwz	r3, 0x02D4 (REG_P2Data)
	lfs	f1, 0x0074 (r3)
	lfs	f0, 0x002C (REG_P2Data)
	fmuls	f1,f1,REG_XComp
	fmuls	REG_XPerFrame,f1,f0
	lfs	f1, 0x0074 (r3)
	fmuls	REG_YPerFrame,f1,REG_YComp
#Create an ECB struct on the stack
	addi	REG_ECBBoneStruct,sp,Stack_ECBBoneStruct
	addi	REG_ECBStruct,sp,Stack_ECBStruct
	mr	r3,REG_ECBStruct
	branchl	r12,0x80041ee4
#Create ECB Bone struct
/*
0x00 = ECB Current Top Y Offset scale * value
0x04 = ECB Current Bottom Y Offset neg(scale * vlaue)
0x08 = ECB Current Left X Offset neg(scale * vlaue)
0x0C = ECB Current Left Y Offset 0
0x10 = ECB Current Right X Offset scale * value
0x14 = ECB Current Right Y Offset 0
*/
#Copy Struct
	mr	r3,REG_ECBBoneStruct
	addi	r4,REG_EventConstants,ECB_TopY
	li	r5,0x18
	branchl	r12,memcpy
#Place Current XY into struct
	lfs	REG_CurrXPos,0xB0(REG_P2Data)
	lfs	REG_CurrYPos,0xB4(REG_P2Data)
#Subtract 0.4 to account for the frame of animation left in this state
	lfs	f1,FinalAnimYDifference(REG_EventConstants)
	fsubs	REG_CurrYPos,REG_CurrYPos,f1
	lfs	f1,0xB8(REG_P2Data)
	stfs	f1,0x24(REG_ECBStruct)
#Disable Interrupts
  branchl r12,0x80347364
  mr  REG_Interrupt,r3
#Init Loop
	li	REG_LoopCount,0
#Init GX Prim
  lwz	r5, 0x02D4 (REG_P2Data)
  lfs	f1, 0x0068 (r5)
  fctiwz  f1,f1
  stfd  f1,Stack_MiscSpace(sp)
  lwz r3,Stack_MiscSpace+4(sp)
  load  r4,0x001F1305
  load  r5,0x00001455
  branchl r12,prim.new
  mr  REG_GX,r3
CollisionLoop:
#Store current position
	stfs	REG_CurrXPos,0x4(REG_ECBStruct)
	stfs	REG_CurrYPos,0x8(REG_ECBStruct)
  lfs	f1, -0x778C (rtoc)
  stfs	f1,0xC(REG_ECBStruct)
#Check if frame X or greater
  lwz	r5, 0x02D4 (REG_P2Data)
  lfs f1,0x70(r5)
  fctiwz  f1,f1
  stfd  f1,Stack_MiscSpace(sp)
  lwz r3,Stack_MiscSpace+4(sp)
	cmpw	REG_LoopCount,r3
	blt	CollisionLoop_SkipDecay
CollisionLoop_Decay:
	lfs	f1,0x78(r5)
	fmuls	f1,f1,REG_XComp
	lfs	f2, 0x002C (REG_P2Data)
	fmuls	f1,f1,f2
	fsubs	REG_XPerFrame,REG_XPerFrame,f1
	lfs	f1,0x78(r5)
	fmuls	f1,f1,REG_YComp
	fsubs	REG_YPerFrame,REG_YPerFrame,f1
CollisionLoop_SkipDecay:
#Shift previous positions down
  lfs f1,0x4(REG_ECBStruct)
  lfs f2,0x8(REG_ECBStruct)
  lfs f3,0xC(REG_ECBStruct)
  stfs f1,0x1C(REG_ECBStruct)
  stfs f2,0x20(REG_ECBStruct)
  stfs f3,0x24(REG_ECBStruct)
#Store next position
	fadds	f1,REG_CurrXPos,REG_XPerFrame
	stfs	f1,0x4(REG_ECBStruct)
	fadds	f1,REG_CurrYPos,REG_YPerFrame
	stfs	f1,0x8(REG_ECBStruct)
	lfs	f1, -0x778C (rtoc)
	stfs	f1,0xC(REG_ECBStruct)
#Run collision
	mr	r3,REG_ECBStruct
	mr	r4,REG_ECBBoneStruct
	branchl	r12,0x800475f4#0x800473cc
#Drop through platforms
  cmpwi r3,0
  beq CollisionLoop_SkipPlatform
  mr  r3,REG_ECBStruct
  branchl r12,0x8004cbc0
  cmpwi r3,0
  beq CollisionLoop_SkipPlatform
  lwz	r0, 0x014C (REG_ECBStruct)
  stw	r0, 0x003C (REG_ECBStruct)
CollisionLoop_SkipPlatform:
#Get new position
	lfs	REG_CurrXPos,0x4(REG_ECBStruct)
	lfs	REG_CurrYPos,0x8(REG_ECBStruct)
#Inc Collision ID
  lwz r3,0x38(REG_ECBStruct)
  addi  r3,r3,1
  stw r3,0x38(REG_ECBStruct)
#Determine line color
  lwz r3,0x134(REG_ECBStruct)
  rlwinm. r0,r3,0,0x8000
  bne CollisionLoop_TouchingGround
  rlwinm. r0,r3,0,0x6000
  bne CollisionLoop_TouchingCeiling
  rlwinm. r0,r3,0,0x20
  bne CollisionLoop_TouchingLeftWall
  rlwinm. r0,r3,0,0x40
  bne CollisionLoop_TouchingLRightWall
CollisionLoop_TouchingNothing:
  lwz r4,LineColor(REG_EventConstants)
  b CollisionLoop_GetColorEnd
CollisionLoop_TouchingGround:
  lwz r4,GroundColor(REG_EventConstants)
  b CollisionLoop_GetColorEnd
CollisionLoop_TouchingCeiling:
  lwz r4,CeilingColor(REG_EventConstants)
  b CollisionLoop_GetColorEnd
CollisionLoop_TouchingLeftWall:
  lwz r4,LeftWallColor(REG_EventConstants)
  b CollisionLoop_GetColorEnd
CollisionLoop_TouchingLRightWall:
  lwz r4,RightWallColor(REG_EventConstants)
  b CollisionLoop_GetColorEnd
CollisionLoop_GetColorEnd:
#Draw this point
  lfs f1,0x84(REG_ECBStruct)
  fadds f1,REG_CurrXPos,f1
  lfs f2,0x88(REG_ECBStruct)
  lfs f3,Float2(REG_EventConstants)
  fdivs f2,f2,f3
  fadds f2,REG_CurrYPos,f2
  lfs f3,FirefoxDrawZ(REG_EventConstants)
  mr  r3,REG_GX
  stfs  f1,0x0(r3)
  stfs  f2,0x0(r3)
  stfs  f3,0x0(r3)
  stw   r4,0x0(r3)
#Inc Loop
	addi	REG_LoopCount,REG_LoopCount,1
  lwz	r5, 0x02D4 (REG_P2Data)
  lfs	f1, 0x0068 (r5)
  fctiwz  f1,f1
  stfd  f1,Stack_MiscSpace(sp)
  lwz r3,Stack_MiscSpace+4(sp)
	cmpw	REG_LoopCount,r3
	blt	CollisionLoop
#End Loop
  branchl r12,prim.close
#Restore Interrupts
  mr  r3,REG_Interrupt
  branchl r12,0x8034738c
  b Exit
#endregion


Constants:
blrl

.set	ECB_TopY,0x0 #scale * value
.set	ECB_BottomY,0x4 #neg(scale * vlaue)
.set	ECB_LeftX,0x8 #neg(scale * vlaue)
.set	ECB_LeftY,0xC #0
.set	ECB_RightX,0x10 #scale * value
.set	ECB_RightY,0x14 #0
.set	FinalAnimYDifference,0x18
.set  Float2,0x1C
.set  FirefoxDrawZ,0x20
.set  LineColor,0x24
.set  LeftWallColor,0x28
.set  RightWallColor,0x2C
.set  CeilingColor,0x30
.set  GroundColor,0x34
.float 9
.float 2.5
.float -3.3
.float 5.7
.float 3.3
.float 5.7
.float 0.4
.float 2
.float 10
.byte 0, 138, 255, 255
.byte 12, 255, 41, 255
.byte 12, 255, 41, 255
.byte 255, 55, 55, 255
.byte 255, 255, 255, 255

Exit:
  lmw  r20,Stack_BackedUpReg(r1)
  lwz r0, StackSize+4(r1)
  addi	r1,r1,StackSize	# release the space
  mtlr r0
  mr	r3, r28
