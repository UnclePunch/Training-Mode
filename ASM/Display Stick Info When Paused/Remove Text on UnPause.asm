#To be inserted at 8016cd78
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

.set PrevASStart,0x23F0
.set CurrentAS,0x10
.set OneASAgo,PrevASStart+(0*0x2)
.set TwoASAgo,PrevASStart+(1*0x2)
.set ThreeASAgo,PrevASStart+(2*0x2)
.set FourASAgo,PrevASStart+(3*0x2)
.set FiveASAgo,PrevASStart+(4*0x2)
.set SixASAgo,PrevASStart+(5*0x2)

.set FFVar,0x240C

#Original Codeline
  stb	r0, 0x0004 (r30)

#Get Text Struct
  load r3,0x804a1f58
  lwz r3,0x8(r3)
#Remove Text Struct
  branchl r12,0x803a5cc4

#Get GObj
  load r5,0x804a1f58
  lwz r3,0xC(r5)
#Zero Out Data
  li  r4,0
  stw r4,0x8(r5)
  stw r4,0xC(r5)
#Remove GObj
  branchl r12,0x80390228
