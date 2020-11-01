#To be inserted @ 803d7078
.include "../../Globals.s"
.include "../Header.s"

.set  REG_SFXID,31

backup

#r3 = stage SFX ID
  mr  REG_SFXID,r3

#Get current stage internal ID
  load  r3,0x8049e6c8
  lwz r3,0x88(r3)
#Get stage's ssm ID
  lwz r4,OFST_Map_Audio(rtoc)
  mulli r3,r3,3
  add r3,r3,r4
  lbz r3,0x0(r3)
#Multiply by 10000
  mulli r3,r3,10000
#Add SFX ID
  add r3,r3,REG_SFXID
#Play SFX
  branchl r12,0x801c53ec

Exit:
  restore
  blr
