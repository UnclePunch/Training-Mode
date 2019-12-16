#To be inserted at 8023e9e4
.include "../../../Globals.s"

  li  r3,0
  subi  r4,r31,3
  li  r5,0
Loop:
  stbu  r3,0x3(r4)
Loop_Inc:
  addi  r5,r5,1
  cmpwi r5,8
  blt Loop
  
  mr	r3, r15
