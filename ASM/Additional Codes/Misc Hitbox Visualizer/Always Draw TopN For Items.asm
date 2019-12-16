#To be inserted at 800593b0
.include "../../Globals.s"

backup

lwz r31,0x2C(r28)

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
  lfs	f3, 0x4C (r31)    #X offset?
  lfs	f2, -0x7964 (rtoc)
  lfs	f4, 0x50 (r31)    #Y offset?
  fsubs	f1,f3,f2
  lfs	f5, 0x54 (r31)    #Z Offset
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

Exit:
  restore
  branch r12,0x800593d0
