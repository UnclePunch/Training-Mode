#To be inserted at 8024da98
.include "../../../Globals.s"
.include "../../../../m-ex/Header.s"

#Update cursor position
#Get Texture Data
	lwz	r3, -0x4A40 (r13)
	lwz	r3, 0x0028 (r3)
	addi r4,sp,0x40
	li	r5,11
	li	r6,-1
	crclr	6
	branchl r12,0x80011e24
#Get New Y Offset
	lis	r0,0x4330
	stw r0,0xA8(sp)
	lwz	r3, -0x4A40 (r13)
	lwz	r3, 0x002C (r3)
	lbz	r3,0x0(r3)			#event selection ID
	stw r3,0xAC(sp)
	lfd f1,0xA8(sp)
	lfd	f2, -0x3888 (rtoc)
	fsubs f1,f1,f2
	bl	Float
	mflr r3
	lfs f2,0x0(r3)
	fmuls f1,f1,f2
#Change Y offset
	lwz r3,0x40(sp)
	stfs f1,0x3C(r3)
#DirtySub
	lwz r3,0x40(sp)
	branchl r12,0x803732e8
	b	Original

Float:
blrl
.float -1.32

Original:
	mr	r3,r28
