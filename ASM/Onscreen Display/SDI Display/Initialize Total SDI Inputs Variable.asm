#To be inserted at 8008f71c
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
stmw  r3,0x8(r1)
.endm

.macro restore
lmw  r3,0x8(r1)
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

.set SDIInputs,0x2350
.set PreviousMoveInstanceHitBy,0x2418

##########################################################
## 804a1f5c -> 804a1fd4 = Static Stock Icon Text Struct ##
## Is 0x80 long and is zero'd at the start              ##
##  of every VS Match				                        ##
## Store Text Info here                                 ##
##########################################################

#Get Victims Data
  lwz r6,0x2C(r31)
#Get Attacker GObj
  lwz r5,0x1868(r6)
#If Pointer doesn't exist, its most likely environmental damage (break the targets walls)
  cmpwi r5,0x0
  beq ResetSDICount
#Check if Player
  lhz r0,0(r5)        #Entity Type
  lwz r5,0x2C(r5)     #Get Attacker Data
  cmpwi r0,4          #Player
  beq LastPlayerMove
  cmpwi r0,6          #Item
  beq LastItemMove
  b  exit             #If neither, exit

LastPlayerMove:
#Get current Move Instance from attacker
  lhz r4,0x2088(r5)
  b   GetLastMoveVictimHitBy
LastItemMove:
#Get current Move Instance from attacker
  lhz r4,0xDA8(r5)

GetLastMoveVictimHitBy:
#Get last Move Instance Victim was hit by
  lhz r3,PreviousMoveInstanceHitBy(r6)

#If the move instance is 0, was most likely a stage element (corneria lasers)
  cmpwi r4,0
  beq ResetSDICount

#Check If New Hit
  cmpw	r3,r4
  beq	exit

#Reset SDI Counter
ResetSDICount:
  li	r0, 0x0
  stw	r0, SDIInputs (r6)

exit:
cmpwi	r30, 0
