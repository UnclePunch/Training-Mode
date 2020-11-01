#To be inserted at 80090924
.include "../../Globals.s"
.include "../../../m-ex/Header.s"

.set entity,31
.set playerdata,31
.set player,30
.set text,29
.set textprop,28
.set hitbool,27


#Check If Entered Fall
lwz	r4,0x10(r31)
cmpwi	r4,0x1D
bne	CheckToDisplay

li	r3,1

CheckToDisplay:
#Branch to Interrupt Check With Interrupt Bool in r3 and player in r4
mr	r4,r30
branchl	r12,0x80005504

lwz	r0, 0x001C (sp)
