#To be inserted at 80266ce0
.macro bl reg, address
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
addi sp,sp,-0x4
mflr r0
stw r0,0(sp)
.endm

.macro restore
lwz r0,0(sp)
mtlr r0
addi sp,sp,0x4
.endm

.set ActionStateChange,0x800693ac
.set HSD_Randi,0x80380580
.set HSD_Randf,0x80380528
.set Wait,0x8008a348
.set Fall,0x800cc730

.set player,31

#######################################
## Runs During CSS -> SSS Transition ##
#######################################

#Get Teams On/Off Bool
lwz	r3, -0x49F0 (r13)
lbz	r3,0x18(r3)

#Check If Teams is On or Off
cmpwi	r3,0x1
beq	Doubles


Singles:
#Get Random Stage Select Bitflags
lwz	r5, -0x77C0 (r13)
addi	r5, r5, 7344
lwz	r0,0x18(r5)
#Flip FoD Bit On in Random Stage Bitflag (FoD is bit #26)
li	r3,0x1
rlwimi	r0,r3,5,26,26
stw	r0,0x18(r5)

#Get Timer Value In Memory
lwz	r3, -0x77C0 (r13)
addi	r3, r3, 6224
#Store 8
li	r4,8		#8 Mins
stb	r4,0x8(r3)		#Store To Memory

b	Exit

Doubles:
#Get Random Stage Select Bitflags
lwz	r5, -0x77C0 (r13)
addi	r5, r5, 7344
lwz	r0,0x18(r5)
#Flip FoD Bit Off in Random Stage Bitflag (FoD is bit #26)
li	r3,0x0
rlwimi	r0,r3,5,26,26
stw	r0,0x18(r5)

#Get Timer Value In Memory
lwz	r3, -0x77C0 (r13)
addi	r3, r3, 6224
#Store 10
li	r4,10		#10 mins
stb	r4,0x8(r3)

b	Exit



Exit:
li	r3, 1
