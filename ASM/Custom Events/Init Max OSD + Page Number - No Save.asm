#To be inserted at 8015fab0
.include "../Globals.s"

#0x0 = Memcard + save
#0x4 = Memcard + no save
#0xF = No Memcard

#Check Memcard Status
  cmpwi	r29,0x4
  beq	InitSettings
  cmpwi	r29,0xF
  beq	InitSettings
  b exit

InitSettings:
#Set Max OSD on No Memcard
  li	r3,1
  lwz	r4, -0x77C0 (r13)
  stb	r3,0x1F28(r4)
#Set Initial Page Number
  li  r3,0x1
  stb r3,CurrentEventPage(r4)

exit:
  lwz	r0, -0x6C98 (r13)
