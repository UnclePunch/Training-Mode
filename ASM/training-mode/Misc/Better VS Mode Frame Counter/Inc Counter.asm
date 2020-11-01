#To be inserted at 8016d310
.include "../../Globals.s"
.include "../../../m-ex/Header.s"

lwz r3,TM_GameFrameCounter(r13)
addi r3,r3,1
stw r3,TM_GameFrameCounter(r13)

Exit:
  lwz	r31, 0x0034 (sp)
