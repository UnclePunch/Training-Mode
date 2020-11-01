#To be inserted at 801dd980
.macro branchl reg, address
lis \reg, \address @h
ori \reg,\reg,\address @l
mtctr \reg
bctrl
.endm

.macro branch reg, address
lis \reg, \address @h
ori \reg,\reg,\address @l
mtctr \reg
bctr
.endm

.macro load reg, address
lis \reg, \address @h
ori \reg, \reg, \address @l
.endm

.macro loadf regf,reg,address
lis \reg, \address @h
ori \reg, \reg, \address @l
stw \reg,-0x4(sp)
lfs \regf,-0x4(sp)
.endm

.macro backup
mflr r0
stw r0, 0x4(r1)
stwu	r1,-0x100(r1)	# make space for 12 registers
stmw  r20,0x8(r1)
.endm

 .macro restore
lmw  r20,0x8(r1)
lwz r0, 0x104(r1)
addi	r1,r1,0x100	# release the space
mtlr r0
.endm

/*
I honestly cant believe this code is needed. Melee spawns the players at Y coordinate 300,
but the stage starts at Y coordinate 0. Because of this, when i get the coordinate of the
ground ID i want to spawn the players over, corneria is technically IN THE BLASTZONE.
Therefore, i spawn the players in the blastzone and it loads state on death, so it infinitely
kills the players and eventually crashes.

This code changes corneria's initialization code to move the ship, instead of waiting for the
per frame think function to do it. This way the stage is in the right position when i
request the coordinates.
*/

#Move Corneria
  mr r3,r30
  branchl r12,0x801c2fe0

#Original Codeline
lwz	r0, 0x0034 (sp)
