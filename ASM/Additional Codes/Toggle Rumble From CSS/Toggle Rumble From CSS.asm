#To be inserted at 802608D8
.include "../../Globals.s"

#CREDIT: Dan Salvato

loc_0x0:
  lbz r3, 7(r31)
  cmpwi r3, 0x0
  bne- loc_0x98
  lbz r4, 4(r31)
  mr r23, r4
  lwz r0, -30656(r13)
  add r3, r0, r4
  lbz r5, 7360(r3)
  rlwinm. r0, r28, 0, 28, 28
  bne- loc_0x34
  rlwinm. r0, r28, 0, 29, 29
  bne- loc_0x68
  b loc_0xDC

loc_0x34:
  cmplwi r5, 1
  beq- loc_0xDC
  mr r3, r23
  li r4, 0x0
  li r5, 0xE
  li r6, 0x0
  subi r7, r13, 0x66B0
  branchl r12,0x80378430
  li r4, 0x1
  b loc_0x74

loc_0x68:
  cmplwi r5, 0
  beq- loc_0xDC
  li r4, 0x0

loc_0x74:
  mr r3, r23
  branchl r12,0x8015ED4C
  li r4, 0x1
  stb r4, 7(r31)
  lis r4, 0xC040
  stw r4, 20(r31)

loc_0x98:
  lfs f1, 20(r31)
  lfs f2, -29172(r2)
  lfs f0, 12(r31)
  fadds f0, f1, f0
  stfs f0, 12(r31)
  fneg f3, f1
  fcmpo cr0, f3, f1
  bgt- loc_0xBC
  fmuls f3, f3, f2

loc_0xBC:
  stfs f3, 20(r31)
  blt- loc_0xDC
  lfs f4, -32168(r2)
  fcmpo cr0, f3, f4
  bgt- loc_0xDC
  li r4, 0x0
  stw r4, 20(r31)
  stb r4, 7(r31)

loc_0xDC:
  lbz r4, 4(r31)
