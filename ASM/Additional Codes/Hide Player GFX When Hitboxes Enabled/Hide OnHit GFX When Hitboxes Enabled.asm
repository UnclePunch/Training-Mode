#To be inserted at 8007a180
.include "../../Globals.s"

#Get player's hitbox visibility flag
  lbz r0,0x21FC(r6)
  rlwinm. r0,r0,0,30,30
  beq Original
  branch  r12,0x8007a6a8

Original:
  lwz	r0, 0x0030 (r4)
