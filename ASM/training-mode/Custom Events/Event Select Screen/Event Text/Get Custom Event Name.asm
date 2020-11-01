#To be inserted at 80005524
.include "../../../Globals.s"

.set EventID,31
.set PageID,30

backup

#Backup Requested Event
  mr EventID,r3

#Get Current Page
  lwz r3,MemcardData(r13)
  lbz PageID,CurrentEventPage(r3)
  bl  SkipPageList

##### Page List #######
	EventJumpTable
#######################
  EventNameStrings
#######################
SkipPageList:
  mflr	r4		#Jump Table Start in r4
  mulli	r5,PageID,0x4		#Each Pointer is 0x4 Long
  add	r4,r4,r5		#Get Event's Pointer Address
  lwz	r5,0x0(r4)		#Get bl Instruction
  rlwinm	r5,r5,0,6,29		#Mask Bits 6-29 (the offset)
#Get String
  mr  r3,EventID
  add	r4,r4,r5		#Gets ASCII Address in r4
  branchl r12,SearchStringTable


#######################

Exit:
restore
blr
