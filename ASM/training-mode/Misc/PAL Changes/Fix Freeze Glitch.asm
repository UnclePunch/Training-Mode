#To be inserted at 801239a8
.include "../../Globals.s"
.include "../../../m-ex/Header.s"

.if PAL==1
nop
.endif

.if PAL==0
stw	r0, 0x1A5C (r31)
.endif
