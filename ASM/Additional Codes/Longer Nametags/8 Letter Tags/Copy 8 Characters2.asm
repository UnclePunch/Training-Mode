#To be inserted at 8023c02c
.include "../../../Globals.s"

.set  REG_Source,4
.set  REG_Dest,7
.set  REG_CharCount,8
.set  REG_SourceCopied,9

  li  r10,0
  li  REG_CharCount,0
  addi  REG_Dest,r30,408
  mr  REG_SourceCopied,REG_Source
  b GetTag_Loop
GetTag_IncLoop:
  stb r3,0x0(REG_Dest)
  addi  REG_CharCount,REG_CharCount,1
  addi  REG_Dest,REG_Dest,1
  addi  REG_SourceCopied,REG_SourceCopied,1
GetTag_Loop:
  lbz r3,0x0(REG_SourceCopied)
  cmpwi r3,0
  bne GetTag_IncLoop
#Check if all 8 letters are read
  addi  REG_Source,REG_Source,3
  mr  REG_SourceCopied,REG_Source
  addi  r10,r10,1
  cmpwi r10,8
  blt GetTag_Loop
  mr  r7,REG_CharCount
  branch  r12,0x8023c118
