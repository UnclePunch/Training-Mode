#To be inserted at 8016e5a8
.include "../../Globals.s"


CreateProc:
.set  REG_Data,31
.set  REG_GObj,30

backup

#Create GObj
  li	r3,4	    	#GObj Type (4 is the player type, this should ensure it runs before any player animations)
  li	r4,0	  	  #On-Pause Function (dont run on pause)
  li	r5,0        #object priority
  branchl	r12,GObj_Create
  mr  REG_GObj,r3

#Alloc Mem
  li  r3,32
  branchl r12,HSD_MemAlloc
  mr  REG_Data,r3

#Zero Data
  mr  r3,REG_Data
  li  r4,32
  branchl r12,ZeroAreaLength

#Attach Data
  mr  r3,REG_GObj
  li  r4,14
  load r5,HSD_Free
  mr  r6,REG_Data
  branchl r12,GObj_AddUserData

#Create Proc
  bl  KillZoomThink
  mflr r4         #Function
  li  r5,14       #Priority
  branchl	r12,GObj_AddProc

b CreateProc_Exit

#############################################################
KillZoomThink:
blrl

.set  REG_GObjData,31
.set  REG_PlayerData,30
.set  REG_PlayerGObj,29
.set  REG_Constants,28

#Init
  backup
  lwz REG_GObjData,0x2C(r3)
  bl  Constants
  mflr  REG_Constants

#Ensure match type is stock
  branchl r12,0x8016ae50
  lbz r0,0x4(r3)
  rlwinm. r0,r0,0,0x20
  bne KillZoomThink_IsStock
  branchl r12,0x8016b094
  cmpwi r3,0
  beq KillZoomThink_Exit

KillZoomThink_IsStock:
#Check if currently zooming
  load  r3,0x80452c68
  lwz r0,0x4(r3)
  cmpwi r0,6
  bne LoopThroughPlayers_GetFirstPlayer
#Decrement Freeze Timer
  lwz r3,0x0(REG_GObjData)
  subi  r3,r3,1
  stw r3,0x0(REG_GObjData)
  cmpwi r3,0
  bgt KillZoomThink_Exit
#Resume Game Speed
  li  r3,1
  branchl r12,0x801a4674
#Restore camera to normal
  branchl r12,0x8015cc14
  b KillZoomThink_Exit
#Loop through all players
LoopThroughPlayers_GetFirstPlayer:
  lwz	r3, -0x3E74 (r13)
  lwz	REG_PlayerGObj, 0x0020 (r3)
  b	LoopThroughPlayers_CheckIfPlayerExists
LoopThroughPlayers_GetNextPlayer:
  lwz	REG_PlayerGObj,0x8(REG_PlayerGObj)
LoopThroughPlayers_CheckIfPlayerExists:
  cmpwi	REG_PlayerGObj,0x0
  beq	KillZoomThink_Exit
  lwz	REG_PlayerData,0x2C(REG_PlayerGObj)

#Ensure not in sleep
  lbz	r3, 0x221F(REG_PlayerData)
  rlwinm. r0,r3,0,0x10
  bne LoopThroughPlayers_GetNextPlayer
#Ensure not a follower
  rlwinm.	r0, r3, 29, 31, 31
  beq	FollowerSkip
#Check If Follower
  lbz r3,0xC(REG_PlayerData)
  branchl r12, PlayerBlock_LoadExternalCharID
  load	r4,0x803bcde0			   #pdLoadCommonData table
  mulli	r0, r3, 3			       #struct length
  add	r3,r4,r0			         #get characters entry
  lbz	r0, 0x2(r3)			     #get subchar functionality
  cmpwi	r0,0x0			         #if a follower, exit
  beq	LoopThroughPlayers_GetNextPlayer
FollowerSkip:
#Check if in hitstun
  lbz	r3, 0x221C(REG_PlayerData)
  rlwinm. r0,r3,0,0x2
  beq LoopThroughPlayers_GetNextPlayer
#Check if in hitlag
  lbz	r3, 0x221A(REG_PlayerData)
  rlwinm. r0,r3,0,0x20
  beq LoopThroughPlayers_GetNextPlayer
#Check if last frame of hitlag
	lfs	f1,-0x7418(rtoc)		          #1fp
	lfs	f2,0x195C(REG_PlayerData)		  #hitlag frames left
	fcmpo	cr0,f1,f2
	bne	LoopThroughPlayers_GetNextPlayer
