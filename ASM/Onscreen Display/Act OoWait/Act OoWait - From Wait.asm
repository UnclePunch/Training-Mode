#To be inserted at 8008A630
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
.set playerdata,30
.set player,31
.set text,29
.set textprop,28
.set hitbool,27

.set PrevASStart,0x23F0
.set CurrentAS,0x10
.set OneASAgo,PrevASStart+0x0
.set TwoASAgo,PrevASStart+0x2
.set ThreeASAgo,PrevASStart+0x4
.set FourASAgo,PrevASStart+0x6
.set FiveASAgo,PrevASStart+0x8
.set SixASAgo,PrevASStart+0xA

##########################################################
## 804a1f5c -> 804a1fd4 = Static Stock Icon Text Struct ##
## Is 0x80 long and is zero'd at the start              ##
##  of every VS Match				                        ##
## Store Text Info here                                 ##
##########################################################

backup

#Check If Interrupted
	cmpwi	r3,0x0
	beq	Moonwalk_Exit

#Get Playerdata
	lwz	playerdata,0x2C(player)

#Ensure I'm Actually Coming from Wait (Wait interrupt is used for certain IASA)
	lhz	r3,OneASAgo(playerdata)
	cmpwi	r3,0xE
	bne	Moonwalk_Exit

#Make Sure Player Didn't Buffer Crouch, Shield, or Walk
	lwz	r3,0x10(playerdata)
	cmpwi	r3,0xF
	beq	Moonwalk_Exit
	cmpwi	r3,0x10
	beq	Moonwalk_Exit
	cmpwi	r3,0x11
	beq	Moonwalk_Exit
	cmpwi	r3,0x27
	beq	Moonwalk_Exit
	cmpwi	r3,0xB2
	beq	Moonwalk_Exit

#Check To Display OSD
	mr	r3,r31
	branchl	r12,0x8000551c

Moonwalk_Exit:
restore
lwz	r0, 0x001C (sp)
