#To be inserted at 8024d3e8
.include "../../../Globals.s"
.include "../../../../m-ex/Header.s"

.set PageID,31

#Get number of events on this page
	lwz r3,MemcardData(r13)
	lbz r3,CurrentEventPage(r3)
  rtocbl r12,TM_GetPageEventNum

#Check if event exists on this page
  cmpw r27,r3
  ble Exit

#Zero out Lv X text
  li  r3,0
  stw	r3, 0 (r23)
#Remove Text
  lwz r3,0x24(r23)
  branchl r12,Text_RemoveText
  li  r3,0
  stw r3,0x24(r23)
#Skip displaying this event
  branch r12,0x8024d4c8

Exit:
  li	r3, 0
