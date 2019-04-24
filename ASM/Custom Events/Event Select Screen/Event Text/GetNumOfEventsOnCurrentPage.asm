#To be inserted at 80005534
.include "../../../Globals.s"

.set EventID,31
.set PageID,30

backup

#Backup Requested Event
  mr EventID,r3

#Get Current Page
  lwz r3,MemcardData(r13)
  lbz PageID,CurrentEventPage(r3)
  bl  EventNumbers
  mflr r3
  lbzx r3,r3,PageID

b exit

EventNumbers:
blrl
.byte GeneralTech.NumOfEvents
.byte SpacieTech.NumOfEvents
.align 2

exit:
restore
blr
