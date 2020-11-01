#To be inserted at 80397c10
.include "../../Globals.s"

# Get inputs
lwz r3,0xC0(r31)
rlwinm. r0,r3,0,0x20
beq Exit
rlwinm. r0,r3,0,0x40
beq Exit
rlwinm. r0,r3,0,0x100
beq Exit
rlwinm. r0,r3,0,0x1000
beq Exit

#Reboot
li  r3,0
li  r4,0
li  r5,0
branchl r12,0x8034844c

Exit:
lbz	r0, 0 (r31)