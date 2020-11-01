#To be inserted at 801a4b14
.include "../../Globals.s"
.include "../../../m-ex/Header.s"

# Finish storing function
    stw	r4, 0x0018 (r5)

# Check if DBLevel
    lwz	r0, -0x6C98 (r13)
    cmpwi r0,3
    bge isDebug

NoDebug:
# Clear these functions
    li  r0,0
    stw	r0, 0x0014 (r5)
    stw	r0, 0x0018 (r5)

isDebug:
#Run as normal
