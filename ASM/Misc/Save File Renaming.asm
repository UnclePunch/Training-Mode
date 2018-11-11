#To be inserted at 8001c800
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
.set TextCreateFunction,0x80005928

.set entity,31
.set playerdata,31
.set player,30
.set text,29
.set textprop,28
.set hitbool,27


#Check For Game ID GTME (ISO)
lis	r11,0x8000
lwz	r11,0x0(r11)
load	r12,0x47544d45		#GTME
cmpw	r11,r12
beq	ISO
b	Memcard

ISO:
bl	ISOSaveName
mflr	r5
b	exit

Memcard:
bl	MemcardSaveName
mflr	r5
bl	MemcardStringFormat
mflr	r4
b	exit

ISOSaveName:
blrl
.long 0x54726169
.long 0x6e696e67
.long 0x204d6f64
.long 0x65206279
.long 0x20556e63
.long 0x6c655075
.long 0x6e636820
.long 0x20202020

ISOSaveDesc:
#blrl
.long 0x47616D65
.long 0x20446174
.long 0x61000000

MemcardSaveName:
blrl
.long 0x53757065
.long 0x7220536D
.long 0x61736820
.long 0x42726F73
.long 0x2E204D65
.long 0x6C656520
.long 0x20202020
.long 0x20202020

MemcardSaveDesc:
#blrl
.long 0x4d6f6420
.long 0x4c61756e
.long 0x63686572
.long 0x20283120
.long 0x6f662032
.long 0x29000000

MemcardStringFormat:
blrl
.long 0x25730000

exit:
branchl	r12,0x80323cf4
