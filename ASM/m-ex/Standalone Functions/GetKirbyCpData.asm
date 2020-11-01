#To be inserted @ 803d7084
.include "../../Globals.s"
.include "../Header.s"

mulli r3,r3,0x4
lwz  r4,OFST_KirbyAbilityRuntimeStruct(rtoc)
lwzx  r3,r3,r4
blr