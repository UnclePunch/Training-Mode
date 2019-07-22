#To be inserted at 80227b70
.include "../../Globals.s"

#Get Inputs
  load  r4,0x804c1fac
  add r4,r4,r5

#Check for dpad down
  lwz r4,0x0(r4)
  rlwinm. r4,r4,0,29,29
  bne Original

#Exit
  branch r12,0x80227b98

Original:
  lfs	f0, -0x3CA4 (rtoc)
