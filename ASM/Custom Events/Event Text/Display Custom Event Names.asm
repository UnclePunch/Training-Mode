#To be inserted at 8024d470
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

#r24 = text struct
#r27 = Event ID

#Check For Custom Event
  mr r3,r27
  branchl r12,0x80005524
  cmpwi r3,0x0
  beq VanillaEvent

CustomEvent:
.set text,24

#Create Text
  li  r3,0
  li  r4,1
  branchl r12,0x803a6754
  mr  text,r3

#Store pointer to text so it can be removed by the game
  stw text,0x0(r23)

#Set Text Values
  lfs	f1, 0x0030 (r31)
  lfs	f4, 0x007C (sp)
  fadds	f1,f4,f1
  lfs	f0, 0x0034 (r31)
  fadds	f2,f31,f0
  lfs	f3, -0x3874 (rtoc)
  lfs	f4, -0x386C (rtoc)
  lfs	f5, -0x3868 (rtoc)
  stfs f1,0x00(text)
  stfs f2,0x04(text)
  stfs f3,0x08(text)
  stfs f4,0x0C(text)
  stfs f5,0x10(text)
  lfs	f0, -0x3878 (rtoc)
  stfs	f0, 0x0024 (text)
  stfs	f0, 0x0028 (text)

backup

#Copy Header to Text Allocation
  lwz r3,0x5C(text)       #Get Pointer to Next Available Menu Text Location
  li  r4,0x1618
  sth r4,0x0(r3)

#Get ASCII
  mr r3,r27
  branchl r12,0x80005524

#Convert To Menu Text
  mr  r4,r3               #ASCII To Store
  addi r3,sp,0x40
  branchl r12,0x803a67ec
#Backup Length
  mr r20,r3

#Copy Text to Text Allocation
  mr  r5,r20               #Length
  lwz r3,0x5C(text)       #Get Pointer to Next Available Menu Text Location
  addi r3,r3,0x2         #Skip Past Header
  addi r4,sp,0x40
  branchl r12,0x800031f4

#Add Terminator
  li  r3,0x1900
  lwz r4,0x5C(text)
  add r4,r4,r20
  sth r3,0x2(r4)

#Exit
  restore
  branch r12,0x8024d4c8

TextHeader:
blrl
.long 0x16180000

VanillaEvent:
Original:
  lfs	f0, 0x0034 (r31)
