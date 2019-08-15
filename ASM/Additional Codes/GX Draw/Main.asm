#To be inserted at 80080e40
.include "../../Globals.s"

.set  REG_PlayerData,30
.set  REG_Interrupt,28

backup

#Disable Interrupts
  branchl r12,0x80347364
  mr  REG_Interrupt,r3
#check for renderpass 2
  cmpwi r29,2
  bne Exit

#Check for firefox trajectory
  lwz r3,0x4(REG_PlayerData)
  cmpwi r3,Fox.Int
  beq CallFirefoxTrajectory
  cmpwi r3,Falco.Int
  beq CallFirefoxTrajectory
  b SkipCallFirefoxTrajectory
CallFirefoxTrajectory:
  bl  FirefoxTrajectory
SkipCallFirefoxTrajectory:
#Check for DI Draw
	lbz	r3,0x221A(REG_PlayerData)			#Check If in Hitlag
	rlwinm.	r3,r3,0,0x20
  beq SkipCallDIDraw
	lbz	r3, 0x221C (REG_PlayerData)
	rlwinm.	r0,r3,0,0x2
  beq SkipCallDIDraw
CallDIDraw:
  bl  DIDraw
SkipCallDIDraw:
  b Exit

#region Firefox Trajectory
FirefoxTrajectory_Constants:
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

#gprs
.set REG_EventConstants,31
.set REG_ECBStruct,20
.set REG_ECBBoneStruct,21
.set REG_LoopCount,22
.set REG_GX,23
.set REG_CObjBackup,24

#fprs
.set REG_arctan,31
.set REG_XComp,30
.set REG_YComp,31
.set REG_XPerFrame,29
.set REG_YPerFrame,28
.set REG_CurrXPos,27
.set REG_CurrYPos,26

#constants
.set RandomAngleRange,20

FirefoxTrajectory:
  mflr r0
  stw r0, 0x4(r1)
  stwu	r1,-StackSize(r1)	# make space for 12 registers
  stmw  r20,Stack_BackedUpReg(r1)

FirefoxTrajectory_isSpacie:
#Check if in up b hold
  lwz r3,0x10(REG_PlayerData)
  cmpwi r3,353
  beq FirefoxTrajectory_isFirefoxHold
  cmpwi r3,354
  beq FirefoxTrajectory_isFirefoxHold
  b FirefoxTrajectory_Exit
FirefoxTrajectory_isFirefoxHold:
#Check if spacie codes are enabled
	li	r0,OSD.SpacieTech			#Fox Training Codes ID
	lwz	r4,-0x77C0(r13)
	lwz	r4,0x1F24(r4)
	li	r3, 1
	slw	r0, r3, r0
	and.	r0, r0, r4
	beq	FirefoxTrajectory_Exit

#Get Floats
  bl  FirefoxTrajectory_Constants
  mflr  REG_EventConstants

#If frame advance && HMN, use HW inputs
  li  r3,0
  branchl r12,0x801a45e8
  cmpwi r3,1
  bne FirefoxTrajectory_PBInputs
  lbz r3,0xC(REG_PlayerData)
  branchl r12,0x8003241c
  cmpwi r3,0x0
  bne FirefoxTrajectory_PBInputs
FirefoxTrajectory_HWInputs:
  load  r3,HSD_InputStructStart
  lbz r4,0x618(REG_PlayerData)
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
  b FirefoxTrajectory_GetInputsEnd
FirefoxTrajectory_PBInputs:
	lfs	REG_XComp,0x620(REG_PlayerData)
	lfs	REG_YComp,0x624(REG_PlayerData)
FirefoxTrajectory_GetInputsEnd:
#Get atan2
	fmr	f1,REG_YComp
	lfs	f2,0x2C(REG_PlayerData)
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
	lwz	r3, 0x02D4 (REG_PlayerData)
	lfs	f1, 0x0074 (r3)
	lfs	f0, 0x002C (REG_PlayerData)
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
	lfs	REG_CurrXPos,0xB0(REG_PlayerData)
	lfs	REG_CurrYPos,0xB4(REG_PlayerData)
