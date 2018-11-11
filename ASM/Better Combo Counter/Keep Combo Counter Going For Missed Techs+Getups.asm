#To be inserted at 8006ab48
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

#Am I in Hitstun? (Ran prior to the injection)

#Am I in Missfoot?
lwz	r3,0x10(playerdata)
cmpwi	r3,0xFB
beq	ContinueCombo

#Am I in Non-IASA Landing?
cmpwi	r3,0x2A
bne	SkipIASALandingCheck
lfs	f1, 0x0894 (playerdata)
lfs	f0, 0x01F4 (playerdata)
fcmpo	cr0,f1,f0
blt	ContinueCombo
SkipIASALandingCheck:

#Am I in Missed Tech, Tech Roll, Slow Getup, Or Getup Attack
lwz	r0,0x10(playerdata)
cmpwi	r0,0xB7
blt	EndCombo
cmpwi	r0,0xC9
bgt	CheckGrab
b	ContinueCombo

CheckGrab:
cmpwi	r0,0xDF
blt	EndCombo
cmpwi	r0,0xE8
bgt	CheckThrow
b	ContinueCombo

CheckThrow:
cmpwi	r0,0xEF
blt	EndCombo
cmpwi	r0,0xF3
bgt	CheckSpecialThrows
b	ContinueCombo

CheckSpecialThrows:
cmpwi	r0,0x10A
blt	EndCombo
cmpwi	r0,0x130
bgt	EndCombo
b	ContinueCombo

ContinueCombo:
branch	r12,0x8006ab58

EndCombo:
lbz	r4, 0x221F (r31)