#Check if will die from this hit
  mr  r3,REG_PlayerData
  bl  DIDraw
  cmpwi r3,0
  beq LoopThroughPlayers_GetNextPlayer
#Check if last stock
  lbz r3,0xC(REG_PlayerData)
  branchl r12,PlayerBlock_LoadStocksLeft
  cmpwi r3,1
  beq KillZoomThink_KOZoom
  b KillZoomThink_KOFlash

KillZoomThink_KOZoom:
.set  ZoomInFrames,6
.set  FreezeFrames,ZoomInFrames+20

#Zoom in on this player
  lwz r3,0x10B0(REG_PlayerData)
  stw r3,0x80(sp)
  lwz r3,0x10B4(REG_PlayerData)
  stw r3,0x84(sp)
  lwz r3,0x10B8(REG_PlayerData)
  stw r3,0x88(sp)
  addi  r3,sp,0x80
  lwz r4,0x1868(REG_PlayerData)
  cmpwi r4,0x0
  beq KillZoomThink_HitByNonPlayer
  lhz r5,0x0(r4)
  cmpwi r5,0x4
  beq  KillZoomThink_HitByPlayer
#Just use the victims sphere
KillZoomThink_HitByNonPlayer:
  addi  r3,sp,0x80
  b KillZoomThink_ZoomInOnCoordinates
KillZoomThink_HitByPlayer:
  lwz r4,0x2C(r4)
  addi  r4,r4,0x10B0
  branchl r12,0x8000d46c      #Add vectors
  lfs f1,Divisor(REG_Constants)
  lfs f2,0x80(sp)
  fdivs f2,f2,f1
  stfs  f2,0x80(sp)
  lfs f2,0x84(sp)
  fdivs f2,f2,f1
  stfs  f2,0x84(sp)
  lfs f2,0x88(sp)
  fdivs f2,f2,f1
  stfs  f2,0x88(sp)
  addi  r3,sp,0x80
KillZoomThink_ZoomInOnCoordinates:
#Set coordinates
  branchl r12,0x8002e818
#Adjust Zoom value
  lfs f1,ZoomValue(REG_Constants)
  stfs  f1,0x88(sp)
  addi  r3,sp,0x80
  branchl r12,0x8002ea64
#Adjust frames to zoom in
  li  r3,ZoomInFrames
  branchl r12,0x8002f0e4
#Set Freeze Frames
  li  r3,FreezeFrames
  stw r3,0x0(REG_GObjData)
#Freeze Game
  li  r3,1
  branchl r12,0x801a4634
#Play SFX
  li  r3,0xDF
  branchl r12,SFX_PlaySoundAtFullVolume
#Spawn GFX
  lwz r3,0x0(REG_PlayerData)
  li  r4,0x1b3
  li  r5,3
  li  r6,0
  li  r7,0
  addi  r8,sp,0x80
  addi  r9,sp,0x8C
#Setup stack
  li r0,0
  stw r0,0x0(r8) #z scatter
  stw r0,0x4(r8) #y scatter
  stw r0,0x8(r8) #z scatter
  li r0,0
  stw r0,0x0(r9) #X offset
  stw r0,0x4(r9) #y offset
  stw r0,0x8(r9) #z offset
  branchl r12,0x8009f834
#Spawn GFX
  lwz r3,0x0(REG_PlayerData)
  li  r4,0xd5
  li  r5,3
  li  r6,0
  li  r7,0
  addi  r8,sp,0x80
  addi  r9,sp,0x8C
#Setup stack
  li r0,0
  stw r0,0x0(r8) #z scatter
  stw r0,0x4(r8) #y scatter
  stw r0,0x8(r8) #z scatter
  li r0,0
  stw r0,0x0(r9) #X offset
  stw r0,0x4(r9) #y offset
  stw r0,0x8(r9) #z offset
  branchl r12,0x8009f834
  b KillZoomThink_Exit

KillZoomThink_KOFlash:
#Play SFX
  li  r3,0x122 #12a #122 #0xff
  branchl r12,SFX_PlaySoundAtFullVolume
#Spawn GFX
  lwz r3,0x0(REG_PlayerData)
  li  r4,0x8e
  li  r5,3
  li  r6,0
  li  r7,0
  addi  r8,sp,0x80
  addi  r9,sp,0x8C
