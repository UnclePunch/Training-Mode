#To be inserted at 80394a6c
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

.set VersionString,0x8040a58c

#############################
## OS Report Tweet Message ##
#############################

load	r20,0x803456a8			#OSReport

#OSReport Blank Line
bl	NewLine
mflr	r3
mtctr	r20
bctrl

#OSReport # Line
bl	PoundLine
mflr	r3
mtctr	r20
bctrl

#OSReport Error Message
bl	StackDumpMessage1
mflr	r3
mtctr	r20
bctrl

#OSReport # Line
bl	PoundLine
mflr	r3
mtctr	r20
bctrl

#OSReport Blank Line
bl	NewLine
mflr	r3
mtctr	r20
bctrl

#OSReport Mod Version
bl	Version
mflr	r3
load	r4,VersionString		#Mod Version
mtctr	r20
bctrl

#OSReport Compile Date
lis	r3, 0x803F
crclr	6
subi	r4, r3, 22840
subi	r3, r13, 27536
mtctr	r20
bctrl

#OSReport Blank Line
bl	NewLine
mflr	r3
mtctr	r20
bctrl

b	Exit

#########################################################

StackDumpMessage1:
blrl
.long 0x23232054
.long 0x57454554
.long 0x20412050
.long 0x49435455
.long 0x5245204f
.long 0x46205448
.long 0x4953204d
.long 0x45535341
.long 0x47452054
.long 0x4f204055
.long 0x6e636c65
.long 0x50756e63
.long 0x685f2023
.long 0x230a0000

PoundLine:
blrl
.long 0x23232323
.long 0x23232323
.long 0x23232323
.long 0x23232323
.long 0x23232323
.long 0x23232323
.long 0x23232323
.long 0x23232323
.long 0x23232323
.long 0x23232323
.long 0x23232323
.long 0x23232323
.long 0x23232323
.long 0x230A0000

NewLine:
blrl
.long 0x0A000000

Version:
blrl
.long 0x56455253
.long 0x494f4e3a
.long 0x2049534f
.long 0x2025730a
.long 0x00000000


#########################################################

Exit:
addi	r3, r30, 2252
