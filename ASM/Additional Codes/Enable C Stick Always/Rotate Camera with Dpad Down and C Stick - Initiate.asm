#To be inserted at 802274f0
.include "../../Globals.s"

#Get Inputs
  load  r4,0x804c1fac
  mulli r3,r30,68
  add r3,r3,r4

#Check for dpad down
  lwz r3,0x0(r3)
  rlwinm. r3,r3,0,29,29
  bne Original

#Exit
  branch r12,0x802275f4

Original:
  lfs	f0, -0x3CA4 (rtoc)
