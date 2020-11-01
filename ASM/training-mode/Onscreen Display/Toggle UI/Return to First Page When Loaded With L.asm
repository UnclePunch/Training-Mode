#To be inserted at 80235fe4
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

#CHECK FLAG IN RULES STRUCT
load	r3,0x804a04f0
lbz	r0, 0x0011 (r3)
cmpwi	r0,0x2
blt	original

#DETERMINE WHERE TO RETURN
cmpwi	r0,0x2
beq	LoadRulesFirstPage
cmpwi	r0,0x3
beq	LoadEvents

LoadRulesFirstPage:
branchl	r12,0x8023164c
b	exit

LoadEvents:
lwz	r3, -0x77C0 (r13)
lbz	r3, 0x0535 (r3)			#Get Last Event Match
li	r4,1			#No Delay On Text Loading
branchl	r12,0x8024e838
b	exit

original:
branchl	r12,0x802339fc
exit:
