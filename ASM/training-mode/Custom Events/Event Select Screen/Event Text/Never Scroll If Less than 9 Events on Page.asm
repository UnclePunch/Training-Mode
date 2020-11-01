#To be inserted at 8024e438
.include "../../../Globals.s"
.include "../../../../m-ex/Header.s"

#Original Codeline
  addi	r30, r3, 0

#First check if page has 9 events
	lwz r3,MemcardData(r13)
	lbz r3,CurrentEventPage(r3)
  rtocbl r12,TM_GetPageEventNum
  cmpwi r3,9
  bge Original
#Set no scroll
  li  r0,0
  stw r0,0x4(r30)
#Set selection
  stb r31,0x0(r30)
#Exit
  branch r12,0x8024e464
Original:
  addi	r3, r30, 0
