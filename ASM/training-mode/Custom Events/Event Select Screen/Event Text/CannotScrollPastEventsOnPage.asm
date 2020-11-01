#To be inserted at 8024dec8
.include "../../../Globals.s"
.include "../../../../m-ex/Header.s"

.set PageID,31

#Get number of events on this page
	lwz r3,MemcardData(r13)
	lbz r3,CurrentEventPage(r3)
  rtocbl r12,TM_GetPageEventNum

#Get current event
  lbz	r4, 0 (r28)

#If on the last event, dont scroll down
  cmpw r4,r3
  blt Exit

#Exit EventThink
  branch r12,0x8024e198

Exit:
  lbz	r0, 0 (r28)
  cmplwi	r0, 8
