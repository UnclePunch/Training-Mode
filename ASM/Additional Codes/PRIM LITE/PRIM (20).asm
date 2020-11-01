#To be inserted @ 800C2734

loc_0x0:
  lmw r30, 16(r1)
  lwz r0, 0x4004(r1)
  addi r1, r1, 0x4000
  mtlr r0
  blr
