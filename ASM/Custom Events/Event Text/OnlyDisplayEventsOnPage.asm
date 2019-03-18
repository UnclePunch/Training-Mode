#To be inserted at 8024cffc
.include "../../Globals.s"

.set PageID,31

#Get number of events on this page
  branchl r12,GetNumOfEventsOnCurrentPage
  subi r3,r3,8

Exit:
  lwz	r0, 0x001C (sp)
