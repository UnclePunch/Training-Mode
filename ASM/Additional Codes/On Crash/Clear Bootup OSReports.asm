#To be inserted at 80160154
.include "../../Globals.s"

# Remove all previous OSReports
  load r3,0x804cf7e8
  li  r4,0
  stw r4,0xC(r3)

li	r0, 0