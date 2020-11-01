#To be inserted at 801bfa28
.include "../Globals.s"
.include "../../m-ex/Header.s"

#Call function in TmDt
  rtocbl  r12,TM_OnBoot

#Original Line
  lwz	r0, 0x001C (sp)
  