#To be inserted @ 803d706C
.include "../../Globals.s"
.include "../Header.s"

.set  REG_Size,31
.set  REG_Alloc,30

#init
  backup
  mr  REG_Size,r3
#alloc
  branchl r12,HSD_MemAlloc
  mr  REG_Alloc,r3
#clear
  li  r4,0
  mr  r5,REG_Size
  branchl r12,0x80003100
#Exit
  mr  r3,REG_Alloc
  restore
  blr