#Setup stack
  li r0,0
  stw r0,0x0(r8) #z scatter
  stw r0,0x4(r8) #y scatter
  stw r0,0x8(r8) #z scatter
  li r0,0
  stw r0,0x0(r9) #X offset
  stw r0,0x4(r9) #y offset
  stw r0,0x8(r9) #z offset
  branchl r12,0x8009f834
#Spawn GFX
  lwz r3,0x0(REG_PlayerData)
  li  r4,0x1e4
  li  r5,3
  li  r6,0
  li  r7,0
  addi  r8,sp,0x80
  addi  r9,sp,0x8C
#Setup stack
  li r0,0
  stw r0,0x0(r8) #z scatter
  stw r0,0x4(r8) #y scatter
  stw r0,0x8(r8) #z scatter
  li r0,0
  stw r0,0x0(r9) #X offset
  stw r0,0x4(r9) #y offset
  stw r0,0x8(r9) #z offset
  branchl r12,0x8009f834

KillZoomThink_Exit:
  restore
  blr

#region DI Draw
DIDraw_Constants:
blrl

.set	ECB_TopY,0x0 #scale * value
.set	ECB_BottomY,0x4 #neg(scale * vlaue)
.set	ECB_LeftX,0x8 #neg(scale * vlaue)
.set	ECB_LeftY,0xC #0
.set	ECB_RightX,0x10 #scale * value
.set	ECB_RightY,0x14 #0
.set  FirefoxDrawZ,0x18
.set  AliveLineColor,0x1C
.set  DeadLineColor,0x20
.set  LeftWallColor,0x24
.set  RightWallColor,0x28
.set  CeilingColor,0x2C
.set  GroundColor,0x30
.set  ASDIColor,0x34
.float 9
.float 2.5
.float -3.3
.float 5.7
.float 3.3
.float 5.7
.float 10
.byte 0, 138, 255, 255
.byte 255, 55, 55, 255
.byte 12, 255, 41, 255
.byte 12, 255, 41, 255
.byte 255, 0, 255, 255
.byte 255, 255, 255, 255
.byte 255, 86, 20, 255

.set StackSize,0x300
.set Stack_BackedUpReg,0x8
  .set Stack_BackedUpReg_Length,0x30
.set Stack_BackedUpFloats, (Stack_BackedUpReg+Stack_BackedUpReg_Length)
  .set Stack_BackedUpFloats_Length,0x14
.set Stack_ECBBoneStruct, (Stack_BackedUpFloats+Stack_BackedUpFloats_Length)
  .set Stack_ECBBoneStruct_Length,0x18
.set Stack_ECBStruct, (Stack_ECBBoneStruct+Stack_ECBBoneStruct_Length)
  .set Stack_ECBStruct_Length,0x1AC
.set Stack_ASDIBackup, (Stack_ECBStruct+Stack_ECBStruct_Length)
  .set  Stack_ASDIBackup_Length,0x8
.set Stack_MiscSpace, (Stack_ASDIBackup+Stack_ASDIBackup_Length)

#gprs
.set REG_EventConstants,31
.set REG_PlayerData,30
.set REG_ECBStruct,20
.set REG_ECBBoneStruct,21
.set REG_LoopCount,22
.set REG_GX,23
.set REG_HeldInputs,24
.set REG_GroundState,24
.set REG_CollisionInfo,25
.set REG_Temp,26            #this register is used for the draw loop, make sure to change both
.set REG_OverrideRemainingFrames,27

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
.set REG_CStickX,22
.set REG_CStickY,21
.set REG_ASDIX,22
.set REG_ASDIY,21
.set REG_Gravity,30

#constants
.set MaxColl,40

DIDraw:
  mflr r0
  stw r0, 0x4(r1)
  stwu	r1,-StackSize(r1)	# make space for 12 registers
  stmw  r20,Stack_BackedUpReg(r1)

#backup
  mr  REG_PlayerData,r3

#Get Floats
  bl  DIDraw_Constants
  mflr  REG_EventConstants

#region GetInputs
DIDraw_PBInputs:
	lfs	REG_XComp,0x620(REG_PlayerData)
	lfs	REG_YComp,0x624(REG_PlayerData)
  lwz REG_HeldInputs,0x65C(REG_PlayerData)
	lfs	REG_CStickX,0x638(REG_PlayerData)
	lfs	REG_CStickY,0x63C(REG_PlayerData)
#endregion

#Get original KB vector
  lfs REG_KnockbackX,0x8C(REG_PlayerData)
  lfs REG_KnockbackY,0x90(REG_PlayerData)

#Calculate player's influence over trajectory
#region GetArctan
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
#endregion
#region CalculateASDI
DIDraw_CalculateASDI:
#CStick has priority
#Check if cstick magnitude > 0.7
  fmuls f1,REG_CStickX,REG_CStickX
  fmuls f0,REG_CStickY,REG_CStickY
  lwz	r3, -0x514C (r13)
  lfs	f2, 0x04B0 (r3)
  fadds	f1,f1,f0
  fmuls	f0,f2,f2
  fcmpo	cr0,f1,f0
  bge DIDraw_CalculateASDICStickApply
#Now check left stick
  fmuls f1,REG_YComp,REG_YComp
  fmuls f2,REG_XComp,REG_XComp
  lwz	r3, -0x514C (r13)
  lfs	f0, 0x04B0 (r3)
  fmuls f0,f0,f0
  fadds f1,f1,f2
  fcmpo cr0,f1,f0
  blt  DIDraw_CalculateASDINone
DIDraw_CalculateASDILeftStickApply:
#Multiply by 3
  lfs	f1, 0x04BC (r3)
  fmuls REG_ASDIX,REG_XComp,f1
  fmuls REG_ASDIY,REG_YComp,f1
  b DIDraw_CalculateASDIEnd
DIDraw_CalculateASDINone:
#Null ASDI
  lfs	REG_ASDIX, -0x750C (rtoc)
  lfs	REG_ASDIY, -0x750C (rtoc)
  b DIDraw_CalculateASDIEnd
DIDraw_CalculateASDICStickApply:
#Multiply by 3
  lfs	f1, 0x04BC (r3)
  fmuls REG_ASDIX,REG_CStickX,f1
  fmuls REG_ASDIY,REG_CStickY,f1
DIDraw_CalculateASDIEnd:
#Save these values for later
  stfs  REG_ASDIX,Stack_ASDIBackup+0(sp)
  stfs  REG_ASDIY,Stack_ASDIBackup+4(sp)
#endregion
#region CalculateKBReduction
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
#endregion
#region CalculateDI
DIDraw_CalculateDI:
#If grounded, skip DI
  lwz r3,0xE0(REG_PlayerData)
  cmpwi r3,0
  beq DIDraw_CalculateDIEnd
#If both inputting nothing, skip DI
  lfs	f1, -0x750C (rtoc)
  fcmpo cr0,f1,REG_XComp
  bne DIDraw_IsInputting
  fcmpo cr0,f1,REG_YComp
  beq DIDraw_CalculateDIEnd
DIDraw_IsInputting:
#If some condition is met, skip DI
  lfs	f0, -0x74E8 (rtoc)
  fneg  f1,REG_KnockbackX
  fmuls f1,f1,f1
  fmuls f2,REG_KnockbackY,REG_KnockbackY
  fadds f1,f1,f2
  fcmpo cr0,f1,f0
  blt DIDraw_CalculateDIEnd
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
#Apply new angle
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
DIDraw_CalculateDIEnd:
#endregion

#Perform collision checks for each frame of hitstun
#region DIDraw_Collision

#region DIDraw_CollisionLoop_Init
DIDraw_CollisionLoop_Init:
#Create an ECB struct on the stack
	addi	REG_ECBBoneStruct,sp,Stack_ECBBoneStruct
	addi	REG_ECBStruct,sp,Stack_ECBStruct
	mr	r3,REG_ECBStruct
	branchl	r12,0x80041ee4
#Get Current XY
	lfs	REG_CurrXPos,0xB0(REG_PlayerData)
	lfs	REG_CurrYPos,0xB4(REG_PlayerData)
#Init Loop
	li	REG_LoopCount,0
  lfs REG_Gravity,-0x750C (rtoc)
  lwz  REG_GroundState,0xE0(REG_PlayerData)
  li  REG_OverrideRemainingFrames,0
#Allocate collision info struct
  lfs f1,0x2340(REG_PlayerData)
  fctiwz  f1,f1
  stfd  f1,Stack_MiscSpace(sp)
  lwz  r3,Stack_MiscSpace+4(sp)
  mulli r3,r3,CollInfo_Length       #backing up X bytes per collision check
  addi  r3,r3,0x4        #small header containing the amount of collision checks
  branchl r12,HSD_MemAlloc
  mr  REG_CollisionInfo,r3
