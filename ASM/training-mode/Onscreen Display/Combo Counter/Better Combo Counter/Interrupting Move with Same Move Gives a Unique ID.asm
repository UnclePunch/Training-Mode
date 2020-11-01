#To be inserted at 80089610
.include "../../../Globals.s"
.include "../../../../m-ex/Header.s"

#Check If Move Was Interrupted With the Same Move
  lwz r3,0x10(r26)  #New Move
  lhz r4,TM_OneASAgo(r26)  #Previous Moe
  cmpw  r3,r4
  bne Original

#Interrupted move with same move, assign unique move ID
  branch r12,0x8008961c

Original:
  lbz	r0, 0x2073 (r31)
