#To be inserted at 8002CB34
loc_0x0:
  extsb r4, r0    #
  lis r3, 0x804C
  ori r3, r3, 0x1FAC
  mulli r6, r0, 0x44
  add r3, r3, r6
  lwz r6, -20812(r13)
  lfs f17, 0(r6)
  fneg f1, f17
  lfs f15, 44(r3)
  fcmpo cr0, f15, f1
  ble- loc_0x34
  fcmpo cr0, f15, f17
  blt- loc_0x5C

loc_0x34:
  lwz r6, 0(r3)
  rlwinm. r6, r6, 0, 27, 27
  beq- loc_0x50
  lfs f16, 796(r31)
  fadd f16, f15, f16
  stfs f16, 796(r31)
  b loc_0x5C

loc_0x50:
  lfs f16, 792(r31)
  fadd f16, f15, f16
  stfs f16, 792(r31)

loc_0x5C:
  lfs f15, 40(r3)
  fcmpo cr0, f15, f1
  ble- loc_0x70
  fcmpo cr0, f15, f17
  blt- loc_0x7C

loc_0x70:
  lfs f16, 788(r31)
  fadd f16, f15, f16
  stfs f16, 788(r31)

loc_0x7C:
