#To be inserted at 8024cffc
.include "../../../Globals.s"
.include "../../../../m-ex/Header.s"

.set PageID,31

#Get number of events on this page
	lwz r3,MemcardData(r13)
	lbz r3,CurrentEventPage(r3)
  rtocbl r12,TM_GetPageEventNum
  cmpwi r3,8
  blt Exit
  subi r3,r3,8

Exit:
  lwz	r0, 0x001C (sp)
