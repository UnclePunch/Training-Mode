#To be inserted at 800693ec
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
stwu	r1,-0x100(r1)	# make space for 12 registers
stmw	r20,8(r1)	# push r20-r31 onto the stack
mflr r0
stw r0,0xFC(sp)
.endm

.macro restore
lwz r0,0xFC(sp)
mtlr r0
lmw	r20,8(r1)	# pop r20-r31 off the stack
addi	r1,r1,0x100	# release the space
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

.set PrevASSlots,6-1
.set PrevASStart,0x23F0


#r3 is free
#23EC
#23F0
#23F4
#23F8

###################
## Shift AS ID's ##
###################

#SHIFT AS ID's
li	r12,PrevASSlots			#Loop Count

ASLoop:
addi	r3,r26,PrevASStart			#Get Start of AS List
mulli	r4,r12,2			#Current AS ID * Length
add	r4,r3,r4			#Get AS Offset in Playerblock
lhz	r3,-0x2(r4)			#Load Previous AS
sth	r3,0x0(r4)			#Push Back

ASIncLoop:
subi	r12,r12,1
cmpwi	r12,0x0
bgt	ASLoop

#Move Current AS To Last AS
lwz	r3,0x10(r26)		#get action state that we just left
sth	r3,PrevASStart(r26)		#store as last action state

#########################
## SHIFT FRAME NUMBERS ##
#########################

#SHIFT AS Frame #'s
li	r12,PrevASSlots			#Loop Count

FrameCountLoop:
addi	r3,r26,PrevASStart			#Get Start of AS List
li	r4,PrevASSlots
mulli	r4,r4,2			
addi	r4,r4,0x2			
add	r3,r3,r4			#Get to the Start of the Frame Counts
mulli	r4,r12,2			#Current AS ID * Length
add	r4,r3,r4			#Get AS Offset in Playerblock
lhz	r3,-0x2(r4)			#Load Previous AS
sth	r3,0x0(r4)			#Push Back

FrameCountIncLoop:
subi	r12,r12,1
cmpwi	r12,0x0
bgt	FrameCountLoop

#Move Current AS Frame To Last AS Frame
addi	r3,r26,PrevASStart			#Get Start of AS List
li	r4,PrevASSlots
mulli	r4,r4,2				
addi	r4,r4,0x2			
add	r3,r3,r4			#Get to the Start of the Frame Counts
lhz	r4,0x23EC(r26)			#Get AS Frame Number we Just Left
sth	r4,0x0(r3)

###########################################
## Init Current AS Frame To Int Variable ##
###########################################



#lfs	f1,0x894(r26)
#fctiwz	f1,f1
#stfd	f1,0x8(sp)
#lwz	r3,0xC(sp)
li	r3,0x0
sth	r3,0x23EC(r26)

exit:
cmplwi	r27, 0



