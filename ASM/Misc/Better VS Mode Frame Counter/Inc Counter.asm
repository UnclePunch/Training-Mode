#To be inserted at 8016d30c
.include "../../Globals.s"

lwz r3,TM_GameFrameCounter(r13)
addi r3,r3,1
stw r3,TM_GameFrameCounter(r13)

Exit:
  lwz	r0, 0x003C (sp)
