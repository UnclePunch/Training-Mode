#To be inserted at 801b02ec
.include "../Globals.s"

.set entity,31
.set player,31
.set playerdata,31

#Set First Boot Flag (used for OSD backup/restore)
  li	r3,0x1
  stb	r3,FirstBootFlag(rtoc)

###############################
## Initialize Event CPU Info ##
###############################
#Set CPU Info
  li  r3,0x21
  stb r3,EventCPUBackup_CharID(rtoc)   #Set CPU Character ID

Original:
  lwz	r0, 0x001C (sp)
