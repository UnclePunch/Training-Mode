#To be inserted at 8015ecec
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

.set entity,31
.set player,31

li r3,0x3
branchl r12,HSD_Randi

cmpwi r3,0x0
beq MainMenu1
cmpwi r3,0x1
beq MainMenu2
cmpwi r3,0x2
beq Trophy

MainMenu1:
li r0,0x34
b done

MainMenu2:
li r0,0x36
b done

Trophy:
li r0,0x35
b done

done:
stb	r0, 0x0001 (r31)
branch r12, 0x8015ed1c
