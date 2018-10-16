#To be inserted at 80078950
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
stwu	r1,-0x100(r1)	# make space for 12 registers
stmw	r20,8(r1)	# push r20-r31 onto the stack
mflr r0
stw r0,0xFC(sp)
.endm

.macro restore
lwz r0,0xFC(sp)
mtlr r0
lmw	r20,8(r1)	# pop r20-r31 off the stack
addi	r1,r1,0x100	# release the space
.endm

.macro intToFloat reg,reg2
xoris    \reg,\reg,0x8000
lis    r18,0x4330
lfd    f16,-0x7470(rtoc)    # load magic number
stw    r18,0(r2)
stw    \reg,4(r2)
lfd    \reg2,0(r2)
fsubs    \reg2,\reg2,f16
.endm

.set ActionStateChange,0x800693ac
.set HSD_Randi,0x80380580
.set HSD_Randf,0x80380528
.set Wait,0x8008a348
.set Fall,0x800cc730

.set entity,31
.set player,31
.set playerdata,31

#Original Line
lwz	r7, 0x002C (r30)

#Check if this is a Pummel
lwz	r3,0x10(r7)
cmpwi	r3,0xD9
beq	Exit

#Allow for Cliff Attacks
cmpwi	r3,0x100
beq	Exit
cmpwi	r3,0x101
beq	Exit

#Check If Attacker Is Grabbable (Attacker is Set Grabbable When the Throw Releases the Victim)
lhz	r3,0x1A6A(r7)		#Grabbable Flag
cmpwi	r3,0x0
bne	SkipComboIncrement

#Check If Attacker Is Throwing, Allow Combo Inc
lwz	r3,0x10(r7)
cmpwi	r3,0xDB
blt	SkipThrowCheck
cmpwi	r3,0xDE
bgt	SkipThrowCheck
b	Exit
SkipThrowCheck:

#Check If Same Move ID as Last Hit
#lwz	r3,0x2C(r31)
#lhz	r3,0x18EC(r3)		#Last Move Instance Victim Was Hit By
#lhz	r4,0x2088(r7)		#Attacking Player's Current Move Instance
#cmpw	r3,r4
#beq	SkipComboIncrement

b	Exit

SkipComboIncrement:
branch	r12,0x8007897c

Exit:







