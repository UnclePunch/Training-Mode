#To be inserted at 8002f5bc
loc_0x0:
  lis r3, 0x8048
  lbz r3, -25240(r3)
  rlwinm. r3, r3, 0, 30, 30
  beq- loc_0x48
  lis r3, 0x8048
  lbz r3, -25296(r3)
  cmpwi r3, 0x1C
  beq- loc_0x48
  li r3, 0x0
  stw r3, 760(r31)
  lis r3, 0x4700
  stw r3, 744(r31)
  stw r3, 748(r31)
  stw r3, 752(r31)
  stw r3, 756(r31)
  stw r3, 764(r31)
  lis r3, 0x8003
  b loc_0x50

loc_0x48:
  lis r3, 0x8003
  stfs f1, 764(r31)

loc_0x50:

