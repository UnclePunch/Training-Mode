#To be inserted at 801b02dc
.include "../../Globals.s"

.set entity,31
.set player,31
.set playerdata,31

#Spoof current (soon to be previous) screen
li	r3,0x2b
load	r4,SceneController
stb	r3,0x0(r4)

#Set First Boot Flag
li	r3,0x1
stb	r3,-0xda4(rtoc)

#Set Max OSD
#li	r3,1
#lwz	r4, -0x77C0 (r13)
#stb	r3,0x1F28(r4)

li	r3,0x00
