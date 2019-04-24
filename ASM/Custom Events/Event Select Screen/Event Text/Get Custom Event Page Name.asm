#To be inserted at 8000552c
.include "../../../Globals.s"

.set PageID,31

backup

mr PageID,r3

#Get Events Text
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
  add	r3,r4,r5		#Gets ASCII Address in r4
  b Exit

Minigames:
.string "Minigames"
.align 2

GeneralTech:
.string "Universal Tech"
.align 2

SpacieTech:
.string "Spacie Tech"
.align 2

Exit:
restore
blr
