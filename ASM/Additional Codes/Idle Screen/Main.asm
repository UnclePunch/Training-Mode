#To be inserted at 80302788
.include "../../Globals.s"

.set  IdleThreshold, (3*60) * 60

.set  REG_DevelopText,31
.set  REG_GObjData,30
.set  REG_GObj,29
.set  REG_Floats,28

backup

  bl  Floats
  mflr  REG_Floats

#Create Rectangle
  li  r3,32
  branchl r12,HSD_MemAlloc
  mr  r8,r3
  li  r3,20
  li  r4,-25
  li  r5,-25
  li  r6,1
  li  r7,1
  branchl r12,DevelopText_CreateDataTable
  mr  REG_DevelopText,r3
#Activate Text
  lwz	r3, -0x4884 (r13)
  mr  r4,REG_DevelopText
  branchl r12,DevelopText_Activate
#Hide blinking cursor
  li  r3,0
  stb r3,0x26(REG_DevelopText)
#Change BG Color
  mr  r3,REG_DevelopText
  addi  r4,REG_Floats,TextBG
  branchl r12,DevelopText_StoreBGColor
#Hide Filter
  mr  r3,REG_DevelopText
  branchl r12,DevelopText_HideBG
#Set Stretch
  lfs f1,TextScale_X(REG_Floats)
  stfs f1,0x8(REG_DevelopText)
  lfs f1,TextScale_Y(REG_Floats)
  stfs f1,0xC(REG_DevelopText)
#Create Background GObj
  li  r3,0
  li  r4,0
  li  r5,0
  branchl r12,GObj_Create
  mr  REG_GObj,r3
#Allocate Space
	li	r3,64
	branchl r12,HSD_MemAlloc
	mr	REG_GObjData,r3
#Zero
	li	r4,64
	branchl r12,ZeroAreaLength
#Initialize
	mr	r6,REG_GObjData
	mr	r3,REG_GObj
	li	r4,4
	load	r5,HSD_Free
	branchl r12,GObj_AddUserData
#Add Process
	mr	r3,REG_GObj
	bl	IdleThink
	mflr r4
	li	r5,0
  branchl r12,GObj_AddProc
#Store pointer to dev text
  stw REG_DevelopText,0x0(REG_GObjData)
  b Injection_Exit

IdleThink:
blrl
.set  REG_GObjData,31
.set  REG_Floats,30

.set  IdleData_Text,0x0
.set  IdleData_State,0x4
.set  IdleData_VolumeBackup,0x8
.set  IdleData_IdleCounter,0xC

  backup

#Init
  lwz REG_GObjData,0x2C(r3)
  bl  Floats
  mflr  REG_Floats

#Check if already muted
  lwz r3,IdleData_State(REG_GObjData)
  cmpwi r3,0x0
  bne IdleThink_CheckToUnmute

IdleThink_CheckToMute:
#Check if anyone is inputting on this frame
  li  r3,4
  branchl r12,Inputs_GetPlayerHeldInputs
  cmpwi r4,0
  beq IdleThink_CheckToMute_IncTimer
IdleThink_CheckToMute_ResetTimer:
  li  r3,0
  stw r3,IdleData_IdleCounter(REG_GObjData)
  b IdleThink_Exit
IdleThink_CheckToMute_IncTimer:
  lwz r3,IdleData_IdleCounter(REG_GObjData)
  addi  r3,r3,1
  stw r3,IdleData_IdleCounter(REG_GObjData)
  cmpwi r3,IdleThreshold
  blt IdleThink_Exit
#Mute Music
  lwz r4,-0x7E1C(r13)
  stw r4,IdleData_VolumeBackup(REG_GObjData)
  li  r3,0
  branchl r12,cvt_sll_flt
  lfs f2,VolumeMultiplier(REG_Floats)
  fmuls f1,f1,f2
  branchl r12,cvt_fp2unsigned
  stw r3,-0x7E1C(r13)
#Display filter
  lwz  r3,IdleData_Text(REG_GObjData)
  branchl r12,DevelopText_ShowBG
#Change state
  li  r3,1
  stw r3,IdleData_State(REG_GObjData)
#Reset Timer
  li  r3,0
  stw r3,IdleData_IdleCounter(REG_GObjData)
  b IdleThink_Exit

IdleThink_CheckToUnmute:
#Check if anyone is inputting on this frame
  li  r3,4
  branchl r12,Inputs_GetPlayerHeldInputs
  cmpwi r4,0
  beq IdleThink_Exit
#Unmute music
  lwz r3,IdleData_VolumeBackup(REG_GObjData)
  stw r3,-0x7E1C(r13)
#Hide Filter
  lwz  r3,IdleData_Text(REG_GObjData)
  branchl r12,DevelopText_HideBG
#Change state
  li  r3,0
  stw r3,IdleData_State(REG_GObjData)
  b IdleThink_Exit

IdleThink_Exit:
  restore
  blr

######################
Floats:
blrl
.set TextScale_X,0x0
.set TextScale_Y,0x4
.set TextBG,0x8
.set VolumeMultiplier,0xC
.float 1000
.float 1000
.byte 0,0,0,130
.float 0.3
######################

Injection_Exit:
  restore
  mr	r3, r31
