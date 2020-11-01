#To be inserted at 802f9a3c
.include "../../Globals.s"
.include "../../../m-ex/Header.s"

.if PAL==1
#Get Flaots
  bl  Floats
  mflr r4
#Store X Scale
  lwz r3,0x0(r4)
  stw r3,0x2c(r29)
#Store Y Scale
  stw r3,0x30(r29)
#Load Y Offset
  lwz r3,0x4(r4)
  stw r3,0x3C(r29)
  b original

######################################
Floats:
blrl
.float 0.85     #x and y scale
.float -21      #y offset
######################################

original:
lwz	r0, 0x0014 (r29)

.endif

.if PAL==0
lwz	r0, 0x0014 (r29)
.endif
