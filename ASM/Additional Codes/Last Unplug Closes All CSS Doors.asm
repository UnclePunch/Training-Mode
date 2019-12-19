#To be inserted at 802605e4
.include "../Globals.s"

backup

#Check if all controllers are unplugged
  load  r3,HSD_Pad+0x144
  li  r4,0
UnplugLoop:
  mulli r5,r4,68
  add r5,r5,r3
  lbz r5,0x41(r5)
  extsb. r5,r5
  beq Exit
  addi  r4,r4,1
  cmpwi r4,4
  blt UnplugLoop

.set  REG_LoopCount,31
.set  REG_DoorStruct,30
#All are unplugged, close all doors
  load  REG_DoorStruct,CSS_DoorStructs
  li  REG_LoopCount,0
DoorUpdateLoop:
#Change State
  mulli r3,REG_LoopCount,0x24
  add r3,r3,REG_DoorStruct
  li  r4,3
  stb r4,CSSDoor_State(r3)
#Update Door State
  mr  r3,REG_LoopCount
  branchl r12,CSS_UpdateCSPInfo
#Inc Loop
  addi  REG_LoopCount,REG_LoopCount,1
  cmpwi REG_LoopCount,4
  blt DoorUpdateLoop

Exit:
  restore
  lbz	r0, 0x0004 (r31)
