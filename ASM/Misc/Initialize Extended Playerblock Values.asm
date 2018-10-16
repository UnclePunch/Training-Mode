#To be inserted at 80068eec
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
stwu	r1,-68(r1)	# make space for 12 registers
stmw	r20,8(r1)	# push r20-r31 onto the stack
mflr r0
stw r0,64(sp)
.endm

.macro restore
lwz r0,64(sp)
mtlr r0
lmw	r20,8(r1)	# pop r20-r31 off the stack
addi	r1,r1,68	# release the space
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

.set ExtendedBlockLength,0x23EC

#Backup Data Pointer After Creation
addi	r30, r3, 0

####################################
## Clear Playerblock up to 0x2200 ##
####################################
li	r4,0x2200
branchl	r12,0x8000c160

#Get To Extended Portion
addi	r3,r30,0x23EC		#Original PB Length

#Get Player Data Length
load	r4,0x80458fd0
lwz	r4,0x20(r4)

#Extended Playerblock Length
subi	r4,r4,0x23EC

#Zero Entire Data Block Before Initializing
branchl	r12,0x8000c160


exit:
mr	r3,r30
lis	r4, 0x8046


