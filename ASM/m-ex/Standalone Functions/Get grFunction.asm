#To be inserted @ 803d7068
.include "../../Globals.s"
.include "../Header.s"

.set  REG_Temp,12
.set  REG_Dest,3

load  REG_Temp,0x8049e6c8
lwz REG_Temp,0x88(REG_Temp)
mulli REG_Temp,REG_Temp,4
lwz REG_Dest,OFST_grFunction(rtoc)
lwzx  REG_Dest,REG_Dest,REG_Temp
lwz REG_Dest,0x4(REG_Dest)
blr
