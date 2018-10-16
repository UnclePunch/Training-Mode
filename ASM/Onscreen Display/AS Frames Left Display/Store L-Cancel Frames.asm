#To be inserted at 8008d698
cmpw	r5, r0
bge	NoLCancel

OnLCancel:
lfs	f3, 0x00E8 (r6)
fdivs	f3,f1,f3
fctiwz	f3,f3
stfd	f3, 0x0028 (sp)
lwz	r7, 0x002C (sp)

b	exit

NoLCancel:
fctiwz	f3,f1
stfd	f3, 0x0028 (sp)
lwz	r7, 0x002C (sp)

exit:
lwz	r8,0x2C(r3)
stw	r7,0x2340(r8)		#store to pb
cmpw	r5, r0