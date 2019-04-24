#To be inserted at 801bab1c
.include "../../Globals.s"

.set P1Info,0 *0x24
.set P2Info,1 *0x24
.set P3Info,2 *0x24
.set P4Info,3 *0x24
.set P5Info,4 *0x24
.set P6Info,5 *0x24
#this is a custom offset that comes after the player info.
#its seemingly unused so #im going to place the backed up CPU info there
  .set MiscInfo,6 *0x24
#**********************************#
#b Original
#Get Event CSS Match Info
  load  r5,0x804977c8
#Get CPU Slot
  lbz	r6,CSS_CPUPlayerPort(r13)    #Player who accessed CSS
#Get CPU's Match Info
  mulli r6,r6,0x24
  add r6,r6,r5
#Get CPU Match Info
  lbz	r3,0x0(r6)
  lbz	r4,0x3(r6)
#Get CPU Info
  stb r3,MiscInfo+0x0(r5)   #Get CPU Character ID
  stb r4,MiscInfo+0x1(r5)   #Get CPU Costime ID

Original:
  li	r0, -1
