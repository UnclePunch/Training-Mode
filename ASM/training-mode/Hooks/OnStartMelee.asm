#To be inserted at 8016e904
.include "../Globals.s"
.include "../../m-ex/Header.s"

#Call function in TmDt
  rtocbl  r12,TM_OnStartMelee

#Original Line
  lbz	r0, 0x0001 (r31)