#Subtract 0.4 to account for the frame of animation left in this state
	lfs	f1,FinalAnimYDifference(REG_EventConstants)
	fsubs	REG_CurrYPos,REG_CurrYPos,f1
	lfs	f1,0xB8(REG_PlayerData)
	stfs	f1,0x24(REG_ECBStruct)
#Init Loop
	li	REG_LoopCount,0
#Init GX Prim
  lwz	r5, 0x02D4 (REG_PlayerData)
  lfs	f1, 0x0068 (r5)
  fctiwz  f1,f1
  stfd  f1,Stack_MiscSpace(sp)
  lwz r3,Stack_MiscSpace+4(sp)
  load  r4,0x001F1305
  load  r5,0x00001455
  branchl r12,prim.new
  mr  REG_GX,r3
FirefoxTrajectory_CollisionLoop:
#Store current position
	stfs	REG_CurrXPos,0x4(REG_ECBStruct)
	stfs	REG_CurrYPos,0x8(REG_ECBStruct)
  lfs	f1, -0x778C (rtoc)
  stfs	f1,0xC(REG_ECBStruct)
#Check if frame X or greater
  lwz	r5, 0x02D4 (REG_PlayerData)
  lfs f1,0x70(r5)
  fctiwz  f1,f1
  stfd  f1,Stack_MiscSpace(sp)
  lwz r3,Stack_MiscSpace+4(sp)
	cmpw	REG_LoopCount,r3
	blt	FirefoxTrajectory_CollisionLoop_SkipDecay
FirefoxTrajectory_CollisionLoop_Decay:
	lfs	f1,0x78(r5)
	fmuls	f1,f1,REG_XComp
	lfs	f2, 0x002C (REG_PlayerData)
	fmuls	f1,f1,f2
	fsubs	REG_XPerFrame,REG_XPerFrame,f1
	lfs	f1,0x78(r5)
	fmuls	f1,f1,REG_YComp
	fsubs	REG_YPerFrame,REG_YPerFrame,f1
FirefoxTrajectory_CollisionLoop_SkipDecay:
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
  beq FirefoxTrajectory_CollisionLoop_SkipPlatform
  mr  r3,REG_ECBStruct
  branchl r12,0x8004cbc0
  cmpwi r3,0
  beq FirefoxTrajectory_CollisionLoop_SkipPlatform
  lwz	r0, 0x014C (REG_ECBStruct)
  stw	r0, 0x003C (REG_ECBStruct)
FirefoxTrajectory_CollisionLoop_SkipPlatform:
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
  bne FirefoxTrajectory_CollisionLoop_TouchingGround
  rlwinm. r0,r3,0,0x6000
  bne FirefoxTrajectory_CollisionLoop_TouchingCeiling
  rlwinm. r0,r3,0,0x20
  bne FirefoxTrajectory_CollisionLoop_TouchingLeftWall
  rlwinm. r0,r3,0,0x40
  bne FirefoxTrajectory_CollisionLoop_TouchingLRightWall
FirefoxTrajectory_CollisionLoop_TouchingNothing:
  lwz r4,LineColor(REG_EventConstants)
  b FirefoxTrajectory_CollisionLoop_GetColorEnd
FirefoxTrajectory_CollisionLoop_TouchingGround:
  lwz r4,GroundColor(REG_EventConstants)
  b FirefoxTrajectory_CollisionLoop_GetColorEnd
FirefoxTrajectory_CollisionLoop_TouchingCeiling:
  lwz r4,CeilingColor(REG_EventConstants)
  b FirefoxTrajectory_CollisionLoop_GetColorEnd
FirefoxTrajectory_CollisionLoop_TouchingLeftWall:
  lwz r4,LeftWallColor(REG_EventConstants)
  b FirefoxTrajectory_CollisionLoop_GetColorEnd
