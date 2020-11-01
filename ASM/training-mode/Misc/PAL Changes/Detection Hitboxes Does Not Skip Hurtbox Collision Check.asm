#To be inserted at 800796e0
.include "../../Globals.s"
.include "../../../m-ex/Header.s"

.if PAL==1
nop
.endif

.if PAL==0
li	r18, 1
.endif
