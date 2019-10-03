#To be inserted at 801b9fc0
.include "../../../Globals.s"

backup
#Store Pointer to onStartMelee function
  bl  SkyBattle_Init
  mflr r0
  stw	r0, 0x0044 (r3)
  b InjectionExit

#region SkyBattle_Init
SkyBattle_Init:
blrl

.set REG_GObj,31
.set REG_Data,30

.set DataSize,64

backup

#Create GObj
  li  r3,22
  li  r4,23
  li  r5,0
  branchl r12,GObj_Create
  mr  REG_GObj,r3

#Alloc Mem
  li  r3,DataSize
  branchl r12,HSD_MemAlloc
  mr  REG_Data,r3

#Zero Data
  mr  r3,REG_Data
  li  r4,DataSize
  branchl r12,ZeroAreaLength

#Attach Data
  mr  r3,REG_GObj
  li  r4,14
  load r5,HSD_Free
  mr  r6,REG_Data
  branchl r12,GObj_AddUserData

#Attach Process
  mr  r3,REG_GObj
  bl  SkyBattle_Think
  mflr r4
  li  r5,2
  branchl r12,GObj_AddProc

#Remove stage
#Get list start
	bl	RemoveStage_SkipList
########################
bl	RemoveStage_Dummy
bl	RemoveStage_TEST
bl	RemoveStage_Izumi
bl	RemoveStage_Pstadium
bl	RemoveStage_Castle
bl	RemoveStage_Kongo
bl	RemoveStage_Zebes
bl	RemoveStage_Corneria
bl	RemoveStage_Story
bl	RemoveStage_Onett
bl	RemoveStage_MuteCity
bl	RemoveStage_RCruise
bl	RemoveStage_Garden
bl	RemoveStage_GreatBay
bl	RemoveStage_Shrine
bl	RemoveStage_Kraid
bl	RemoveStage_Yoster
bl	RemoveStage_Greens
bl	RemoveStage_Fourside
bl	RemoveStage_MK1
bl	RemoveStage_MK2
bl	RemoveStage_Akaneia
bl	RemoveStage_Venom
bl	RemoveStage_Pura
bl	RemoveStage_BigBlue
bl	RemoveStage_Icemt
bl	RemoveStage_Icetop
bl	RemoveStage_FlatZone
bl	RemoveStage_OldDL
bl	RemoveStage_OldYS
bl	RemoveStage_OldKongo
bl	RemoveStage_Battlefield
bl	RemoveStage_FinalDestination
########################
RemoveStage_SkipList:
	mflr r3
	lwz r4,StageID_External(r13)
  cmpwi r4,0x20
  bgt SkyBattle_RemoveLines
	mulli	r4,r4,4
	add r4,r3,r4
	lwz r5,0x0(r4)				#Get bl Instruction
  rlwinm	r5,r5,0,6,29	#Mask Bits 6-29 (the offset)
	cmpwi r5,0						#If pointer is null, exit
	beq	SkyBattle_RemoveLines
  add	r4,r4,r5					#Pointer to code now in r4
	mtctr r4
	bctr
################################
DestroyMapGObj:
  backup
  branchl r12,Stage_map_gobj_Load
  branchl r12,Stage_Destroy_map_gobj
  restore
  blr
################################
RemoveStage_Izumi:
  li  r3,3
  bl  DestroyMapGObj
#FoD is annoying so get the first platform gobj from the second
  li  r3,4
  branchl r12,Stage_map_gobj_Load
  lwz r3,0xC(r3)
  branchl r12,GObj_Destroy
  li  r3,4
  bl  DestroyMapGObj
  b SkyBattle_RemoveLines
