#To be inserted at 800e7418
.include "../../Globals.s"

.set StackSize,0x300
.set Stack_BackedUpReg,0x8
  .set Stack_BackedUpReg_Length,0x2C
.set Stack_BackedUpFloats, (Stack_BackedUpReg+Stack_BackedUpReg_Length)
  .set Stack_BackedUpFloats_Length,0x14
.set Stack_ECBBoneStruct, (Stack_BackedUpFloats+Stack_BackedUpFloats_Length)
  .set Stack_ECBBoneStruct_Length,0x18
.set Stack_ECBStruct, (Stack_ECBBoneStruct+Stack_ECBBoneStruct_Length)
  .set Stack_ECBStruct_Length,0x1AC
.set Stack_MiscSpace, (Stack_ECBStruct+Stack_ECBStruct_Length)

.set  REG_P2Data,31
.set  REG_EventConstants,30

mflr r0
stw r0, 0x4(r1)
stwu	r1,-StackSize(r1)	# make space for 12 registers
stmw  r20,Stack_BackedUpReg(r1)

lwz REG_P2Data,0x2c(r3)
bl  ArmadaShineThink_Constants
mflr  REG_EventConstants

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

.set RandomAngleRange,20

#Get Per Frame Velocity
	lfs	REG_XComp,0x620(REG_P2Data)
	lfs	REG_YComp,0x624(REG_P2Data)
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
#Init Loop
	li	REG_LoopCount,0
#Change current CObj
  lwz	REG_CObjBackup, -0x4044 (r13)
  load  r3,0x80452C68
  lwz r3,0x0(r3)
  lwz r3,0x28(r3)
  branchl r12,0x80368458
#Init GX Prim
  lwz	r5, 0x02D4 (REG_P2Data)
  lfs	f1, 0x0068 (r5)
  fctiwz  f1,f1
  stfd  f1,-0x10(sp)
  lwz r3,-0x0C(sp)
  load  r4,0x00101306
  load  r5,0x00001455
  branchl r12,prim.new
  mr  REG_GX,r3
ArmadaShineThink_RecoverStart_CollisionLoop:
#Store current position
	stfs	REG_CurrXPos,0x1C(REG_ECBStruct)
	stfs	REG_CurrYPos,0x20(REG_ECBStruct)
#Check if frame X or greater
  lwz	r5, 0x02D4 (REG_P2Data)
  lfs f1,0x70(r5)
  fctiwz  f1,f1
  stfd  f1,-0x10(sp)
  lwz r3,-0x0C(sp)
	cmpw	REG_LoopCount,r3
	blt	ArmadaShineThink_RecoverStart_CollisionLoop_SkipDecay
ArmadaShineThink_RecoverStart_CollisionLoop_Decay:
	lfs	f1,0x78(r5)
	fmuls	f1,f1,REG_XComp
	lfs	f2, 0x002C (REG_P2Data)
	fmuls	f1,f1,f2
	fsubs	REG_XPerFrame,REG_XPerFrame,f1
	lfs	f1,0x78(r5)
	fmuls	f1,f1,REG_YComp
	fsubs	REG_YPerFrame,REG_YPerFrame,f1
ArmadaShineThink_RecoverStart_CollisionLoop_SkipDecay:
#Store next position
	fadds	f1,REG_CurrXPos,REG_XPerFrame
	stfs	f1,0x4(REG_ECBStruct)
	fadds	f1,REG_CurrYPos,REG_YPerFrame
	stfs	f1,0x8(REG_ECBStruct)
	lfs	f1,0x24(REG_ECBStruct)
	stfs	f1,0xC(REG_ECBStruct)
	mr	r3,REG_ECBStruct
	mr	r4,REG_ECBBoneStruct
	branchl	r12,0x8004730c
	lfs	REG_CurrXPos,0x4(REG_ECBStruct)
	lfs	REG_CurrYPos,0x8(REG_ECBStruct)
#Draw this point
  lfs f1,0x84(REG_ECBStruct)
  fadds f1,REG_CurrXPos,f1
  lfs f2,0x88(REG_ECBStruct)
  fadds f2,REG_CurrYPos,f2
  li  r3,0
  stw r3,Stack_MiscSpace(sp)
  lfs f3,Stack_MiscSpace(sp)
  load  r4,0x4B75FFFF
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
  stfd  f1,-0x10(sp)
  lwz r3,-0x0C(sp)
	cmpw	REG_LoopCount,r3
	blt	ArmadaShineThink_RecoverStart_CollisionLoop
#End Loop
  branchl r12,prim.close
  mr  r3,REG_CObjBackup
  branchl r12,0x80368458
#endregion
  Exit:
  lmw  r20,Stack_BackedUpReg(r1)
  lwz r0, StackSize+4(r1)
  addi	r1,r1,StackSize	# release the space
  mtlr r0
  blr



ArmadaShineThink_Constants:
blrl

.set	ECB_TopY,0x0 #scale * value
.set	ECB_BottomY,0x4 #neg(scale * vlaue)
.set	ECB_LeftX,0x8 #neg(scale * vlaue)
.set	ECB_LeftY,0xC #0
.set	ECB_RightX,0x10 #scale * value
.set	ECB_RightY,0x14 #0
.set	FinalAnimYDifference,0x18
.float 9
.float 2.5
.float -3.3
.float 5.7
.float 3.3
.float 5.7
.float 0.4
