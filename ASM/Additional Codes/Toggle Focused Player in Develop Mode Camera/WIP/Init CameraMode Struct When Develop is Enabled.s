#To be inserted at 8016e898
.include "../../Globals.s"

lwz	r0, -0x6C98 (r13)
cmpwi r0,3
blt Original

branchl r12,0x8002fc7c

Original:
lis	r3, 0x8047
