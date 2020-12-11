#To be inserted at 8016bbb4
.include "../Globals.s"
.include "../../m-ex/Header.s"

.set REG_Timer, 10
.set REG_Inputs, 11
.set REG_Count, 12

backup

bl Timer
mflr REG_Timer
load REG_Inputs,0x804c1fac
li REG_Count,0

Loop:
.set REG_ThisInputs, 9
  mulli r3,REG_Count,68
  add REG_ThisInputs,r3,REG_Inputs

# Check for Z
  lwz r0,0x0(REG_ThisInputs)
  rlwinm. r0,r0,0,0x10
  beq LoopInc

# increment timer
  lwz r3,0x0(REG_Timer)
  addi r3,r3,1
  stw r3,0x0(REG_Timer)
# Check if held for 30 frames
  lwz r3,0x0(REG_Timer)
  cmpwi r3,1
  beq Success 
  cmpwi r3,30
  bge Success
  b Failure

Success:
# Inputted, now remove input
  li r4,0
  lwz r0,0x0(REG_ThisInputs)
  rlwimi r0,r4,4,0x10
  stw r0,0x0(REG_ThisInputs)
  lwz r0,0x8(REG_ThisInputs)
  rlwimi r0,r4,4,0x10
  stw r0,0x8(REG_ThisInputs)
# Exit with success
  li r3,1
  b Exit

LoopInc:
  addi REG_Count,REG_Count,1
  cmpwi REG_Count,4
  blt Loop

# Reset timer
  li r3,0
  stw r3,0x0(REG_Timer)
# Set advance to 0
  load r3,0x80479d48
  li r4,0
  lbz r0,0x22(r3)
  rlwimi r0,r4,31,0x1
  stb r0,0x22(r3)

Failure:
  li r3,0
  b Exit

Timer:
blrl
.long 0


Exit:
restore
blr