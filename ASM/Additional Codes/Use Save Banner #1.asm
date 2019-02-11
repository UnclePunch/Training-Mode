#To be inserted at 8001c838
.include "../Globals.s"

.set entity,31
.set player,31

#Check if Memcard
	lis	r3,0x8000
	lwz	r3,0x0(r3)
	load	r4,0x47544d45			#GTME
	cmpw	r3,r4
	beq	ISO

Memcard:
  li	r0, 2
  b Exit

ISO:
  li	r0, 1
Exit:
