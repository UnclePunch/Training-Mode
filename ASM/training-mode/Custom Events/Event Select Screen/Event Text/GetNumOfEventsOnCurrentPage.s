#To be inserted at 80005534
.include "../../../Globals.s"
.include "../../../../m-ex/Header.s"

.set EventID,31
.set PageID,30

backup

#Backup Requested Event
  mr EventID,r3

#Get Current Page
  lwz r3,MemcardData(r13)
  lbz PageID,CurrentEventPage(r3)
#Get pointer page's string array
	bl	SkipJumpTable

##### Page List #######
	EventJumpTable
#######################

SkipJumpTable:
  mflr	r4		#Jump Table Start in r4
  mulli	r5,PageID,0x4		#Each Pointer is 0x4 Long
  add	r4,r4,r5		#Get Event's Pointer Address
  lwz	r5,0x0(r4)		#Get bl Instruction
  rlwinm	r5,r5,0,6,29		#Mask Bits 6-29 (the offset)
  add	r5,r4,r5		#Gets Address in r4
  lwz r3,0x0(r5)
b exit

Minigames:
.long Minigames.NumOfEvents
.align 2
GeneralTech:
.long GeneralTech.NumOfEvents
.align 2
SpacieTech:
.long SpacieTech.NumOfEvents
.align 2

exit:
restore
blr
