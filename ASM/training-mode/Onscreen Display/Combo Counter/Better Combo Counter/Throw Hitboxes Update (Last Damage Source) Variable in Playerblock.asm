#To be inserted at 800dde68
.include "../../../Globals.s"
.include "../../../../m-ex/Header.s"

.set entity,31
.set player,31
.set playerdata,31

#Store/Update Last Damage Source For Victim
stw	r24,0x1868(r30)

Exit:
#Original Line
lwz	r0, 0x1988 (r30)
