#To be inserted at 801a5e90
.include "../../Globals.s"

.set  SuddenDeathTimer,3*60

#Override Timer
  li  r3,SuddenDeathTimer
  stw r3,0x10(r31)

#Original
  mr	r3, r31