FirefoxTrajectory_CollisionLoop_TouchingLRightWall:
  lwz r4,RightWallColor(REG_EventConstants)
  b FirefoxTrajectory_CollisionLoop_GetColorEnd
FirefoxTrajectory_CollisionLoop_GetColorEnd:
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
  lwz	r5, 0x02D4 (REG_PlayerData)
  lfs	f1, 0x0068 (r5)
  fctiwz  f1,f1
  stfd  f1,Stack_MiscSpace(sp)
  lwz r3,Stack_MiscSpace+4(sp)
	cmpw	REG_LoopCount,r3
	blt	FirefoxTrajectory_CollisionLoop
#End Loop
  branchl r12,prim.close

FirefoxTrajectory_Exit:
  lmw  r20,Stack_BackedUpReg(r1)
  lwz r0, StackSize+4(r1)
  addi	r1,r1,StackSize	# release the space
  mtlr r0
  blr

####################################################
#endregion

#region DI Draw
DIDraw_Constants:
blrl

.set	ECB_TopY,0x0 #scale * value
.set	ECB_BottomY,0x4 #neg(scale * vlaue)
.set	ECB_LeftX,0x8 #neg(scale * vlaue)
.set	ECB_LeftY,0xC #0
.set	ECB_RightX,0x10 #scale * value
.set	ECB_RightY,0x14 #0
.set  Float2,0x18
.set  FirefoxDrawZ,0x1C
.set  LineColor,0x20
.set  LeftWallColor,0x24
.set  RightWallColor,0x28
.set  CeilingColor,0x2C
.set  GroundColor,0x30
.float 9
.float 2.5
.float -3.3
.float 5.7
.float 3.3
.float 5.7
.float 2
.float 10
.byte 0, 138, 255, 255
.byte 12, 255, 41, 255
.byte 12, 255, 41, 255
.byte 255, 55, 55, 255
.byte 255, 255, 255, 255

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

#gprs
.set REG_EventConstants,31
.set REG_ECBStruct,20
.set REG_ECBBoneStruct,21
.set REG_LoopCount,22
.set REG_GX,23
.set REG_HeldInputs,24
.set REG_GroundState,24
.set REG_Temp,25

#fprs
.set REG_arctan,31
.set REG_XComp,30
.set REG_YComp,29
.set REG_KnockbackX,28
.set REG_KnockbackY,27
.set REG_CurrXPos,26
.set REG_CurrYPos,25
.set REG_DIInput,24
.set REG_KnockbackMag,23
.set REG_Gravity,30

#constants
.set RandomAngleRange,20

DIDraw:
  mflr r0
  stw r0, 0x4(r1)
  stwu	r1,-StackSize(r1)	# make space for 12 registers
  stmw  r20,Stack_BackedUpReg(r1)

#Get Floats
  bl  DIDraw_Constants
  mflr  REG_EventConstants
#If frame advance && HMN, use HW inputs
  li  r3,0
  branchl r12,0x801a45e8
  cmpwi r3,1
  bne DIDraw_PBInputs
  lbz r3,0xC(REG_PlayerData)
  branchl r12,0x8003241c
  cmpwi r3,0x0
  bne DIDraw_PBInputs
DIDraw_HWInputs:
  load  r3,HSD_InputStructStart
  lbz r4,0x618(REG_PlayerData)
  mulli r4,r4,68
  add r3,r3,r4
#If Holding A, override and use PB Inputs
  lwz r0,InputStruct_HeldButtons(r3)
  rlwinm. r0,r0,0,0x100
  bne DIDraw_PBInputs
	lfs	REG_XComp,InputStruct_LeftAnalogXFloat(r3)
	lfs	REG_YComp,InputStruct_LeftAnalogYFloat(r3)
#Get L/R input
  lwz REG_HeldInputs,InputStruct_HeldButtons(r3)
  rlwinm. r0,REG_HeldInputs,0,0x20
  bne DIDraw_HWInputs_PressingLR
  rlwinm. r0,REG_HeldInputs,0,0x40
  bne DIDraw_HWInputs_PressingLR
DIDraw_HWInputs_NoLR:
  li  REG_HeldInputs,0
  b 0x8
DIDraw_HWInputs_PressingLR:
  lis REG_HeldInputs,0x8000
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
  b DIDraw_GetInputsEnd
DIDraw_PBInputs:
	lfs	REG_XComp,0x620(REG_PlayerData)
	lfs	REG_YComp,0x624(REG_PlayerData)
  lwz REG_HeldInputs,0x65C(REG_PlayerData)
DIDraw_GetInputsEnd:
#Get original KB vector
  lfs REG_KnockbackX,0x8C(REG_PlayerData)
  lfs REG_KnockbackY,0x90(REG_PlayerData)
DIDraw_GetArctan:
#Get atan2
	fmr	f1,REG_KnockbackY
	fmr	f2,REG_KnockbackX
	branchl	r12,0x80022c30
	fmr	REG_arctan,f1
#Do something
  fmuls f1,REG_KnockbackY,REG_KnockbackY
  fmadds  REG_KnockbackMag,REG_KnockbackX,REG_KnockbackX,f1
  lfs	f0, -0x750C (rtoc)
  fcmpo cr0,REG_KnockbackMag,f0
  ble DIDraw_SkipUnk
#Do a bunch of stuff
  frsqrte	f2,REG_KnockbackMag
  lfd	f4, -0x74E0 (rtoc)
  lfd	f3, -0x74D8 (rtoc)
  fmul	f0,f2,f2
  fmul	f2,f4,f2
  fnmsub	f0,REG_KnockbackMag,f0,f3
  fmul	f2,f2,f0
  fmul	f0,f2,f2
  fmul	f2,f4,f2
  fnmsub	f0,REG_KnockbackMag,f0,f3
  fmul	f2,f2,f0
  fmul	f0,f2,f2
  fmul	f2,f4,f2
  fnmsub	f0,REG_KnockbackMag,f0,f3
  fmul	f0,f2,f0
  fmul	f0,REG_KnockbackMag,f0
  frsp	f0,f0
  fmr REG_KnockbackMag,f0
DIDraw_SkipUnk:
DIDraw_CalculateKBReduction:
#Check if holding L/R/Z
  rlwinm. r0,REG_HeldInputs,0,0x80000000
  beq DIDraw_CalculateKBReductionEnd
  lwz	r3, -0x514C (r13)
  lfs	f0, 0x01AC (r3)
  fmuls REG_KnockbackMag,f0,REG_KnockbackMag
  fmr  f1,REG_arctan
  branchl r12,cos
  fmuls REG_KnockbackX,f1,REG_KnockbackMag
  fmr  f1,REG_arctan
  branchl r12,sin
  fmuls REG_KnockbackY,f1,REG_KnockbackMag
#Get new atan2
	fmr	f1,REG_KnockbackY
	fmr	f2,REG_KnockbackX
	branchl	r12,0x80022c30
	fmr	REG_arctan,f1
DIDraw_CalculateKBReductionEnd:
#If both inputting nothing, skip DI
  lfs	f1, -0x750C (rtoc)
  fcmpo cr0,f1,REG_XComp
  bne DIDraw_IsInputting
  fcmpo cr0,f1,REG_YComp
  beq DIDraw_DrawTrajectory
DIDraw_IsInputting:
#If some condition is met, skip DI
  lfs	f0, -0x74E8 (rtoc)
  fneg  f1,REG_KnockbackX
  fmuls f1,f1,f1
  fmuls f2,REG_KnockbackY,REG_KnockbackY
  fadds f1,f1,f2
  fcmpo cr0,f1,f0
  blt DIDraw_DrawTrajectory
#Get DI value
  fneg  f2,REG_KnockbackX
  fmuls f2,f2,REG_YComp
  fmuls f3,REG_KnockbackY,REG_XComp
  fadds f2,f2,f3
  fmuls f2,f2,f2
  fdivs REG_DIInput,f2,f1
  lfs	f4, -0x750C (rtoc)
