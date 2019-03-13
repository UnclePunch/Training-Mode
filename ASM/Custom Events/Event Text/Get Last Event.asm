#To be inserted at 8024cffc
.include "../../Globals.s"

#Get total num of events in current page
	lwz r3,MemcardData(r13)
	lbz r3,CurrentEventPage(r3)
  bl  TotalNumOfEvents
  mflr r4
  lbzx r3,r3,r4
  b Exit

TotalNumOfEvents:
blrl
.byte GeneralTech.LastCustomEvent-8
.byte FoxTech.LastCustomEvent-8
.align 2

Exit:
  lwz	r0, 0x001C (sp)
