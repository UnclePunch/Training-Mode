#To be inserted at 801a49a8
.include "../../Globals.s"
.include "../../../m-ex/Header.s"

lwz	r0, -0x6C98 (r13)
cmpwi r0,3
bge isDebug

NoDebug:
#Run just HSDUpdate
branch r12,0x801a4a78

isDebug:
#Run as normal