#To be inserted at 800789e0
.include "../../../Globals.s"
.include "../../../../m-ex/Header.s"

#r31 = Projectile Data
#r30 = Victim GObj

#Check If Same Move ID as Last Hit
lwz	r3,0x2C(r30)
lhz	r3,0x18EC(r3)		#Last Move Instance Victim Was Hit By
lhz	r4,0xDA8(r31)		#Attacking Player's Current Move Instance
cmpw	r3,r4
beq	SkipComboIncrement

b	Exit

SkipComboIncrement:
branch	r12,0x80078a10

Exit:
lwz	r3, 0x0518 (r31)
