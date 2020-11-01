#To be inserted at 801bb128
.include "../Globals.s"
.include "../../m-ex/Header.s"

#Branch to C function to initialize the event
  lwz r3,MemcardData(r13)
  lbz r3,CurrentEventPage(r3)
	mr	r4,r25									#event
	mr	r5,r26									#match struct
	rtocbl	r12,TM_EventInit
	
#Exit
	branch	r12,0x801bb738
