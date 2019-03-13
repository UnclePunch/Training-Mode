#To be inserted at 801beb8c
.include "../../Globals.s"

#0x0 = KOs
#0x1 = Time

backup
bl	EventTypes
mflr	r4
lbzx	r3,r3,r4

b	exit

EventTypes:
blrl
.long 0x01010100
.long 0x00000000
.long 0x00000000
.long 0x00000001
.long 0x01010001
.long 0x01010101
.long 0x01010101
.long 0x01010000
.long 0x01010101
.long 0x01010101
.long 0x01010101
.long 0x01010101
.long 0x01010101

exit:
restore
blr