RemoveStage_Pstadium:
/*
#Get monitor gobj from map_gobj
  li  r3,1      #monitor
  branchl r12,Stage_map_gobj_Load
  lwz r31,0x2C(r3)
  lwz r3,0xD4(r31)
  branchl r12,GObj_Destroy
  lwz r3,0xD8(r31)
  branchl r12,GObj_Destroy
  lwz r3,0xDC(r31)
  branchl r12,GObj_Destroy

  li  r3,1      #monitor
  bl  DestroyMapGObj
  li  r3,2      #stage and transform
  bl  DestroyMapGObj
*/
  b SkyBattle_RemoveLines
RemoveStage_Story:
  li  r3,2
  bl  DestroyMapGObj
  li  r3,3
  bl  DestroyMapGObj
  b SkyBattle_RemoveLines
RemoveStage_OldDL:
  li  r3,1
  bl  DestroyMapGObj
  li  r3,4
  bl  DestroyMapGObj
  li  r3,5
  bl  DestroyMapGObj
  li  r3,6
  bl  DestroyMapGObj
  li  r3,7
  bl  DestroyMapGObj
  li  r3,8
  bl  DestroyMapGObj
#set wind hazard count to 0
	li	r3,0
	stw	r3,Stage_PositionHazardCount(r13)
  b SkyBattle_RemoveLines
RemoveStage_Battlefield:
  li  r3,6
  bl  DestroyMapGObj
  b SkyBattle_RemoveLines
RemoveStage_FinalDestination:
  li  r3,1
  bl  DestroyMapGObj
  li  r3,2
  bl  DestroyMapGObj
  li  r3,3
  bl  DestroyMapGObj
  b SkyBattle_RemoveLines

/*
SkyBattle_RemoveLines:
.set  REG_Count,31
#Remove all stage lines
  lwz r3,-0x51EC (r13)
  lwz REG_Count,0x4(r3)
SkyBattle_RemoveLinesLoop:
  mr  r3,REG_Count
  branchl r12,0x80057bc0
  subi  REG_Count,REG_Count,1
  cmpwi REG_Count,0
  bge SkyBattle_RemoveLinesLoop
*/

SkyBattle_RemoveLines:
  lwz r3,-0x51EC (r13)
  lwz r3,0x4(r3)
  mulli r5,r3,4*6
  lwz r3,-0x51E8 (r13)
  li  r4,0x45
  branchl r12,memset

SkyBattle_InitExit:
  restore
  blr

#endregion

#region SkyBattle_Think
SkyBattle_Think:
blrl
#Registers
.set REG_GObj,31
.set REG_GObjData,30

backup

#Init Pointers
  mr  REG_GObj,r3
  lwz REG_GObjData,0x2C(REG_GObj)

#Loop through all alive players and give them infinite jumps
.set  REG_Count,20
.set  REG_isSubchar,21
  li  REG_Count,0
SkyBattle_Think_JumpLoop:
  li  REG_isSubchar,0
SkyBattle_Think_JumpLoopCheckExist:
#Check if exists
  mr  r3,REG_Count
  mr  r4,REG_isSubchar
  branchl r12,0x8003418c
  cmpwi r3,0
  beq SkyBattle_Think_JumpCheckSubchar
#Give jumps back
  lwz r4,0x2C(r3)
  li  r3,1
  stb r3,0x1968(r4)
#If in special fall, enter fall
  lwz r3,0x10(r4)
  cmpwi r3,ASID_FallSpecial
  bne SkyBattle_Think_JumpCheckSubchar
#Enter fall
  lwz r3,0x0(r4)
  branchl r12,AS_Fall

SkyBattle_Think_JumpCheckSubchar:
#Check if subchar
  cmpwi REG_isSubchar,1
  beq  SkyBattle_Think_JumpIncLoop
  li  REG_isSubchar,1
  b SkyBattle_Think_JumpLoopCheckExist
SkyBattle_Think_JumpIncLoop:
  addi  REG_Count,REG_Count,1
  cmpwi REG_Count,6
  blt SkyBattle_Think_JumpLoop

SkyBattle_ThinkExit:
restore
blr

#endregion

InjectionExit:
  restore
