#To be inserted at 801a4c94
.include "../Globals.s"
.include "../../m-ex/Header.s"

#Original Line
  stw	r3, -0x4F74 (r13)

#Call function in TmDt
  rtocbl  r12,TM_OnSceneChange
