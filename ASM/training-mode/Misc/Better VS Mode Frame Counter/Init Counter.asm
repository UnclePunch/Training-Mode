#To be inserted at 8016e744
.include "../../Globals.s"
.include "../../../m-ex/Header.s"

li  r3,0
stw r3,TM_GameFrameCounter(r13)

Exit:
  stw	r30, 0x0018 (sp)
