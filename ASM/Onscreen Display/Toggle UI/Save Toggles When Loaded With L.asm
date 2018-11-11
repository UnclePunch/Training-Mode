#To be inserted at 80235994
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

#CHECK FLAG IN RULES STRUCT
load	r5,0x804a04f0
lbz	r0, 0x0011 (r5)
cmpwi	r0,0x2
blt original

#CUSTOM CODE
rlwinm	r0, r3, 0, 24, 31			#put menu selection in r0
#lwz	r5,-0xdbc(rtoc)			#get frame data toggle bits
lwz	r6,-0x77C0(r13)
lwz	r5,0x1F24(r6)
rlwinm.	r4, r4, 0, 24, 31			#check if turning on or off

beq	turnOff

turnOn:
li	r4, 1
slw	r0, r4, r0
or	r0, r5, r0
stw	r0,0x1F24(r6)
#stw	r0,-0xdbc(rtoc)			#store frame data toggle bits
b exit

turnOff:
li	r4, 1
slw	r0, r4, r0
andc	r0, r5, r0
stw	r0,0x1F24(r6)
#stw	r0,-0xdbc(rtoc)			#store frame data toggle bits
b exit


original:
branchl	r5,0x801641e4
exit:
