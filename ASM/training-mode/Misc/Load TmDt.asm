#To be inserted at 803753b0
.include "../Globals.s"
.include "../../m-ex/Header.s"
.include "../../m-ex/Header.s"

#ftX struct
  .set  ftX_Code,0x0
  .set  ftX_InstructionRelocTable,0x4
  .set  ftX_InstructionRelocTableCount,0x8
  .set  ftX_FunctionRelocTable,0xC
    .set  FunctionRelocTable_ReplaceThis,0x0
    .set  FunctionRelocTable_ReplaceWith,0x4
  .set  ftX_FunctionRelocTableCount,0x10

.set  REG_HeapLo,31
.set  REG_FileSize,28
.set  REG_File,27
.set  REG_HeapID,26
.set  REG_Header,25
.set  REG_mexData,24

stw	r31, -0x3FE8 (r13)

backup

#Check if file exists
  bl  FileName
  mflr  r3
  branchl r12,0x8033796c
  cmpwi r3,-1
  beq Exit
#Get size of TmDt.dat
  bl  FileName
  mflr  r3
  branchl r12,0x800163d8
  addi  REG_FileSize,r3,0
#ALlign
  addi  REG_FileSize,REG_FileSize,31
  rlwinm	REG_FileSize, REG_FileSize, 0, 0, 26
#Create heap of this size
  add r4,REG_HeapLo,REG_FileSize     #heap hi = start + filesize
  addi  r4,r4,32*5              #plus 96 for header
  mr  r3,REG_HeapLo                  #heap lo = start
  mr  REG_HeapLo,r4             #new start = heap hi
  branchl r12,0x803440e8
  mr  REG_HeapID,r3
#Alloc header
  li  r4,68
  branchl r12,0x80343ef0
  mr  REG_Header,r3
#Alloc from this heap
  mr  r3,REG_HeapID
  mr  r4,REG_FileSize
  branchl r12,0x80343ef0
  mr  REG_File,r3
#Load file here
  bl  FileName
  mflr  r3
	mr r4, REG_File
	addi	r5, sp, 0x80
	branchl	r12,0x8001668C
#Init Archive
  lwz r5,0x80(sp)
  mr  r3,REG_Header   #store header
  mr  r4,REG_File      #file
  branchl r12,0x80016a54
#Get symbol offset
  mr  r3,REG_Header
  bl  SymbolName
  mflr  r4
  branchl r12,0x80380358
  mr.  REG_mexData,r3
  beq mexPatch_Skip
#Reloc
  lwz r3,ftX_InstructionRelocTableCount(REG_mexData)  #count
  lwz r4,ftX_Code(REG_mexData)                        #code
  lwz r5,ftX_InstructionRelocTable(REG_mexData)       #reloc table
  branchl r12,Reloc
#Overload
  mr  r3,REG_mexData
  addi  r4,rtoc,TM_tmFunction
  bl  Overload
mexPatch_Skip:

#Flush instruction cache so code can be run from this file
  mr  r3,REG_File
  mr  r4,REG_FileSize
  branchl r12,0x80328f50

#Run TM_OnFileLoad
  lwz r12,TM_OnFileLoad(rtoc)
  cmpwi r12,0
  beq Skip_OnFileLoad
  mr  r3,REG_Header
  mtctr r12
  bctrl
  Skip_OnFileLoad:

  b Exit

###########################################

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
  mulli r4,REG_Count,4
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

FileName:
blrl
.string "TM/TmDt.dat"
.align 2
SymbolName:
blrl
.string "tmFunction"
.align 2

Exit:
  mr  r3,REG_HeapLo
  restore
  mr  r31,r3
  stw	r31, -0x3FE8 (r13)
  mr	r3, r31
  mr	r4, r29
