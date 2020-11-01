#To be inserted @ 800C2D3C

loc_0x0:
  lis r0, 0x800C
  ori r0, r0, 0x2690
  mtlr r0
  blrl
  addi r5, r24, 0x1
  lis r0, 0x800C
  ori r0, r0, 0x2DA4
  mtctr r0
  bctr
