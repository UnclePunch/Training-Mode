#To be inserted @ 80268648
.include "../../Globals.s"
.include "../Header.s"

.set  REG_GObj,31
.set  REG_ItemSpawnStruct,30
.set  REG_PlayerData,29
.set  REG_MEXItemLookup,28
.set  REG_ArticleID,27

backup

#Check if article >=5000
  lwz REG_ArticleID,0x8(REG_ItemSpawnStruct)
  cmpwi REG_ArticleID,5000
  blt Exit
#Index
  subi  REG_ArticleID,REG_ArticleID,5000
#Check if player or stage
  lwz REG_GObj,0x0(REG_ItemSpawnStruct)
  cmpwi REG_GObj,0
  beq IsStageItem
  lhz r3,0x0(REG_GObj)
  cmpwi r3,4
  beq IsFighterItem
  cmpwi r3,3
  beq IsStageItem
  b Unsupported

IsFighterItem:
#Get Fighter MEX Item Lookup
  lwz r3,OFST_mexData(rtoc)
  lwz r3,Arch_Fighter(r3)
  lwz r3,Arch_Fighter_MEXItemLookup(r3)
#Get index (fighter internal ID)
  lwz r4,0x2C(REG_GObj)
  lwz r4,0x4(r4)
  b GetMEXItemID
IsStageItem:
#Get index (stage internal ID)
  lwz r3,OFST_mexData(rtoc)
  lwz r3,Arch_Map(r3)
  lwz r3,Arch_Map_StageItemLookup(r3)
#No player gobj passed in, assuming this is a stage item
  load  r4,0x8049e6c8
  lwz r4,0x88(r4)
GetMEXItemID:
#Get table from mxdt
  mulli r4,r4,MEXItemLookup_Stride
  add REG_MEXItemLookup,r3,r4
#Check if exists
  lwz r3,0x0(REG_MEXItemLookup)
  cmpw  REG_ArticleID,r3
  bge DoesNotExist

SpawnItem:
#Get external item ID from internal
  lwz r3,0x4(REG_MEXItemLookup)
  mulli r4,REG_ArticleID,2
  lhzx r3,r3,r4
  stw r3,0x8(REG_ItemSpawnStruct)
  b Exit

#############################################
DoesNotExist:
#OSReport
  bl  ErrorString
  mflr  r3
  mr  r4,REG_ArticleID
  branchl r12,0x803456a8
#Assert
  bl  Assert_Name
  mflr  r3
  li  r4,0
  load  r5,0x804d3940
  branchl r12,0x80388220
Assert_Name:
blrl
.string "m-ex"
.align 2
ErrorString:
blrl
.string "error: MxDt does not have article ID %d\n"
.align 2
###############################################
Unsupported:

Exit:
  restore
  lwz	r3, 0x000C (r30)
