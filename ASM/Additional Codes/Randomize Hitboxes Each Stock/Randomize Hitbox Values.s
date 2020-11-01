#To be inserted at 80071240
.include "../../Globals.s"

.set  REG_Script,29
.set  REG_FighterGObj,28
.set  REG_Sum,30
.set  REG_Free2,31

# first add up the entire subaction data
  lwz r3, 0x0008 (REG_Script)
  li  r4,0
  li  REG_Sum,0
AddLoop:
  lwz r5,0x0(r3)
  add REG_Sum,REG_Sum,r5
AddLoopInc:
  addi  r4,r4,1
  addi  r3,r3,4
  cmpwi r4,5
  blt AddLoop

# get 16 bit int from this (shitty hash)
.set  REG_Hash,30
  sth REG_Sum,0x03C(sp)
  lhz REG_Hash,0x03C(sp)

# get random damage

# get random angle

# get random KB


# exit
  b Original


Original:
  lwz	r4, 0x0008 (REG_Script)
