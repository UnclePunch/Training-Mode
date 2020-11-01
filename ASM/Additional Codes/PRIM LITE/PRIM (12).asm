#To be inserted @ 800C268C

loc_0x0:
  mflr r0
  stw r0, 4(r1)
  stwu r1, -16384(r1)
  stmw r30, 16(r1)
  mr r30, r3
  mr r31, r4
  lis r0, 0x800C
  li r3, 0x1
  ori r0, r0, 0x2678
  mtctr r0
  bctr
