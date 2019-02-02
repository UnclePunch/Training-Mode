#To be inserted at 80040f04
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

#r27 = Attacker Slot
#r28 = Victim Slot

#r5 = Attacker
#r6 = Victim

#This injection makes the Pummel Move ID skip the combo count increment. Originally only 5 moves perform this behavior, pummel not being one of them.




#Get Attacker Pointer
	mr	r3,r27
	branchl	r12,0x80034110
	lwz	r5,0x2C(r3)
#Get Victim Pointer
	mr	r3,r28
	branchl	r12,0x80034110
	lwz	r6,0x2C(r3)



######################
## Check For Pummel ##
######################

	cmpwi	r30,0x34
	beq	NoComboInc

#################################
## Check For Same Move as Last ##
#################################

SameMoveCheck:
	lhz	r3,0x18EC(r6)		#Last Move Instance Victim Was Hit By
	lhz	r4,0x2088(r5)		#Attacking Player's Current Move Instance
	cmpw	r3,r4
	bne	SkipSameMoveCheck
#Check If Its a Throw
	cmpwi	r30,0x35
	blt	NoComboInc
	cmpwi	r30,0x38
	bgt	NoComboInc
#Check If Attacker Is Grabbable (Attacker is Set Grabbable When the Throw Releases the Victim)
	lhz	r3,0x1A6A(r5)		#Grabbable Flag
	cmpwi	r3,0x0
	bne	NoComboInc
	b	Original
	SkipSameMoveCheck:

################################
## Check For MidGrab Hitboxes ##
################################

#Allow Cliff Attacks
	cmpwi	r30,0x3F
	beq	Original
	cmpwi	r30,0x3E
	beq	Original

#Check If Attacker Is Grabbable (Attacker is Set Grabbable When the Throw Releases the Victim)
	lhz	r3,0x1A6A(r5)		#Grabbable Flag
	cmpwi	r3,0x0
	bne	NoComboInc

	b	Original



NoComboInc:
#Spoof Pummel as Some Other Move that Triggers the Check
	li	r30,76

Original:
addi	r3, r28, 0
