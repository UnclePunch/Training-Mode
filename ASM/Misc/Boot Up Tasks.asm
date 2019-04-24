#To be inserted at 801b02ec
.include "../Globals.s"

.set entity,31
.set player,31
.set playerdata,31

#Set First Boot Flag (used for OSD backup/restore)
  li	r3,0x1
  stb	r3,-0xda4(rtoc)

###############################
## Initialize Event CPU Info ##
###############################
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
  load  r4,0x804977c8
#Get CPU Info
  li  r3,0x21
  stb r3,MiscInfo+0x0(r4)   #Set CPU Character ID

Original:
  lwz	r0, 0x001C (sp)
