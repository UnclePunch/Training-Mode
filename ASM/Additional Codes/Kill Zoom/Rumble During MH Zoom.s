#To be inserted at 8002e6e0
.include "../../Globals.s"

subi  sp,sp,0x30

#Get some camera data
  addi  r3,sp,0x1C
  load  r4,0x80452c7c
  branchl r12,0x8002958c

#Get rumble data
  addi  r3,sp,0x1C
  branchl r12,0x8002a28c

#Apply rumble
  addi  r3,sp,0x1C
  load  r4,0x80452c7c
  branchl r12,0x8002a0c0

addi  sp,sp,0x30

lwz	r0, 0x003C (sp)
