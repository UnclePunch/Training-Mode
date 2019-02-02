#To be inserted at 801b02ec
.include "../Globals.s"

.set entity,31
.set player,31
.set playerdata,31

#Set First Boot Flag
  li	r3,0x1
  stb	r3,-0xda4(rtoc)

#Set Max OSD
  #li	r3,1
  #lwz	r4, -0x77C0 (r13)
  #stb	r3,0x1F28(r4)

  lwz	r0, 0x001C (sp)
