#To be inserted at 80265224
.include "../../../Globals.s"

#Check if BTT
  lwz r3,CSS_Data(r13)
  lbz r3,0x2(r3)
  cmplwi  r3,0xF
  bne Exit

#Load Joint
  branch  r12,0x8026522c

Exit:
  cmplwi	r0, 1
