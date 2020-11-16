#To be inserted @ 803d7080
.include "../../Globals.s"
.include "../Header.s"

# args are
# r3 = file name
# r4 = array to store function pointers to
# r5 = symbol

# returns
# r3 = file data

.set  REG_FileName,31
.set  REG_Return,30
.set  REG_Symbol,29
.set  REG_FileSize,28
.set  REG_File,27
.set  REG_Header,26
.set  REG_mexData,25

backup
mr  REG_FileName,r3
mr  REG_Return,r4
mr  REG_Symbol,r5

#Load file
  mr r3, REG_FileName
  addi	r4, sp, 0x80
  mr r5, REG_Symbol
  li r6,0
  branchl	r12,0x80016c64
  mr REG_Header,r3
#Check if exists
  lwz  REG_mexData,0x80(sp)
  cmpwi REG_mexData,0
  beq mexPatch_Skip
#Reloc
  lwz r3,ftX_InstructionRelocTableCount(REG_mexData)  #count
  lwz r4,ftX_Code(REG_mexData)                        #code
  lwz r5,ftX_InstructionRelocTable(REG_mexData)       #reloc table
  branchl r12,Reloc
#Overload
  mr  r3,REG_mexData
  mr  r4,REG_Return
  bl  Overload
mexPatch_Skip:

#Flush instruction cache so code can be run from this file
  lwz  r3,0x20(REG_Header)   # file start
  lwz  r4,0x0(REG_Header)   # file size 
  branchl r12,0x80328f50

  mr r3,REG_Header
  restore
  blr

###########################################

#ftX struct
  .set  ftX_Code,0x0
  .set  ftX_InstructionRelocTable,0x4
  .set  ftX_InstructionRelocTableCount,0x8
  .set  ftX_FunctionRelocTable,0xC
    .set  FunctionRelocTable_ReplaceThis,0x0
    .set  FunctionRelocTable_ReplaceWith,0x4
  .set  ftX_FunctionRelocTableCount,0x10

Overload:
# r3 = ftX
# r4 = table
#Copy function pointers - init
.set  REG_ftX,12
.set  REG_ThisElement,11
.set  REG_Code,10
.set  REG_OverloadTable,9
.set  REG_Count,8
.set  REG_RelocTable,7
  mr  REG_ftX,r3
  mr  REG_OverloadTable,r4
  lwz REG_RelocTable,ftX_FunctionRelocTable(REG_ftX)
  lwz REG_Code,0x0(REG_ftX)
  li  REG_Count,0
  b Overload_CheckLoop
Overload_Loop:
#Get this element
  mulli r3,REG_Count,8
  add REG_ThisElement,r3,REG_RelocTable

Overload_TableIndex:
#Get ram offset for this function
  lwz r3,FunctionRelocTable_ReplaceWith(REG_ThisElement)
  add r3,r3,REG_Code
#Update table
  lwz r4,FunctionRelocTable_ReplaceThis(REG_ThisElement)
  mulli r4,r4,4
  stwx  r3,r4,REG_OverloadTable
  b Overload_IncLoop

Overload_IncLoop:
  addi  REG_Count,REG_Count,1
Overload_CheckLoop:
  lwz r3,ftX_FunctionRelocTableCount(REG_ftX)
  cmpw  REG_Count,r3
  blt Overload_Loop
Overload_Exit:
  blr
############################################