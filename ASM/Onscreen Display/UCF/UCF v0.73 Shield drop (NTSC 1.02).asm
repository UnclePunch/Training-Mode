#To be inserted at 800998A4
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

##########################################################
## 804a1f5c -> 804a1fd4 = Static Stock Icon Text Struct ##
## Is 0x80 long and is zero'd at the start              ##
##  of every VS Match				                        ##
## Store Text Info here                                 ##
##########################################################


	#CHECK IF ENABLED
	li	r0,0x1B			#PowerShield ID
	lwz	r4,-0x77C0(r13)
	lwz	r4,0x1F24(r4)
	li	r5, 1
	slw	r0, r5, r0
	and.	r0, r0, r4
	beq	loc_0xE4




loc_0x0:
  lwz r3, 44(r3)
  lfs f1, 1596(r3)
  lwz	r5, -0x514C (r13)
  lfs f0, 788(r5)
  fcmpo cr0, f1, f0
  ble- loc_0xE4
  lis r4, 0x42A0
  stw r4, -12(r1)
  lis r4, 0x3727
  stw r4, -8(r1)
  lis r4, 0x4330
  stw r4, -28(r1)
  lfs f0, 1568(r3)
  li r0, 0x0

loc_0x34:
  fabs f0, f0
  lfs f1, -12(r1)
  fmuls f0, f0, f1
  lfs f1, -8(r1)
  fsubs f0, f0, f1
  fctiwz f0, f0
  stfd f0, -20(r1)
  lwz r4, -16(r1)
  addi r4, r4, 0x2
  xoris r4, r4, 32768
  stw r4, -24(r1)
  lfd f0, -28(r1)
  lfd f1, -29808(r2)
  fsubs f0, f0, f1
  lfs f1, -12(r1)
  fdivs f0, f0, f1
  cmpwi r0, 0x0
  bne- loc_0x8C
  li r0, 0x1
  stfs f0, -32(r1)
  lfs f0, 1572(r3)
  b loc_0x34

loc_0x8C:
  lfs f1, -32(r1)
  fmuls f1, f1, f1
  fmuls f0, f0, f0
  fadds f0, f0, f1
  lfs f1, -30380(r2)
  fcmpo cr0, f0, f1
  cror 2, 1, 2
  bne- loc_0xE4
  lbz r4, 1648(r3)
  cmpwi r4, 0x3
  ble- loc_0xE4
  lfs f0, 44(r5)
  fneg f0, f0
  lfs f1, 1572(r3)
  fcmpo cr0, f0, f1
  bge- loc_0xE4
  lwz r3, 28(r1)
  addi r3, r3, 0x8
  lwz r31, 20(r1)
  addi r1, r1, 0x18
  mtlr r3
  blr

loc_0xE4:
  mr r3, r30
  lwz r4, 44(r3)
