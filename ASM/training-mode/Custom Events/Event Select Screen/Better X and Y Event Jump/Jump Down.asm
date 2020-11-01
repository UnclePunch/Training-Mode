#To be inserted at 8024d998
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

#Get Current Page
  lwz r3,MemcardData(r13)
  lbz PageID,CurrentEventPage(r3)
#Get pointer page's string array
	bl	SkipJumpTable

##### Page List #######
	EventJumpTable
#######################

SkipJumpTable:
#Get number of events on this page
  mflr	r4		#Jump Table Start in r4
  mulli	r5,PageID,0x4		#Each Pointer is 0x4 Long
  add	r4,r4,r5		#Get Event's Pointer Address
  lwz	r5,0x0(r4)		#Get bl Instruction
  rlwinm	r5,r5,0,6,29		#Mask Bits 6-29 (the offset)
  add	r5,r4,r5		#Gets Address in r4
  lwz NumOfEvents,0x0(r5)

#Check if already on last event
  cmpw EventID,NumOfEvents
  bge exit

#Jump 9 events
  addi  r3,EventID,9
#Check if exceeded NumOfEvents
  cmpw r3,NumOfEvents
  bge LastEvent

JumpEvent:
#add 9 to event ID
  lbz	r3,0x0(r28)
  addi r3,r3,9
  stb r3,0x0(r28)
  b UpdateText

LastEvent:
#if NumOfEvents >= 9, event ID = 9, scroll ID = NumOfEvents-8
  cmpwi NumOfEvents,9
  blt LessThan9Events
GreaterThan9Events:
  li  r3,8
  stb	r3,0x0(r28)
  subi r3,NumOfEvents,8
  stw r3,0x4(r28)
  b UpdateText
LessThan9Events:
#if NumOfEvents < 9, event ID = NumOfEvents, scroll ID = 0
  stb	NumOfEvents,0x0(r28)
  li  r3,0
  stw r3,0x4(r28)
  b UpdateText

#############################
EventAmountPerPage
##############################

UpdateText:
#overflow event ID to scroll ID
  lbz r3,0x0(r28)
  cmpwi r3,8
  ble 0x1C
#get overflow and add to scroll
  subi r3,r3,8
  lwz r4,0x4(r28)
  add r3,r3,r4
  stw r3,0x4(r28)     #add to scroll
  li  r3,8
  stb r3,0x0(r28)
#now Correct Scroll
  lwz r3,0x4(r28)
  subi r4,NumOfEvents,8
  cmpw r3,r4
  ble UpdateText1
#Highlight last entry
  cmpwi NumOfEvents,8
  bgt 0x10
  mr  r3,NumOfEvents
  li  r4,0
  b 0x8
  li  r3,8          #highlight last entry
  stb	r3,0x0(r28)
  stw r4,0x4(r28)   #last scroll

UpdateText1:
#Play SFX and Update Text
  li  r3,2
  branchl r12,0x80024030
  restore
  branch r12,0x8024d9dc

exit:
  restore
  branch r12,0x8024e198
