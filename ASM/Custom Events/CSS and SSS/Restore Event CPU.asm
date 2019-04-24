#To be inserted at 801baa9c
.include "../../Globals.s"

.set P1Info,0 *0x24
.set P2Info,1 *0x24
.set P3Info,2 *0x24
.set P4Info,3 *0x24
.set P5Info,4 *0x24
.set P6Info,5 *0x24
#this is a custom offset that comes after the player info.
#its seemingly unused so im going to place the backed up CPU info there
  .set MiscInfo,6 *0x24
#**********************************#
#b Original
#Get Event CSS Match Info
  load  r5,0x804977c8
#Get CPU Info
  lbz r3,MiscInfo+0x0(r5)   #Get CPU Character ID
  lbz r4,MiscInfo+0x1(r5)   #Get CPU Costime ID
#Get CPU Slot
  li  r6,1                #Temp make CPU slot 1
  lbz	r7, 0x0006 (r31)    #Player who accessed CSS
  cmpwi r7,0x1            #Check if P1
  bne 0x8
  li  r6,0
#Get CPU's Match Info
  mulli r6,r6,0x24
  add r6,r6,r5
#Store to CPU Match Info
  stb	r3,0x0(r6)
  stb	r4,0x3(r6)

Original:
  lbz	r0, 0x0044 (r31)
