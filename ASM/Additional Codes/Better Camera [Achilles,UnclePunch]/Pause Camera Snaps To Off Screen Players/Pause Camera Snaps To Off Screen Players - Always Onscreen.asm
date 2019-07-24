#To be inserted at 8002cf34
.include "../../../Globals.s"

.set REG_Pauser,31
.set REG_Count,30

backup

#Get player port who paused
  load r3,0x8046b6a0
  lbz REG_Pauser,0x1(r3)

#Search all players for this port
  li  REG_Count,0
Loop:
  mr  r3,REG_Count
  branchl r12,PlayerBlock_LoadMainCharDataOffset
  cmpwi r3,0
  beq IncLoop
#Check their port to see if it matches
  mr  r3,REG_Count
  branchl r12,0x8003345c
  cmpw  r3,REG_Pauser
  beq FoundPauser
IncLoop:
  addi  REG_Count,REG_Count,1
  cmpwi REG_Count,4
  blt Loop
  b Dead

FoundPauser:
#Check if player is alive
  mr  r3,REG_Count
  branchl r12,PlayerBlock_LoadMainCharDataOffset
  lwz r3,0x2C(r3)
  lbz r3,0x221F(r3)
  rlwinm. r3,r3,0,25,25
  bne Dead

Alive:
  li  r3,0
  b Exit
Dead:
  li  r3,1
Exit:
  restore
