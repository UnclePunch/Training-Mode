#To be inserted at 803ce4d4
.include "../../Globals.s"
.include "../../../m-ex/Header.s"

.if PAL==1
.long 0x00240464
.endif

.if PAL==0
.long 0x00200000
.endif
