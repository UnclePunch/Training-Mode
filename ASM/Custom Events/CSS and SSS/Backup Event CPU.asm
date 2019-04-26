#To be inserted at 801bab1c
.include "../../Globals.s"

  load  r5,0x804977c8
#Get CPU Slot
  lbz	r6,CSS_CPUPlayerPort(r13)    #Player who accessed CSS
#Get CPU's Match Info
  mulli r6,r6,0x24
  add r6,r6,r5
#Get CPU Match Info
  lbz	r3,0x0(r6)
  lbz	r4,0x3(r6)
#Backup CPU Info
  stb r3,EventCPUBackup_CharID(rtoc)   #Get CPU Character ID
  stb r4,EventCPUBackup_CostumeID(rtoc)   #Get CPU Costime ID

Original:
  li	r0, -1
