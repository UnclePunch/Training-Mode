#To be inserted @ 800C2674

loc_0x0:
  lwz r3, -8576(r2)
  lwz r4, -8572(r2)
  lis r0, 0x800C
  ori r0, r0, 0x268C
  mtlr r0
  blrl
  lis r0, 0x800C
  ori r0, r0, 0x2738
  mtctr r0
  lbz r0, 8449(r28)
  bctr
