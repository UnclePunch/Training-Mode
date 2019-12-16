#To be inserted at 8023cb08
.include "../../../Globals.s"

  li  r10,0
  mr  r9,r6
  b GetTag_Loop
GetTag_IncLoop:
  stb r3,0x0(r7)
  addi  r5,r5,1
  addi  r7,r7,1
  addi  r9,r9,1
GetTag_Loop:
  lbz r3,0x0(r9)
  cmpwi r3,0
  bne GetTag_IncLoop
#Check if all 8 letters are read
  addi  r6,r6,3
  mr  r9,r6
  addi  r10,r10,1
  cmpwi r10,8
  blt GetTag_Loop
  li  r4,0
  branch  r12,0x8023cbec
