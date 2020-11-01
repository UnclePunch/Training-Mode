#To be inserted at 8010fb68
.include "../../../Globals.s"
.include "../../../../m-ex/Header.s"

.if PAL==1
nop
.endif

.if PAL==0
stw	r0, 0x21DC (r5)
.endif
