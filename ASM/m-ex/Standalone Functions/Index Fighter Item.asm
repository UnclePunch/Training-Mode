#To be inserted @ 803d7058
.include "../../Globals.s"
.include "../Header.s"

.set  REG_FighterID,31
.set  REG_ArticleData,30
.set  REG_ArticleID,29
.set  REG_MEXItemLookup,27

backup

#Backup args
  mr  REG_FighterID,r3
  mr  REG_ArticleData,r4
  mr  REG_ArticleID,r5

#Get table from mxdt
  lwz r3,OFST_mexData(rtoc)
  lwz r3,Arch_Fighter(r3)
  lwz r3,Arch_Fighter_MEXItemLookup(r3)
  mulli r4,REG_FighterID,MEXItemLookup_Stride
  add REG_MEXItemLookup,r3,r4
#Check if MxDt has an entry for this item
  lwz r3,0x0(REG_MEXItemLookup)
  cmpw  REG_ArticleID,r3
  bge DoesNotExist

Index:
#Get external item ID from internal
  lwz r3,0x4(REG_MEXItemLookup)
  mulli r4,REG_ArticleID,2
  lhzx r3,r3,r4
#Get runtime index
  lwz r4,OFST_ItemsAdded(rtoc)
  lwz r4,Arch_ItemsAdded_RuntimeIndex(r4)
#Correctly index item
  subi  r3,r3,CustomItemStart
#Store article data
  mulli r3,r3,4
  stwx  REG_ArticleData,r3,r4
  b Exit

#############################################
DoesNotExist:
#OSReport
  bl  ErrorString_NoItem
  mflr  r3
  mr  r4,REG_ArticleID
  mr  r5,REG_FighterID
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
ErrorString_NoItem:
blrl
.string "error: MxDt does not contain item %d for fighter %d\n"
.align 2
###############################################

Exit:
  restore
  blr
