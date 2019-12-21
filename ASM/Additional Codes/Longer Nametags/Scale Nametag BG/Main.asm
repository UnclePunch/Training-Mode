#To be inserted at 802fcfc8
.include "../../../Globals.s"

#Original
  stfs	f0, 0x002C (r28)

#Check if HMN
  mr  r3,r27
  branchl r12,PlayerBlock_LoadSlotType
  cmpwi r3,0
  bne Exit
#Get nametag ID
  mr  r3,r27
  branchl r12,PlayerBlock_LoadNameTagSlot #0x8003556c
  cmpwi r3,120
  beq Exit
#Get nametag text
  branchl r12,Nametag_LoadNametagSlotText #0x8023754c

#Count letters
  subi  r3,r3,2
  li  r5,0
CountLetterLoop:
  lbzu  r4,0x2(r3)
  cmpwi r4,0
  beq CountLetterLoop_Exit
  addi  r5,r5,1
  b CountLetterLoop
CountLetterLoop_Exit:
#Normal size if 4 or less
  cmpwi r5,4
  ble Exit
#Cast to float
  li  r3,0
  subi  r4,r5,4
  branchl r12,cvt_sll_flt
  bl  Floats
  mflr  r3
  lfs f2,0x0(r3)
  lfs f3,0x2C(r28)
  fdivs f2,f3,f2
  fmuls f1,f1,f2
  fadds f1,f1,f3
  stfs	f1, 0x002C (r28)
  b Exit

Floats:
  blrl
  .float 4

  Exit:
