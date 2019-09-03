#To be inserted at 802641d0
.include "../../../Globals.s"

#Check if BTT
  cmplwi  r0,0xF
  bne Exit

#Make 4 Players
  li  r19,4
  stb r19,-0x49AB (r13)
  branch  r12,0x802641f4

Exit:
