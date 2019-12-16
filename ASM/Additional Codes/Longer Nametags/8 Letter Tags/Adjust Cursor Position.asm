#To be inserted at 8023E0A4
.include "../../../Globals.s"

  fsubs f0, f0, f2
  bl  Floats
  mflr  r4
  lfs f1, 0(r4)
  fdivs f0, f0, f1
  b Exit

Floats:
blrl
.float 2

Exit:
