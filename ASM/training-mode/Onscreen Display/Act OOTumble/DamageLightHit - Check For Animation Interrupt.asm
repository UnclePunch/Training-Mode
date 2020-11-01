#To be inserted at 8008f914
.include "../../Globals.s"
.include "../../../m-ex/Header.s"

#Branch to Interrupt Check With Interrupt Bool in r3 and player in r4
mr	r4,r31
branchl	r12,0x80005504

branch	r12,0x8008f920
