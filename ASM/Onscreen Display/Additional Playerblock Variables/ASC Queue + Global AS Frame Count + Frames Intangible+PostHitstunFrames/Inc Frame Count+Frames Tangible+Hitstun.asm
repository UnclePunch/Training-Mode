#To be inserted at 8006ab78
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
.set TextProp,29

.set PostHistunFrames,0x240E

#Don't Run During Hitlag
lbz	r0, 0x2219 (r31)
rlwinm.	r0, r0, 30, 31, 31
bne	exit

########################
## Increment AS Frame ##
########################

lhz	r3,0x23EC(r31)
addi	r3,r3,0x1
sth	r3,0x23EC(r31)

##################################
## Increment Tangibility Frames ##
##################################

#Check Timer Intangible Count
lwz	r3,0x1990(r31)
cmpwi	r3,0x0
bgt	IsIntangible

#Ensure Player Had Ledge Intang FIRST
lwz	r3,0x2408(r31)
cmpwi	r3,0x0
bne	IncTangibleFrames
#Check For Subaction Intang
lwz	r3,0x1988(r31)
cmpwi	r3,0x2
bne	IncTangibleFrames

#Set Tangible Frames to 0 When Player Has Intangibility
IsIntangible:
li	r3,0x0
stw	r3,0x2408(r31)			#Store Tangible Frame Count
b	Tangible_End

IncTangibleFrames:
lwz	r3,0x2408(r31)
addi	r3,r3,0x1
stw	r3,0x2408(r31)

Tangible_End:

exit:
mr	r3, r30
