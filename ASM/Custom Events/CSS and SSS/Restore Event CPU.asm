#To be inserted at 801baa9c
.include "../../Globals.s"

#Get CPU Info
  lbz r3,EventCPUBackup_CharID(rtoc)   #Get CPU Character ID
  lbz r4,EventCPUBackup_CostumeID(rtoc)   #Get CPU Costime ID
#Get CPU Slot
  li  r6,1                #Temp make CPU slot 1
  lbz	r7, 0x0006 (r31)    #Player who accessed CSS
  cmpwi r7,0x1            #Check if P1
  bne 0x8
  li  r6,0
#Get CPU's Match Info
  load  r5,0x804977c8
  mulli r6,r6,0x24
  add r6,r6,r5
#Store to CPU Match Info
  stb	r3,0x0(r6)
  stb	r4,0x3(r6)

Original:
  lbz	r0, 0x0044 (r31)