#Cross product
  stfs  REG_XComp,Stack_MiscSpace+0(sp)
  stfs  REG_YComp,Stack_MiscSpace+4(sp)
  lfs f0, -0x750C (rtoc)
  stfs  f0,Stack_MiscSpace+8(sp)
  addi  r3,REG_PlayerData,0x8C
  addi  r4,sp,Stack_MiscSpace+0
  addi  r5,sp,Stack_MiscSpace+12
  branchl r12,0x80342e58
#Check if over 0
  lfs	f0, -0x750C (rtoc)
  lfs f1,Stack_MiscSpace+20(sp)
  fcmpo cr0,f1,f0
  bge 0x8
  fneg  REG_DIInput,REG_DIInput
DIDraw_CalculateDI:
  lwz	r3, -0x514C (r13)
  lfs	f2, -0x7510 (rtoc)
  lfs	f0, 0x01A8 (r3)
  fmuls	f0,f2,f0
  fmadds	REG_arctan,f0,REG_DIInput,REG_arctan
  fmr f1,REG_arctan
  branchl r12,cos
  fmuls REG_KnockbackX,REG_KnockbackMag,f1
  fmr f1,REG_arctan
  branchl r12,sin
  fmuls REG_KnockbackY,REG_KnockbackMag,f1
DIDraw_DrawTrajectory:
#Create an ECB struct on the stack
	addi	REG_ECBBoneStruct,sp,Stack_ECBBoneStruct
	addi	REG_ECBStruct,sp,Stack_ECBStruct
	mr	r3,REG_ECBStruct
	branchl	r12,0x80041ee4
#Create ECB Bone struct
#Copy Struct
	mr	r3,REG_ECBBoneStruct
	addi	r4,REG_EventConstants,ECB_TopY
	li	r5,0x18
	branchl	r12,memcpy
#Get Current XY
	lfs	REG_CurrXPos,0xB0(REG_PlayerData)
	lfs	REG_CurrYPos,0xB4(REG_PlayerData)
	lfs	f1,0xB8(REG_PlayerData)
	stfs	f1,0xC(REG_ECBStruct)
#Init Loop
	li	REG_LoopCount,0
  lfs REG_Gravity,-0x750C (rtoc)
  li  REG_GroundState,1
#Init GX Prim
  lfs f1,0x2340(REG_PlayerData)
  fctiwz  f1,f1
  stfd  f1,Stack_MiscSpace(sp)
  lwz  r3,Stack_MiscSpace+4(sp)
  load  r4,0x001F1306
  load  r5,0x00001455
  branchl r12,prim.new
  mr  REG_GX,r3
DIDraw_CollisionLoop:
#Store current position
	stfs	REG_CurrXPos,0x4(REG_ECBStruct)
	stfs	REG_CurrYPos,0x8(REG_ECBStruct)
DIDraw_CollisionLoop_Decay:
#Get arctan of the KB vector
  fmr f1,REG_KnockbackY
  fmr f2,REG_KnockbackX
  branchl r12,0x80022c30
  fmr  REG_arctan,f1
#Get cos of the atan
  branchl r12,cos
  lwz	r3, -0x514C (r13)
  lfs	f2, 0x0204 (r3)
  fnmsubs	REG_KnockbackX,f2,f1,REG_KnockbackX
#Get sin of the atan
  fmr f1,REG_arctan
  branchl r12,sin
  lwz	r3, -0x514C (r13)
  lfs	f2, 0x0204 (r3)
  fnmsubs	REG_KnockbackY,f2,f1,REG_KnockbackY
DIDraw_CollisionLoop_SkipDecay:
#Now account for gravity
  lfs	f1, 0x016C (REG_PlayerData)
  lfs	f2, 0x0170 (REG_PlayerData)
  fneg  f2,f2
  fsubs REG_Gravity,REG_Gravity,f1
  fcmpo	cr0,REG_Gravity,f2
  bge 0x8
  fmr REG_Gravity,f2
#Shift previous positions down
  lfs f1,0x4(REG_ECBStruct)
  lfs f2,0x8(REG_ECBStruct)
  lfs f3,0xC(REG_ECBStruct)
  stfs f1,0x1C(REG_ECBStruct)
  stfs f2,0x20(REG_ECBStruct)
  stfs f3,0x24(REG_ECBStruct)
#Store next position
	fadds	f1,REG_CurrXPos,REG_KnockbackX
	stfs	f1,0x4(REG_ECBStruct)
	fadds	f1,REG_CurrYPos,REG_KnockbackY
  fadds f1,f1,REG_Gravity
	stfs	f1,0x8(REG_ECBStruct)
	lfs	f1, -0x778C (rtoc)
	stfs	f1,0xC(REG_ECBStruct)
#Run collision
	mr	r3,REG_ECBStruct
	mr	r4,REG_ECBBoneStruct
	branchl	r12,0x800475f4#0x800473cc
#Get new position
	lfs	REG_CurrXPos,0x4(REG_ECBStruct)
	lfs	REG_CurrYPos,0x8(REG_ECBStruct)
#Inc Collision ID
  lwz r3,0x38(REG_ECBStruct)
  addi  r3,r3,1
  stw r3,0x38(REG_ECBStruct)
#Determine line collision behavior
  lwz r3,0x134(REG_ECBStruct)
  rlwinm. r0,r3,0,0x8000
  bne DIDraw_CollisionLoop_TouchingGround
  rlwinm. r0,r3,0,0x6000
  bne DIDraw_CollisionLoop_TouchingCeiling
  rlwinm. r0,r3,0,0x20
  bne DIDraw_CollisionLoop_TouchingWall
  rlwinm. r0,r3,0,0x40
  bne DIDraw_CollisionLoop_TouchingWall
DIDraw_CollisionLoop_TouchingNothing:
  lwz r4,LineColor(REG_EventConstants)
  b DIDraw_CollisionLoop_GetColorEnd

DIDraw_CollisionLoop_TouchingGround:
#If grounded, dont run KB manip code
  cmpwi REG_GroundState,0
  beq DIDraw_CollisionLoop_TouchingGround_GetColor
#Check if over max horizontal velocity
  lwz	r4, -0x514C (r13)
  lfs	f1, 0x0164 (r4)
  fcmpo cr0,REG_KnockbackX,f1
  ble 0x8
  fmr REG_KnockbackX,f1
  fneg  f1,f1
  fcmpo cr0,REG_KnockbackX,f1
  bge 0x8
  fmr REG_KnockbackX,f1
#Adjust KB
  lfs f1,0x158(REG_ECBStruct)
  fmuls REG_KnockbackX,REG_KnockbackX,f1
  lfs f1,0x154(REG_ECBStruct)
  fneg  f1,f1
  fmuls REG_KnockbackY,REG_KnockbackX,f1
#Set as grounded
  li  REG_GroundState,0
DIDraw_CollisionLoop_TouchingGround_GetColor:
#Get ground color
  lwz r4,GroundColor(REG_EventConstants)
  b DIDraw_CollisionLoop_GetColorEnd

DIDraw_CollisionLoop_TouchingCeiling:
#If grounded, dont run KB manip code
  cmpwi REG_GroundState,0
  beq DIDraw_CollisionLoop_TouchingCeiling_GetColor
#Self-Induced velocity
  lfs	f1, -0x750C (rtoc)
  stfs f1,Stack_MiscSpace+0x0(sp)
  stfs REG_Gravity,Stack_MiscSpace+0x4(sp)
#KB-Induced
  stfs REG_KnockbackX,Stack_MiscSpace+0x8(sp)
  stfs REG_KnockbackY,Stack_MiscSpace+0xC(sp)
#Add vectors
  addi  r3,sp,Stack_MiscSpace+0x0
  addi  r4,sp,Stack_MiscSpace+0x8
  branchl r12,0x8000d4a0
#Unk
  addi  r3,sp,Stack_MiscSpace+0x0
  addi  r4,REG_ECBStruct,0x190
  branchl r12,0x8000dc6c
