#To be inserted @ 804DD84C

loc_0x0:
  mflr r0
  stw r0, 4(r1)
  stwu r1, -64(r1)
  stmw r29, 16(r1)
  mr r30, r3
  mr r31, r4
  mr r3, r4
  mr r4, r5
  lis r0, 0x800C
  ori r0, r0, 0x268C
  mtlr r0
  blrl
  lis r0, 0x800C
  ori r0, r0, 0x2690
  mtlr r0
  blrl
  rlwinm r3, r31, 0, 24, 31
  cmpwi r3, 0x5
  blt+ loc_0x84
  cmpwi r3, 0x7
  bgt- loc_0x84
  rlwinm r3, r31, 16, 22, 31
  li r4, 0x5
  beq- loc_0x74
  lis r0, 0x8033
  ori r0, r0, 0xD240
  mtlr r0
  blrl
  b loc_0x84

loc_0x74:
  lis r0, 0x8033
  ori r0, r0, 0xD298
  mtlr r0
  blrl

loc_0x84:
  rlwinm r3, r31, 3, 24, 28
  addi r3, r3, 0x80
  li r4, 0x0
  rlwinm r5, r30, 0, 16, 31
  lis r0, 0x8033
  ori r0, r0, 0xD0DC
  mtlr r0
  blrl
  lis r3, 0xCC01
  subi r3, r3, 0x8000
  lmw r29, 16(r1)
  lwz r0, 0x44(r1)
  addi r1, r1, 0x40
  mtlr r0
  blr
