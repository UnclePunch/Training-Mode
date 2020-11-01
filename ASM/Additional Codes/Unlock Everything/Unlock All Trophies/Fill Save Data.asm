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

Exit:
  cmpwi	r25, 0
