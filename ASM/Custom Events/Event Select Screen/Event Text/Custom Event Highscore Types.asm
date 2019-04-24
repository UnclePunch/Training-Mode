#To be inserted at 801beb8c
.include "../../../Globals.s"

.set EventID,31
.set PageID,30

.set KO,0x0
.set Time,0x1

backup

#Backup Requested Event
  mr EventID,r3

#Get Current Page
  lwz r3,MemcardData(r13)
  lbz PageID,CurrentEventPage(r3)
  bl  SkipPageList

##### Page List #######

  bl  GeneralTech
  bl  SpacieTech

##########################
GeneralTech:
.byte KO
.byte KO
.byte KO
.byte KO
.byte KO
.byte KO
.byte KO
.byte KO
.byte KO
.byte KO
.byte KO
.align 2

SpacieTech:
.byte KO
.align 2
##########################

SkipPageList:
  mflr	r4		#Jump Table Start in r4
  mulli	r5,PageID,0x4		#Each Pointer is 0x4 Long
  add	r4,r4,r5		#Get Event's Pointer Address
  lwz	r5,0x0(r4)		#Get bl Instruction
  rlwinm	r5,r5,0,6,29		#Mask Bits 6-29 (the offset)
  add	r4,r4,r5		#Gets ASCII Address in r4
#Get Byte
  lbzx	r3,EventID,r4

exit:
restore
blr
