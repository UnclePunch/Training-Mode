#To be inserted at 801bab28
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

stb	r0, 0x000A (r31)

#Get Current Event Number
lwz	r4, -0x77C0 (r13)
lbz	r7, 0x0535 (r4)

#Init Loop
bl	SSSEvents
mflr	r5
subi	r5,r5,0x1

#Loop Through Whitelisted Events
Loop:
lbzu	r6,0x1(r5)
extsb	r0,r6
cmpwi	r0,-1
beq	original
cmpw	r6,r7
beq	SSS
b	Loop

SSSEvents:
blrl
.byte 0x03,0x04,0x05,0x07,0x0B,0x0C,0x0D
.byte 0xFF
.align 2

SSS:
#Store SSS as Next Scene
load	r3,0x80479D30
li	r4,0x3
stb	r4,0x5(r3)
original:
