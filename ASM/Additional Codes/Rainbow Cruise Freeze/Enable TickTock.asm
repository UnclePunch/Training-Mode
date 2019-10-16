#To be inserted at 801ff62c
.include "../../Globals.s"

  bl  Floats
  mflr r7

#Enable TickTock
  mr  r3,r30
  li  r4,0x10
  li  r5,2
  li  r6,2  #enabled state
  lfs f1,0x0(r7)
  lfs	f2, -0x437C (rtoc)
  branchl r12,0x801c7ff8
  li  r3,10
  branchl r12,0x80057638
  li  r3,10
  branchl r12,0x80055e9c
  li  r3,10
  branchl r12,0x80057424
  b Exit

Floats:
blrl
.float 100

Exit:
  lis	r3, 0x8020
