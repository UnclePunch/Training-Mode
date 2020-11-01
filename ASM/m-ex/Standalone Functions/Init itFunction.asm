#To be inserted @ 803d7070
.include "../../Globals.s"
.include "../Header.s"

/*
r3 = file header
r4 = index
r5 = fighter/stage
*/

.set  REG_Index,31
.set  REG_Type,30
.set  REG_itFunction,29

#ftX struct
  .set  ftX_Code,0x0
  .set  ftX_InstructionRelocTable,0x4
  .set  ftX_InstructionRelocTableCount,0x8
  .set  ftX_FunctionRelocTable,0xC
    .set  FunctionRelocTable_ReplaceThis,0x0
    .set  FunctionRelocTable_ReplaceWith,0x4
  .set  ftX_FunctionRelocTableCount,0x10

backup
mr  REG_Index,r4
mr  REG_Type,r5

#Get symbol offset from file
  bl  itFunctionString
  mflr  r4
  branchl r12,0x80380358
  mr.  REG_itFunction,r3
  beq itFunction_NoItem

#Loop through all items
.set  REG_ItemCount,20
.set  REG_LoopCount,21
  lwz REG_ItemCount,0x0(REG_itFunction)
  li  REG_LoopCount,0
  cmpwi REG_ItemCount,0
  beq itFunction_NoItem
itFunction_Init:
#Get this item
.set  REG_ThisItem,22
  addi r3,REG_itFunction,0x4
  mulli r4,REG_LoopCount,4
  lwzx  REG_ThisItem,r3,r4
#Ensure it exists
  cmpwi REG_ThisItem,0
  beq itFunction_InitLoop
#Reloc
  lwz r3,ftX_InstructionRelocTableCount(REG_ThisItem)  #count
  lwz r4,ftX_Code(REG_ThisItem)  #code
  lwz r5,ftX_InstructionRelocTable(REG_ThisItem)  #reloc table
  branchl r12,Reloc
#Copy function pointers - init
.set  REG_ThisOffset,12
.set  REG_FuncPtrs,11
.set  REG_Code,10
.set  REG_ItemTable,9
.set  REG_Count,8
#Get external item ID from internal
  mr  r3,REG_Index
  mr  r4,REG_Type
  mr  r5,REG_LoopCount
  bl  Item_GetItemTableFromInternal
  mr  REG_ItemTable,r3
#Init
  lwz REG_FuncPtrs,ftX_FunctionRelocTable(REG_ThisItem)
  lwz REG_Code,0x0(REG_ThisItem)
  li  REG_Count,0
  b itFunction_Overload_CheckLoop
itFunction_Overload_Loop:
  mulli r4,REG_Count,8
  add  r5,r4,REG_FuncPtrs
#Convert to code offset
  lwz r3,0x4(r5)
  add r3,r3,REG_Code
#get offset
  lwz r4,0x0(r5)
  mulli r4,r4,4
#Store to item table
  stwx  r3,r4,REG_ItemTable
itFunction_Overload_IncLoop:
  addi  REG_Count,REG_Count,1
itFunction_Overload_CheckLoop:
  lwz r3,ftX_FunctionRelocTableCount(REG_ThisItem)
  cmpw REG_Count,r3
  blt itFunction_Overload_Loop

itFunction_InitLoop:
  addi  REG_LoopCount,REG_LoopCount,1
  cmpw  REG_LoopCount,REG_ItemCount
  blt itFunction_Init
  li  r3,1
  b Exit

itFunction_NoItem:
  li  r3,0
  b Exit

itFunctionString:
blrl
.string "itFunction"
.align 2


Item_GetItemTableFromInternal:
.set  REG_ArticleID,12
.set  REG_Index,11
.set  REG_Type,10
#Init
  mr  REG_Index,r3
  mr  REG_Type,r4
  mr  REG_ArticleID,r5
#Get external item ID from internal
  cmpwi REG_Type,1
  beq Item_GetItemTableFromInternal_Stage
Item_GetItemTableFromInternal_Fighter:
  lwz r3,OFST_mexData(rtoc)
  lwz r3,Arch_Fighter(r3)
  lwz r3,Arch_Fighter_MEXItemLookup(r3)
  b Item_GetItemTableFromInternal_GetID
Item_GetItemTableFromInternal_Stage:
  lwz r3,OFST_mexData(rtoc)
  lwz r3,Arch_Map(r3)
  lwz r3,Arch_Map_StageItemLookup(r3)
  b Item_GetItemTableFromInternal_GetID
Item_GetItemTableFromInternal_GetID:
  mulli r4,REG_Index,MEXItemLookup_Stride
  add r3,r3,r4
  lwz r3,0x4(r3)
#Ensure item table exists
  cmpwi r3,0
  beq DoesNotExist
#Get item ID
  mulli r4,REG_ArticleID,2
  lhzx r3,r3,r4
#Get item's table
  lwz r4,OFST_ItemsAdded(rtoc)
  cmpwi r3,43
  blt CommonItems
  cmpwi r3,161
  blt FighterItems
  cmpwi r3,208
  blt PokemonItems
  cmpwi r3,CustomItemStart
  blt StageItems
  b CustomItems
CommonItems:
  lwz r4,Arch_ItemsAdded_Common(r4)
  b GetTable
FighterItems:
  subi  r3,r3,43
  lwz r4,Arch_ItemsAdded_Fighter(r4)
  b GetTable
PokemonItems:
  subi  r3,r3,161
  lwz r4,Arch_ItemsAdded_Pokemon(r4)
  b GetTable
StageItems:
  subi  r3,r3,208
  lwz r4,Arch_ItemsAdded_Stages(r4)
  b GetTable
CustomItems:
  subi  r3,r3,CustomItemStart
  lwz r4,Arch_ItemsAdded_Custom(r4)
  b GetTable

GetTable:
  mulli r3,r3,0x3C
  add  r3,r3,r4
  blr
###########################################

DoesNotExist:

#Get Object Kind string
  cmpwi REG_Type, 1
  beq DoesNotExist_Stage
DoesNotExist_Fighter:
  bl  ErrorString_Fighter
  mflr r4
  b DoesNotExist_OSReport
DoesNotExist_Stage:
  bl  ErrorString_Stage
  mflr r4
  b DoesNotExist_OSReport
DoesNotExist_OSReport:
  bl  ErrorString
  mflr  r3
  mr  r5,REG_Index
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
.string "error: MxDt does not contain any items for %s %d\n"
.align 2
ErrorString_Fighter:
blrl
.string "fighter"
.align 2
ErrorString_Stage:
blrl
.string "stage"
.align 2
###############################################

Exit:
  restore
  blr
