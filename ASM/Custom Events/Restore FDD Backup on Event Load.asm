#To be inserted at 8022e8d8
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
stmw	r3,8(r1)	# push r20-r31 onto the stack
mflr r0
stw r0,0xFC(sp)
.endm

.macro restore
lwz r0,0xFC(sp)
mtlr r0
lmw	r3,8(r1)	# pop r20-r31 off the stack
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

#Check If First Boot
CheckIfFirstBoot:
lbz	r5,-0xDA4(rtoc)
cmpwi	r5,0x0
beq	RestoreBackup
#On First Boot
#Backup Instead of Restoring
lwz	r6,-0x77C0(r13)
lwz	r5,0x1F24(r6)
stw	r5,-0xDA8(rtoc)
#Remove Boot Flag
li	r5,0x0
stb	r5,-0xDA4(rtoc)

b	Exit

#Restore FDD Backup
RestoreBackup:
lwz	r5,-0xDA8(rtoc)
lwz	r6,-0x77C0(r13)
stw	r5,0x1F24(r6)

Exit:

#Ensure Event 4+ is Selected
cmpwi	r3,0x2
bgt	0x8
li	r3,0x3

#Original Line
li	r4, 0

