#To be inserted at 80377944
.include "../../Globals.s"

#Check if nothing is pressed
  lwz	r0, 0x0000 (r26)
  cmpwi r0,0
  beq Exit

#If something is pressed, dont reset timer
  branch r12,0x80377984

Exit:
lwz	r0, 0x0008 (r26)
