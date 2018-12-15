#To be inserted at 801bab04
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

backup

mr r31,r3

#Loop through selected characters and load .ssm files
  mr r27,r31
  li  r28,0
  mulli r0,r28,36
  li  r29,0
  li  r30,0
Loop:
  lbz r3,0x70(r27)
  extsb r3,r3
  branchl r12,0x80026e84
  addi r28,r28,1
  cmpwi r28,6
  or r29,r29,r4
  or r30,r30,r3
  addi r27,r27,36
  blt Loop

#Clear Audio Cache?
  li r3,20
  branchl r12,0x80026f2c
#Request All ssm Files
  li  r3,4
  mr r5,r30
  mr r6,r29
  branchl r12,0x8002702c
#Load Preload Cache
  branchl r12,0x80027168

exit:
mr r3,r31
restore
addi	r4, r31, 2
