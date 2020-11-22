#To be inserted at 8016e8c8
.include "../Globals.s"
.include "../../m-ex/Header.s"

#Call function in TmDt
  rtocbl  r12,TM_OnStartMelee

#Original Line
  lwz	r12, 0x0044 (r31)