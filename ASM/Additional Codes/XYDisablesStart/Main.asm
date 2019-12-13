#To be inserted at 803775bc
.include "../../Globals.s"

#Check if pressing start
  rlwinm. r3,r0,0,0x1000
  beq Injection_Exit
  #Check if also holding X+Y
  rlwinm. r3,r0,0,0xC00
  beq Injection_Exit
#Remove the start input
  li  r3,0
  rlwimi  r0,r3,12,0x1000
Injection_Exit:
#store their instant input
  stw	r0, 0 (r26)
