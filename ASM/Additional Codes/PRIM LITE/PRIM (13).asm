#To be inserted @ 800C2690

loc_0x0:
  mflr r0
  stw r0, 4(r1)
  stwu r1, -16384(r1)
  lis r0, 0x8033
  ori r0, r0, 0xC3C8
  mtlr r0
  blrl
  lis r0, 0x800C
  ori r0, r0, 0x2D40
  mtctr r0
  bctr