#Decay KB
  lwz	r3, -0x514C (r13)
  lfs	f1, 0x01BC (r3)
  lfs f2,Stack_MiscSpace+0x0(sp)
  lfs f3,Stack_MiscSpace+0x4(sp)
  fmuls REG_KnockbackX,f1,f2
  fmuls REG_KnockbackY,f1,f3
DIDraw_CollisionLoop_TouchingCeiling_GetColor:
#Get ceil color
  lwz r4,CeilingColor(REG_EventConstants)
  b DIDraw_CollisionLoop_GetColorEnd

DIDraw_CollisionLoop_TouchingWall:
#If grounded, dont run KB manip code
  cmpwi REG_GroundState,0
  beq DIDraw_CollisionLoop_TouchingWall_GetColor
#Get walls data
  lwz r3,0x134(REG_ECBStruct)
  rlwinm. r0,r3,0,0x20
  bne DIDraw_CollisionLoop_LeftWallsData
  rlwinm. r0,r3,0,0x40
  bne DIDraw_CollisionLoop_RightWallsData
DIDraw_CollisionLoop_RightWallsData:
  addi  REG_Temp,REG_ECBStruct,380
  b 0x8
DIDraw_CollisionLoop_LeftWallsData:
  addi  REG_Temp,REG_ECBStruct,360
#Self-Induced velocity
  lfs	f1, -0x750C (rtoc)
  stfs f1,Stack_MiscSpace+0x0(sp)
  stfs REG_Gravity,Stack_MiscSpace+0x4(sp)
#KB-Induced
  stfs REG_KnockbackX,Stack_MiscSpace+0x8(sp)
  stfs REG_KnockbackY,Stack_MiscSpace+0xC(sp)
#Add vectors
  addi  r3,sp,Stack_MiscSpace+0x0
  addi  r4,sp,Stack_MiscSpace+0x8
  branchl r12,0x8000d4a0
#Unk
  addi  r3,sp,Stack_MiscSpace+0x0
  mr  r4,REG_Temp
  branchl r12,0x8000dc6c
#Decay KB
  lwz	r3, -0x514C (r13)
  lfs	f1, 0x01BC (r3)
  lfs f2,Stack_MiscSpace+0x0(sp)
  lfs f3,Stack_MiscSpace+0x4(sp)
  fmuls REG_KnockbackX,f1,f2
  fmuls REG_KnockbackY,f1,f3
DIDraw_CollisionLoop_TouchingWall_GetColor:
  lwz r3,0x134(REG_ECBStruct)
  rlwinm. r0,r3,0,0x20
  bne DIDraw_CollisionLoop_TouchingLeftWall
  rlwinm. r0,r3,0,0x40
  bne DIDraw_CollisionLoop_TouchingRightWall
DIDraw_CollisionLoop_TouchingLeftWall:
  lwz r4,LeftWallColor(REG_EventConstants)
  b DIDraw_CollisionLoop_GetColorEnd
DIDraw_CollisionLoop_TouchingRightWall:
  lwz r4,RightWallColor(REG_EventConstants)
  b DIDraw_CollisionLoop_GetColorEnd

DIDraw_CollisionLoop_GetColorEnd:
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
  lfs f1,0x2340(REG_PlayerData)
  fctiwz  f1,f1
  stfd  f1,Stack_MiscSpace(sp)
  lwz  r3,Stack_MiscSpace+4(sp)
	cmpw	REG_LoopCount,r3
	blt	DIDraw_CollisionLoop
#End Loop
  branchl r12,prim.close

DIDraw_Exit:
  lmw  r20,Stack_BackedUpReg(r1)
  lwz r0, StackSize+4(r1)
  addi	r1,r1,StackSize	# release the space
  mtlr r0
  blr

####################################################
#endregion

Exit:
#Restore Interrupts
  mr  r3,REG_Interrupt
  branchl r12,0x8034738c
#Return
  restore
  mr	r3, r28
