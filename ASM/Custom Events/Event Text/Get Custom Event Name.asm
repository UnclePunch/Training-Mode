#To be inserted at 80005524
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

.set EventID,31

backup

mr EventID,r3

#Check For Custom Event
  branchl r12,0x80005520
  cmpwi r3,0x0
  beq VanillaEvent
#Get Events Text
  bl	SkipJumpTable
  #bl	PlaceHolder
  #bl	PlaceHolder
  #bl	PlaceHolder
  bl	Event4
  bl	Event5
  bl	Event6
  bl	Event7
  bl	Event8
  bl	Event9
  bl	Event10
  bl	Event11
  bl	Event12
  bl	Event13
  bl	Event14
  bl	Event15
  bl	Event16
  bl	Event17
  bl	Event18
SkipJumpTable:
  mflr	r4		#Jump Table Start in r4
  subi	r5,EventID,0x3		#Start at Event 0, so 0-Index
  mulli	r5,r5,0x4		#Each Pointer is 0x4 Long
  add	r4,r4,r5		#Get Event's Pointer Address
  lwz	r5,0x0(r4)		#Get bl Instruction
  rlwinm	r5,r5,0,6,29		#Mask Bits 6-29 (the offset)
  add	r3,r4,r5		#Gets ASCII Address in r4
  b Exit

PlaceHolder:
.string "Placeholder"
.align 2

Event4:
#L-Cancel Training
.string "L-Cancel Training"
.align 2

Event5:
#Ledgedash Training
.string "Ledgedash Training"
.align 2

Event6:
#Eggs-ercise
.string "Eggs-ercise"
.align 2

Event7:
#SDI Training
.string "SDI Training"
.align 2

Event8:
#Reversal Training
.string "Reversal Training"
.align 2

Event9:
#Powershield Training
.string "Powershield Training"
.align 2

Event10:
#Shield Drop Training
.string "Shield Drop Training"
.align 2

Event11:
#Attack On Shield
.string "Attack On Shield"
.align 2

Event12:
#Ledge-Tech Training
.string "Ledge-Tech Training"
.align 2

Event13:
#Amsah-Tech Training
.string "Amsah-Tech Training"
.align 2

Event14:
#Combo Training
.string "Combo Training"
.align 2

Event15:
#Waveshine SDI
.string "Waveshine SDI"
.align 2

VanillaEvent:
li  r3,0

Exit:
restore
blr
