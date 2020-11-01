#To be inserted at 80016714
.include "../../Globals.s"

mftbl	r4
stw	r4,-8(rtoc)

lwz	r4, 0 (r28)
