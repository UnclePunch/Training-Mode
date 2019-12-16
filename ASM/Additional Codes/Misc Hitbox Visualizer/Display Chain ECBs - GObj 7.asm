#To be inserted at 800593dc
.include "../../Globals.s"

.set  REG_CurrentGObj,31
.set  REG_GX,30

backup

  lis  REG_GX,0xcc01

#Draw location of all chains (0x28)
  lwz	r3, -0x3E74 (r13)
  lwz REG_CurrentGObj,0x28(r3)
  b Loop_CheckNext

Loop:
.set  REG_CurrentGObjData,29

#Get Data
  lwz REG_CurrentGObjData,0x2C(REG_CurrentGObj)
/*
#Draw TopN
  lwz	r10, -0x7920 (rtoc)
  lwz	r9, -0x791C (rtoc)
  lwz	r8, -0x7918 (rtoc)
  lwz	r7, -0x7914 (rtoc)
  lwz	r6, -0x7910 (rtoc)
  lwz	r5, -0x790C (rtoc)
  lwz	r4, -0x7908 (rtoc)
  lwz	r0, -0x7924 (rtoc)
  stw	r10, 0x00DC (sp)
  stw	r9, 0x00D8 (sp)
  stw	r8, 0x00D4 (sp)
  stw	r7, 0x00D0 (sp)
  stw	r6, 0x00CC (sp)
  stw	r5, 0x00C8 (sp)
  stw	r4, 0x00C4 (sp)
  stw	r0, 0x00C0 (sp)
  branchl r12,0x80058ACC
  li	r3, 168
  li	r4, 0
  li	r5, 4
  branchl r12,0x8033D0DC
  lfs	f3, 0x4C (REG_CurrentGObjData)    #X offset?
  lfs	f2, -0x7964 (rtoc)
  lfs	f4, 0x50 (REG_CurrentGObjData)    #Y offset?
  fsubs	f1,f3,f2
  lfs	f5, 0x54 (REG_CurrentGObjData)    #Z Offset
  fadds	f0,f2,f3
  fsubs	f6,f4,f2
  stfs	f1, -0x8000 (r30)
  fadds	f1,f2,f4
  stfs	f4, -0x8000 (r30)
  stfs	f5, -0x8000 (r30)
  stfs	f0, -0x8000 (r30)
  stfs	f4, -0x8000 (r30)
  stfs	f5, -0x8000 (r30)
  stfs	f3, -0x8000 (r30)
  stfs	f6, -0x8000 (r30)
  stfs	f5, -0x8000 (r30)
  stfs	f3, -0x8000 (r30)
  stfs	f1, -0x8000 (r30)
  stfs	f5, -0x8000 (r30)
*/
#Check if collision is up to date
  lwz	r0, -0x51F4 (r13)
  lwz	r4, 0x0038+48 (REG_CurrentGObjData)
  cmpw  r0,r4
  bne Loop_Inc
#Draw ECB
  addi  r3,REG_CurrentGObjData,48
  branchl r12,0x80058b5c
#Check if more
Loop_Inc:
  lwz REG_CurrentGObj,0x8(REG_CurrentGObj)
Loop_CheckNext:
  cmpwi REG_CurrentGObj,0
  bne Loop

Exit:
  restore
  lmw	r26, 0x0118 (sp)
