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

.macro getPlayerBlock reg1,reg2
lwz \reg1,0x2c(\reg2)
.endm

.macro getCharID reg
lbz \reg,0x7(player)
.endm

.macro getCostumeID reg
lbz \reg,0x619(player)
.endm

.macro getAS reg
lwz \reg,0x10(player)
.endm

.macro getASFrame reg
lwz \reg,0x894(player)
.endm

.macro getFacing reg
lwz \reg,0x2c(player)
.endm

.macro setFacing reg
stw \reg,0x2c(player)
.endm

.macro invertFacing reg
lfs \reg,0x2c(player)
fneg \reg,\reg
stfs \reg,0x2c(player)
.endm

.macro fsetGroundVelocityX reg
stfs \reg,0xec(player)
.endm

.macro fsetAirVelocityX reg
stfs \reg,0x80(player)
.endm

.macro fsetAirVelocityY reg
stfs \reg,0x84(player)
.endm

.macro fgetGroundVelocityX reg
lfs \reg,0xec(player)
.endm

.macro fgetAirVelocityX reg
lfs \reg,0x80(player)
.endm

.macro fgetAirVelocityY reg
lfs \reg,0x84(player)
.endm

.macro setGroundVelocityX reg
stw \reg,0xec(player)
.endm

.macro setAirVelocityX reg
stw \reg,0x80(player)
.endm

.macro setAirVelocityY reg
stw \reg,0x84(player)
.endm

.macro getGroundVelocityX reg
lwz \reg,0xec(player)
.endm

.macro getAirVelocityX reg
lwz \reg,0x80(player)
.endm

.macro getAirVelocityY reg
lwz \reg,0x84(player)
.endm

.macro getGroundAirState reg
lwz \reg,0xe0(player)
.endm

.macro getPlayerDatAddress reg
lwz \reg,0x108(player)
.endm

.macro getStaticBlock reg, reg2
lbz \reg,0xc(player)			#get player slot (0-3)
li \reg2,0xe90			#static player block length
mullw \reg2,\reg,\reg2			#multiply block length by player number
lis \reg,0x8045			#load in static player block base address
ori \reg,\reg,0x3080			#load in static player block base address
add \reg,\reg,\reg2			#add length to base address to get current player's block
#playerblock address in \reg
.endm

.macro getDpad reg
lbz \reg,0x66b(player)
.endm

.macro getPlayerSlot reg
lbz \reg,0xC(player)
.endm

.macro get reg offset
lwz \reg,\offset(player)
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

