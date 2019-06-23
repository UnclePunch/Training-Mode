#To be inserted at 8015f6f8
.include "../../../Globals.s"

#Get trophy data
  lwz	r3, -0x77C0 (r13)
  addi	r3, r3, 7376
#Set trophy count
  li  r4,293
  sth r4,0x0(r3)
#Set individual trophies as unlocked
  addi r3,r3,4
  li  r4,99
  li  r5,0x24f
  branchl r12,memset

InitSettings:
#Set Max OSD on No Memcard
  li	r3,1
  lwz	r4, -0x77C0 (r13)
  stb	r3,0x1F28(r4)
#Set Initial Page Number
  li  r3,0x1
  stb r3,CurrentEventPage(r4)
#Enable UCF by default
  load r3,0x08000000
  stw r3,OSDBitfield(r4)

Exit:
  cmpwi	r25, 0
