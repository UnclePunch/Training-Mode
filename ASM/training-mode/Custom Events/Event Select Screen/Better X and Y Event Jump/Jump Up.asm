#To be inserted at 8024dabc
.include "../../../Globals.s"
.include "../../../../m-ex/Header.s"

.set EventID,31
.set PageID,30
.set NumOfEvents,30

backup

#Get Current Event
	lbz	r3,0x0(r28)
	lwz	r4,0x4(r28)
	add	EventID,r3,r4

#Check if already on first event
  cmpwi EventID,0
  ble exit

#Jump 9 events
  subi  r3,EventID,9
#Check if exceeded 0
  cmpwi r3,0
  ble FirstEvent

JumpEvent:
#sub 9 from event ID
  lbz	r3,0x0(r28)
  subi r3,r3,9
  stb r3,0x0(r28)
  b UpdateText

FirstEvent:
	li	r3,0
	stb r3,0x0(r28)
	stw r3,0x4(r28)
  b UpdateText

UpdateText:
#overflow event ID to scroll ID
  lbz r3,0x0(r28)
	extsb r3,r3
  cmpwi r3,0
  bge UpdateText1
#get overflow and add to scroll
  lwz r4,0x4(r28)
  add r3,r3,r4
  stw r3,0x4(r28)     #add to scroll
  li  r3,0
  stb r3,0x0(r28)

UpdateText1:
#Play SFX and Update Text
  li  r3,2
  branchl r12,0x80024030
  restore
  branch r12,0x8024daf8

exit:
  restore
  branch r12,0x8024e198
