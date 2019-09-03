#To be inserted at 8000a284
.include "../../Globals.s"

#Check if vuln
  cmpwi r6,0
  bne Exit
#Check if this is an ungrabbable hurtbox
  lwz r0,0x48(r28)
  cmpwi r0,0
  bne Exit
#Override color
  bl  Color
  mflr  r3
  b Skip

Color:
blrl
.long 0xAB27FF80

Exit:
  lwz	r3, 0 (r3)
Skip:
