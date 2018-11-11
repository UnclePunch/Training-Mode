#To be inserted at 802360f8
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
.set Text,30
.set TextProp,28

.set MaxWindows,4-1

#Injected into CursorMovement Check

backup

#CHECK FLAG IN RULES STRUCT
load	r4,0x804a04f0
lbz	r0, 0x0011 (r4)
cmpwi	r0,0x2
blt exit

lwz	r20,-0x77C0(r13)			#Get Memcard Data

#############################################
CheckY:
rlwinm.	r0, r28, 0, 20, 20 		#Check For Y
beq	CheckX

#Increase Number
lbz	r3,0x1f28(r20)
addi	r3,r3,0x1
#Check If Over Max
cmpwi	r3,MaxWindows
ble	CheckY_Store
#Loop Back to 0
li	r3,0x0
CheckY_Store:
stb	r3,0x1f28(r20)

b	UpdateText
#############################################

#############################################
CheckX:
rlwinm.	r0, r28, 0, 21, 21 		#Check For X
beq	exit

#Decrease Number
lbz	r3,0x1f28(r20)
subi	r3,r3,0x1
#Check If Over Max
cmpwi	r3,0
bge	CheckX_Store
#Loop Back to MaxWindows
li	r3,MaxWindows
CheckX_Store:
stb	r3,0x1f28(r20)

b	UpdateText
#############################################

#############################################
UpdateText:
lwz	r3,0x40(r29)			#Get Text Structure
lbz	r4,0x48(r29)			#Get Subtext ID
bl	UpdateText_Text
mflr	r5
lbz	r6,0x1f28(r20)
addi	r6,r6,0x1
branchl	r12,0x803a70a0

b	exit
#############################################

#############################################

UpdateText_Text:
blrl

.long 0x4d617820
.long 0x4f534427
.long 0x733a2025
.long 0x64000000

exit:
restore
rlwinm.	r0, r28, 0, 23, 23