#Init collision info struct
  li  r3,-1               #init as 0 checks
  stw r3,0x0(REG_CollisionInfo)
#If grounded, copy over ground ECB data
  cmpwi REG_GroundState,0
  bne DIDraw_DrawTrajectory_SkipCopyGroundData
  addi  r3,REG_ECBStruct,0x130
  addi  r4,REG_PlayerData,0x820
  li  r5,0x28
  branchl r12,memcpy
DIDraw_DrawTrajectory_SkipCopyGroundData:
#endregion
#region DIDraw_CollisionLoop_Start
DIDraw_CollisionLoop:

#region Initalize ECB Bone Positions
#Create ECB Bone struct
#If loop count < noECBUpdate-remaining hitlag fraes, use current ECB bottom Y offset
  lwz r3,0x88C(REG_PlayerData)
  lfs f1,0x195C(REG_PlayerData)
  fctiwz  f1,f1
  stfd  f1,Stack_MiscSpace(sp)
  lwz r4,Stack_MiscSpace+0x4(sp)
  sub r3,r3,r4
  cmpw  REG_LoopCount,r3
  blt DIDraw_CollisionLoop_ECBBonesUseCurrent
#Copy Struct
	mr	r3,REG_ECBBoneStruct
	addi	r4,REG_EventConstants,ECB_TopY
	li	r5,0x18
	branchl	r12,memcpy
#If the player is grounded, ECB bottom is 0
  cmpwi REG_GroundState,0
  bne DIDraw_CollisionLoop_ECBBonesEnd
  lfs	f1, -0x750C (rtoc)
  stfs f1,0x04(REG_ECBBoneStruct)
  b DIDraw_CollisionLoop_ECBBonesEnd
DIDraw_CollisionLoop_ECBBonesUseCurrent:
#Use Current Bone Positions
  lfs f1,0x778(REG_PlayerData)
  stfs f1,0x00(REG_ECBBoneStruct)
  lfs f1,0x780(REG_PlayerData)
  stfs f1,0x04(REG_ECBBoneStruct)
  lfs f1,0x78C(REG_PlayerData)
  stfs f1,0x08(REG_ECBBoneStruct)
  lfs f1,0x790(REG_PlayerData)
  stfs f1,0x0C(REG_ECBBoneStruct)
  lfs f1,0x784(REG_PlayerData)
  stfs f1,0x10(REG_ECBBoneStruct)
  lfs f1,0x788(REG_PlayerData)
  stfs f1,0x14(REG_ECBBoneStruct)
  b DIDraw_CollisionLoop_ECBBonesEnd
DIDraw_CollisionLoop_ECBBonesEnd:
#Store current position
  lfs	f1, -0x750C (rtoc)
	stfs	REG_CurrXPos,0x4(REG_ECBStruct)
	stfs	REG_CurrYPos,0x8(REG_ECBStruct)
  stfs	f1,0xC(REG_ECBStruct)
	stfs	REG_CurrXPos,0x10(REG_ECBStruct)
	stfs	REG_CurrYPos,0x14(REG_ECBStruct)
  stfs	f1,0x18(REG_ECBStruct)
#endregion

#region Apply ASDI
DIDraw_CollisionLoop_ApplyASDI:
#Apply ASDI X
  fadds REG_CurrXPos,REG_CurrXPos,REG_ASDIX
#Only apply ASDI Y if in the air
  cmpwi REG_GroundState,0
  beq 0x8
  fadds REG_CurrYPos,REG_CurrYPos,REG_ASDIY
#Null ASDI
  lfs	REG_ASDIX, -0x750C (rtoc)
  lfs	REG_ASDIY, -0x750C (rtoc)
#endregion

#region Decay Knockback
#Apply either gravity or traction
  cmpwi REG_GroundState,1
  bne DIDraw_CollisionLoop_DecayGrounded
DIDraw_CollisionLoop_DecayAerial:
#Account for gravity
  lfs	f1, 0x016C (REG_PlayerData)
  lfs	f2, 0x0170 (REG_PlayerData)
  fneg  f2,f2
  fsubs REG_Gravity,REG_Gravity,f1
  fcmpo	cr0,REG_Gravity,f2
  bge 0x8
  fmr REG_Gravity,f2
#Decay KB Vector
  fmr f1,REG_KnockbackY
  fmr f2,REG_KnockbackX
  branchl r12,0x80022c30    #Get arctan of the KB vector
  fmr  REG_arctan,f1
#Decay X KB
  branchl r12,cos
  lwz	r3, -0x514C (r13)
  lfs	f2, 0x0204 (r3)
  fnmsubs	REG_KnockbackX,f2,f1,REG_KnockbackX
#Decay Y KB
  fmr f1,REG_arctan
  branchl r12,sin
  lwz	r3, -0x514C (r13)
  lfs	f2, 0x0204 (r3)
  fnmsubs	REG_KnockbackY,f2,f1,REG_KnockbackY
  b DIDraw_CollisionLoop_DecayEnd
DIDraw_CollisionLoop_DecayGrounded:
#Get Ground Friction's multipllier
  lwz r3,0x4(REG_PlayerData)
  cmpwi r3,Popo.Int
  beq DIDraw_CollisionLoop_DecayGrounded_isICs
  cmpwi r3,Nana.Int
  beq DIDraw_CollisionLoop_DecayGrounded_isICs
#Get grounds friction multiplier
  lfs	f1, -0x7A38 (rtoc)
  lwz	r0, 0x014C (REG_ECBStruct)
  cmpwi r0,-1
  beq DIDraw_CollisionLoop_DecayGrounded_isICs
  lwz r3,0x150(REG_ECBStruct)
  branchl r12,0x800569ec    #Get ground's friction multiplier
  b 0x8
DIDraw_CollisionLoop_DecayGrounded_isICs:
  lfs	f1, -0x7A38 (rtoc)
#Account for friction
  lfs	f0, 0x128 (REG_PlayerData)
  fmuls	f1,f0,f1
  lwz	r4, -0x514C (r13)
  lfs	f0, 0x0200 (r4)
  fmuls f0,f1,f0
#Apply Friction to knockback
  lfs	f2, -0x76B0 (rtoc)
  fcmpo cr0,REG_KnockbackX,f2
  bge DIDraw_CollisionLoop_DecayGrounded_Subtract
  fadds f0,f0,REG_KnockbackX
  fmr REG_KnockbackX,f0
  fcmpo cr0,f0,f2
  ble DIDraw_CollisionLoop_DecayGroundedEnd
  fmr REG_KnockbackX,f2
  b DIDraw_CollisionLoop_DecayGroundedEnd
DIDraw_CollisionLoop_DecayGrounded_Subtract:
  fsubs	f0,REG_KnockbackX,f0
  fmr REG_KnockbackX,f0
  fcmpo cr0,f0,f2
  bge DIDraw_CollisionLoop_DecayGroundedEnd
  fmr REG_KnockbackX,f2
  b DIDraw_CollisionLoop_DecayGroundedEnd
DIDraw_CollisionLoop_DecayGroundedEnd:
DIDraw_CollisionLoop_DecayEnd:
#endregion

#region Shift Positions
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
#endregion

#region Run Collision Check

.if MaxColl>=0
#Only run X collision checks because theyre expensive
  cmpwi REG_LoopCount,MaxColl
  blt DIDraw_CollisionLoop_DetermineCollision
#Spoof as not touching anything
  li  r3,0
  stw r3,0x134(REG_ECBStruct)
	lfs	REG_CurrXPos,0x4(REG_ECBStruct)
	lfs	REG_CurrYPos,0x8(REG_ECBStruct)
#If grounded and max collision checks, just stop updating position
  cmpwi REG_GroundState,0
  bne  DIDraw_CollisionLoop_StageBehaviorEnd
  li  REG_OverrideRemainingFrames,1
  b DIDraw_CollisionLoop_StageBehaviorEnd
.endif

DIDraw_CollisionLoop_DetermineCollision:
#Run collision
  cmpwi REG_GroundState,1
  beq DIDraw_CollisionLoop_AerialCollision
DIDraw_CollisionLoop_GroundCollision:
#Grounded Collision
	mr	r3,REG_ECBStruct
	mr	r4,REG_ECBBoneStruct
	branchl	r12,0x8004b21c
  xori  REG_GroundState,r3,0x1
  b DIDraw_CollisionLoop_CollisionEnd
DIDraw_CollisionLoop_AerialCollision:
#Aerial Collision
	mr	r3,REG_ECBStruct
	mr	r4,REG_ECBBoneStruct
	branchl	r12,0x800475f4
DIDraw_CollisionLoop_CollisionEnd:
#endregion

#region Stage Collision Behavior
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
  b DIDraw_CollisionLoop_StageBehaviorEnd

#region Touching Ground
DIDraw_CollisionLoop_TouchingGround:
#If grounded, dont run KB manip code
  cmpwi REG_GroundState,0
  beq DIDraw_CollisionLoop_StageBehaviorEnd
/*
#End check
  li  REG_OverrideRemainingFrames,1
*/
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
#REMOVE ALL Y KB?
  lfs	REG_KnockbackY, -0x750C (rtoc)
#Set as grounded
  li  REG_GroundState,0
  b DIDraw_CollisionLoop_StageBehaviorEnd
#endregion
#region Touching Ceiling
DIDraw_CollisionLoop_TouchingCeiling:
#If grounded, dont run KB manip code
  cmpwi REG_GroundState,0
  beq DIDraw_CollisionLoop_StageBehaviorEnd
#End check
  li  REG_OverrideRemainingFrames,1
/*
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
*/
  b DIDraw_CollisionLoop_StageBehaviorEnd
#endregion
#region Touching Wall
DIDraw_CollisionLoop_TouchingWall:
#If grounded, dont run KB manip code
  cmpwi REG_GroundState,0
  beq DIDraw_CollisionLoop_StageBehaviorEnd
#End check
  li  REG_OverrideRemainingFrames,1
/*
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
  lfs	REG_Gravity, -0x6DA0 (rtoc)
*/
  b DIDraw_CollisionLoop_StageBehaviorEnd
#endregion
DIDraw_CollisionLoop_StageBehaviorEnd:
#endregion

#region Ground to Air Check
.if MaxColl>=0
DIDraw_CollisionLoop_GroundToAirCheck:
.set  GroundToAirRemainingFrames,5
#Ensure not touching ground this frame
  lwz r3,0x134(REG_ECBStruct)
  rlwinm. r0,r3,0,0x8000
  bne DIDraw_CollisionLoop_GroundToAirCheckEnd
#Ensure was touching ground last frame
  lwz r3,0x138(REG_ECBStruct)
  rlwinm. r0,r3,0,0x8000
  beq DIDraw_CollisionLoop_GroundToAirCheckEnd
#End check
  li  REG_OverrideRemainingFrames,1
/*
#Check if over MaxColl
  cmpwi REG_LoopCount,MaxColl
  blt DIDraw_CollisionLoop_GroundToAirCheckEnd
#Check if REG_OverrideRemainingFrames is already set
  cmpwi REG_OverrideRemainingFrames,0
  bgt DIDraw_CollisionLoop_GroundToAirCheckEnd
#Set REG_OverrideRemainingFrames
  li  REG_OverrideRemainingFrames,GroundToAirRemainingFrames
*/
DIDraw_CollisionLoop_GroundToAirCheckEnd:
.endif
#endregion

#region Save Collision Info
.set  CollInfo_Length,0x18
.set  CollInfo_XPos,0x0
.set  CollInfo_YPos,0x4
.set  CollInfo_EnvBitfield,0x8
.set  CollInfo_ECBTopY,0xC
.set  CollInfo_ECBLeftY,0x10
.set  CollInfo_KnockbackY,0x14
#Update collision check count
  stw REG_LoopCount,0x0(REG_CollisionInfo)
#Get this frames offset in info struct
  addi  r3,REG_CollisionInfo,0x4    #skip past header
  mulli r4,REG_LoopCount,CollInfo_Length
  add r3,r3,r4
#Store data
  stfs  REG_CurrXPos,CollInfo_XPos(r3)
  stfs  REG_CurrYPos,CollInfo_YPos(r3)
  lwz r4,0x134(REG_ECBStruct)
  stw  r4,CollInfo_EnvBitfield(r3)
  lfs f1,0x88(REG_ECBStruct)
  stfs  f1,CollInfo_ECBTopY(r3)
  lfs f1,0xA0(REG_ECBStruct)
  stfs  f1,CollInfo_ECBLeftY(r3)
  stfs  REG_KnockbackY,CollInfo_KnockbackY(r3)
#endregion

DIDraw_CollisionLoop_IncLoop:
#Check override frames first
  cmpwi REG_OverrideRemainingFrames,0
  ble DIDraw_CollisionLoop_IncLoopNoOverride
#Decrement override frames
  subi  REG_OverrideRemainingFrames,REG_OverrideRemainingFrames,1
  cmpwi REG_OverrideRemainingFrames,0
  bgt DIDraw_CollisionLoop_IncLoopNoOverride
