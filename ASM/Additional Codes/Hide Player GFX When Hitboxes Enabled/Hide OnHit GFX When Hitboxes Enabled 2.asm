#To be inserted at 8007a430
.include "../../Globals.s"

#Get player's hitbox visibility flag
  lwz	r12, 0x002C (r30)
  lbz r12,0x21FC(r12)
  rlwinm. r12,r12,0,30,30
  beq Original
  branch  r12,0x8007a6a8

Original:
  lwz	r0, 0x0030 (r17)
