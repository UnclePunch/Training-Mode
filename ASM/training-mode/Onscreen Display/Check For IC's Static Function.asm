#To be inserted at 80005510
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

backup

mr	r31,r3

#Get Byte
lbz	r3, 0x221F (playerdata)

#Check If Subchar
rlwinm.	r0, r3, 29, 31, 31
beq	NoFollower

#Check If Follower
lbz	r3,0xC(playerdata)			#get slot
branchl	r12,0x80032330			#get external character ID
load	r4,0x803bcde0			#pdLoadCommonData table
mulli	r0, r3, 3			#struct length
add	r3,r4,r0			#get characters entry
lbz	r0, 0x2 (r3)			#get subchar functionality
cmpwi	r0,0x0			#if not a follower, exit
bne	NoFollower

Follower:
li	r3,0x1
b	0x8

NoFollower:
li	r3,0x0

Moonwalk_Exit:
restore
blr
