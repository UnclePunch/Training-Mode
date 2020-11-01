#To be inserted at 80236e00
.include "../../Globals.s"
.include "../../../m-ex/Header.s"

#CHECK FLAG IN RULES STRUCT
load	r4,0x804a04f0
lbz	r0, 0x0011 (r4)
cmpwi	r0,0x2
blt original

#CUSTOM CODE
rlwinm	r0, r3, 0, 16, 31
#lwz	r4,-0xdbc(rtoc)			#get frame data toggle bits
lwz	r4,-0x77C0(r13)
lwz	r4,0x1F24(r4)

li	r3, 1
slw	r0, r3, r0
and.	r0, r0, r4
beq	Off

On:
li	r3,0x1
b	exit
Off:
li	r3,0x0
b	exit

original:
branchl	r4,0x80164250
exit:
