#To be inserted at 8008ff14
.include "../../Globals.s"
.include "../../../m-ex/Header.s"

.set entity,31
.set playerdata,31
.set player,30
.set text,29
.set textprop,28
.set hitbool,27

#Branch to Interrupt Check With Interrupt Bool in r3 and player in r4
mr	r4,r31
branchl	r12,0x80005504

branch	r12,0x8008ff1c
