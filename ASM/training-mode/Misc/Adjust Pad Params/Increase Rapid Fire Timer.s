#To be inserted at 8037797c
.include "../../Globals.s"
.include "../../../m-ex/Header.s"

.set AltTimer,3

# Check if R is held
    lwz r0,0x0(r26)
    rlwinm. r0,r0,0,0x20
    beq Original
# Use new timer
    li  r0,AltTimer
    b   Exit

Original:
# Original timer
lwz	r0, 0x0010 (r30)

Exit: