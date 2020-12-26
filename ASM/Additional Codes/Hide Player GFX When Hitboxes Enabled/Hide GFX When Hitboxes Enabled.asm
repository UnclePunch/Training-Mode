#To be inserted at 8005FE30
.include "../../Globals.s"

#Check if a GObj was sent as an arg
  cmpwi r4,0
  beq Original
#Check if this is a player GObj
  lhz r8,0x0(r4)
  cmpwi r8,0x4
  beq Fighter
  cmpwi r8,0x6
  beq Item
  b Original

Fighter:
#Get player's hitbox visibility flag
  lwz r8,0x2C(r4)
  lbz r8,0x21FC(r8)
  rlwinm. r8,r8,0,30,30
  beq Original
  b Skip

Item:
#Get item's hitbox visibility flag
  lwz r8,0x2C(r4)
  lbz r8,0xDAA(r8)
  rlwinm. r8,r8,0,30,30
  beq Original
  b Skip

Skip:
  li  r3,0
  branch  r12,0x80061d40

Original:
  addi	r28, r3, 0
