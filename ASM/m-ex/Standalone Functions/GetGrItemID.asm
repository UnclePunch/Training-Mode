#To be inserted @ 803d708C
.include "../../Globals.s"
.include "../Header.s"

.set  REG_FighterID,31
.set  REG_ArticleID,30
.set  REG_ID,29
.set  REG_MEXItemLookup,28

backup

#Backup args
  mr  REG_ArticleID,r3

# Get stage ID
  load  r3,0x8049e6c8
  lwz REG_ID,0x88(r3)
#Get table from mxdt
  lwz r3,OFST_mexData(rtoc)
  lwz r3,Arch_Map(r3)
  lwz r3,Arch_Map_StageItemLookup(r3)
  mulli r4,REG_ID,MEXItemLookup_Stride
  add REG_MEXItemLookup,r3,r4
#Check if exists
  lwz r3,0x0(REG_MEXItemLookup)
  cmpw  REG_ArticleID,r3
  bge DoesNotExist
#Get external item ID from internal
  lwz r3,0x4(REG_MEXItemLookup)
  mulli r4,REG_ArticleID,2
  lhzx r3,r3,r4
  b Exit

#############################################
DoesNotExist:
#OSReport
  bl  ErrorString
  mflr  r3
  mr r4,REG_ID
  mr  r5,REG_ArticleID
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
.string "error: stage %d does not have item %d\n"
.align 2
###############################################

Exit:
  restore
  blr
