#To be inserted at 8021819c
.include "../../Globals.s"

.set LayoutCount,8

#Get rand number
  li r3,LayoutCount
  branchl r12,HSD_Randi
#Get rand layout
  bl  Layouts
  mflr  r5
  lbzx  r5,r3,r5
  b Exit

Layouts:
blrl
.byte 0,1,/*2,*/3,13,18,20,21,22
.align 2

Exit:
  mr	r3, r30
  lwz	r4, 0x0014 (r29)
  branchl r12,0x801c8138
  mr  r3,r30
  branchl r12,0x801c2fe0
