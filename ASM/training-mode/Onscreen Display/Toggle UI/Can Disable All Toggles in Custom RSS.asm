#To be inserted at 80236064
.include "../../Globals.s"
.include "../../../m-ex/Header.s"

#CHECK FLAG IN RULES STRUCT
load	r3,0x804a04f0
lbz	r0, 0x0011 (r3)
cmpwi	r0,0x2
blt	original


#REMOVE CUSTOM TEXT
li	r0, 0
b	exit

original:
li	r0, 1
exit:
