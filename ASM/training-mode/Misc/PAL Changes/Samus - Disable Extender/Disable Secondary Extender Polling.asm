#To be inserted at 802b808c
.include "../../../Globals.s"
.include "../../../../m-ex/Header.s"

.if PAL==1
b 0x84
.endif

.if PAL==0
cmpwi	r3, 2
.endif