#Override and exit loop prematurely
  b DIDraw_CollisionLoop_IncLoopEnd
DIDraw_CollisionLoop_IncLoopNoOverride:
#Inc Loop
	addi	REG_LoopCount,REG_LoopCount,1
#Check if non-meteor cancellable
  lbz r3,0x235A(REG_PlayerData)
  cmpwi r3,1
  bne DIDraw_CollisionLoop_IncLoopCheckHitstunFrames
  lwz	r3, -0x514C (r13)
  lwz	r3, 0x07F0 (r3)
  cmpw  REG_LoopCount,r3
  bgt DIDraw_CollisionLoop_IncLoopEnd
DIDraw_CollisionLoop_IncLoopCheckHitstunFrames:
  lfs f1,0x2340(REG_PlayerData)
  fctiwz  f1,f1
  stfd  f1,Stack_MiscSpace(sp)
  lwz  r3,Stack_MiscSpace+4(sp)
	cmpw	REG_LoopCount,r3
	blt	DIDraw_CollisionLoop
DIDraw_CollisionLoop_IncLoopEnd:
/*
.if MaxColl>=0
#Output collision checks count
  bl  DIDraw_CollisionLoop_Text
  mflr  r3
  lwz r4,TM_GameFrameCounter(r13)
  mr  r5,REG_LoopCount
  branchl r12,OSReport
  b DIDraw_CollisionLoop_TextEnd
DIDraw_CollisionLoop_Text:
blrl
.string "frame %d performed %d collision checks\n"
.align 2
DIDraw_CollisionLoop_TextEnd:
.endif
*/
#endregion
#endregion

#region DIDraw_DeathCheck
DIDraw_DrawLoop_Init:
.set REG_DeathLoopCount,28
  li  REG_DeathLoopCount,0
DIDraw_DrawLoop_Init_DeathLoop:
  addi  r3,REG_CollisionInfo,0x4
  mulli r4,REG_DeathLoopCount,CollInfo_Length
  add  r3,r3,r4                     #get last frames info
  lfs REG_CurrXPos,CollInfo_XPos(r3)
  lfs REG_CurrYPos,CollInfo_YPos(r3)
  lfs REG_KnockbackY,CollInfo_KnockbackY(r3)
  branchl r12,0x80224b38            #right blastzone
  fcmpo cr0,REG_CurrXPos,f1
  bgt DIDraw_DrawLoop_Init_Dead
  branchl r12,0x80224b50            #left blastzone
  fcmpo cr0,REG_CurrXPos,f1
  blt DIDraw_DrawLoop_Init_Dead
  branchl r12,0x80224b80            #bottom blastzone
  fcmpo cr0,REG_CurrYPos,f1
  blt DIDraw_DrawLoop_Init_Dead
  branchl r12,0x80224b68            #top blastzone
  fcmpo cr0,REG_CurrYPos,f1
  ble DIDraw_DrawLoop_Init_DeathLoop_Inc
  cmpwi REG_GroundState,0
  beq DIDraw_DrawLoop_Init_Dead
  lwz	r3, -0x514C (r13)
  lfs	f0, 0x04F0 (r3)
  fcmpo cr0,REG_KnockbackY,f0
  ble DIDraw_DrawLoop_Init_DeathLoop_Inc
DIDraw_DrawLoop_Init_Dead:
  li  r3,1
  b DIDraw_DrawLoop_Init_DeathLoop_Exit
DIDraw_DrawLoop_Init_DeathLoop_Inc:
  addi  REG_DeathLoopCount,REG_DeathLoopCount,1
  lwz r3,0x0(REG_CollisionInfo)
  cmpw  REG_DeathLoopCount,r3
  blt DIDraw_DrawLoop_Init_DeathLoop
#Is alive, make blue
  li  r3,0
DIDraw_DrawLoop_Init_DeathLoop_Exit:
#endregion

DIDraw_Exit:
  lmw  r20,Stack_BackedUpReg(r1)
  lwz r0, StackSize+4(r1)
  addi	r1,r1,StackSize	# release the space
  mtlr r0
  blr

####################################################
#endregion

Constants:
blrl
.set  ZoomValue,0x0
.set  Divisor,0x4
.float 100
.float 2

CreateProc_Exit:
  restore
  lmw	r24, 0x0038 (sp)
