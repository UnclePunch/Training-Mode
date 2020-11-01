#To be inserted at 802b7e54
.include "../../../Globals.s"
.include "../../../../m-ex/Header.s"

.if PAL==1
b 0x88
.endif

.if PAL==0
lbz	r3, 0x2240 (r31)
.endif
