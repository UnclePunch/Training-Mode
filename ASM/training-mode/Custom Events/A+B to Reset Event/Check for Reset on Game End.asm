#To be inserted at 801bba38
.include "../../Globals.s"
.include "../../../m-ex/Header.s"

#Get all players inputs
  li  r3,4
  branchl r12,0x801a3680

#Check Inputs
  rlwinm. r0, r4, 0, 23, 23 #check A
  beq- Original
  rlwinm. r0, r4, 0, 22, 22 #check B
  beq- Original

Runback:
  branch r12,0x801bb7a0

Original:
  li	r3, 1
