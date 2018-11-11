#To be inserted at 80009fa4
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


#r0 is free
#r5 is free

#18 = 0

#5 = 187

#minimum GB value - (damage * (minimum GB value /max damage)

#Get Values
lfs	f5,0xC(r3)		#Get Hitbox Damage
bl	Floats
mflr	r5
lfs	f6,0x0(r5)		#Min GB Value
lfs	f7,0x4(r5)		#Damage Value for Lightest Color
lfs	f8,0x8(r5)		#Damage Value for Darkest Color


#Check If Does Over Max Damage Accounted For
fcmpo	cr0,f5,f8
blt	CheckMin
li	r6,0x0
b	StoreGandB

CheckMin:
#Check If Does Under Min Damage Accounted For
fcmpo	cr0,f5,f7
bgt	Formula
lfs	f8,0x0(r5)		#Value for Lightest Color
b	ConvertToDecimal

#Formula
Formula:
fsubs   f8,f8,f7
fsubs	f5,f5,f7
fsubs   f7,f7,f7
fdivs	f8,f6,f8		#(minimum GB value /max damage)
fmuls	f8,f5,f8		#(damage * (minimum GB value /damage range)
fsubs	f8,f6,f8		#minimum GB value - (damage * (minimum GB value /damage range)

#Convert To Decimal
ConvertToDecimal:
fctiwz	f5,f8
stfd	f5,-0xC(sp)
lwz	r6,-0x8(sp)		#Get Hitbox Damage as Int

#Store As G and B Value
StoreGandB:
subi	r5, r13, 32768		#Get Hitbox Color in DOL
stb	r6,0x1(r5)		#G
stb	r6,0x2(r5)		#B


b	exit

Floats:
blrl
.long 0x43580000	#Min GB Value 187
.long 0x40A00000	#Damage Value for Lightest Color 5
.long 0x41900000 #Damage Value for Darkest Color 18


exit:
