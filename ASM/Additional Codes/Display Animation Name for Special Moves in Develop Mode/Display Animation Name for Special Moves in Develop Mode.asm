#To be inserted at 80226acc
.include "../../Globals.s"

.set entity,31
.set playerdata,28
.set player,29

#Get Animation Data Pointer
mr	r3,playerdata
lwz	r4,0x14(playerdata)
branchl	r12,0x80085fd4

#Get Move Name String
lwz	r3,0x0(r3)

#Get Start of Move Name
StringSearchLoop:
lbzu	r4,0x1(r3)
cmpwi	r4,0x4E		#Check For "N"
bne	StringSearchLoop
lbzu	r4,0x1(r3)
cmpwi	r4,0x5F		#Check for Underscore
bne	StringSearchLoop
addi	r3,r3,0x1		#Start of Move Name in r3

#Copy Move Name To Cut Off "fiagtree" Text
bl	StringSpace
mflr	r5
subi	r4,r5,0x1
subi	r3,r3,0x1
StringCopyLoop:
lbzu	r6,0x1(r3)
cmpwi	r6,0x5F		#Check for Underscore
beq	ExitCopyLoop
stbu	r6,0x1(r4)
b	StringCopyLoop

ExitCopyLoop:
li	r3,0x0
stbu	r3,0x1(r4)
mr	r4,r5
b	exit

StringSpace:
blrl
.long 0x00000000
.long 0x00000000
.long 0x00000000
.long 0x00000000
.long 0x00000000
.long 0x00000000
.long 0x00000000

exit:
mr	r3,r31
crclr 	6
