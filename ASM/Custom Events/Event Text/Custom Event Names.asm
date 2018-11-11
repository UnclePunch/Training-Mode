#To be inserted at 8024d4c8
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

#r24 = text struct
#r27 = Event ID

#Make Text Color Gray For All Events
load	r3,0xbbbbbbFF
stw	r3,0x8C(r24)

#Check for Custom Event
#cmpwi	r27,3
#bgt	CustomEvent
cmpwi	r27,14
bgt	Original

CustomEvent:
#Store Size
lfs	f0, -0x3878 (rtoc)
stfs	f0, 0x0024 (r24)
stfs	f0, 0x0028 (r24)

#Check for JP Enabled

#beq	JapaneseNames

#ENGLISH
bl	SkipJumpTable
bl	PlaceHolder
bl	PlaceHolder
bl	PlaceHolder
bl	Event4
bl	Event5
bl	Event6
bl	Event7
bl	Event8
bl	Event9
bl	Event10
bl	Event11
bl	Event12
bl	Event13
bl	Event14
bl	Event15
bl	Event16
bl	Event17
bl	Event18

#JAPANESE
JapaneseNames:
bl	SkipJumpTable
bl	JP_PlaceHolder
bl	JP_PlaceHolder
bl	JP_PlaceHolder
bl	JP_Event4
bl	JP_Event5
bl	JP_Event6
bl	JP_Event7
bl	JP_Event8
bl	JP_Event9
bl	JP_Event10
bl	JP_Event11
bl	JP_Event12
bl	JP_Event13
bl	JP_Event14
bl	JP_Event15
bl	JP_Event16
bl	JP_Event17
bl	JP_Event18

SkipJumpTable:
mflr	r4		#Jump Table Start in r4
subi	r5,r27,0x0		#Start at Event 0, so 0-Index
mulli	r5,r5,0x4		#Each Pointer is 0x4 Long
add	r4,r4,r5		#Get Event's Pointer Address
lwz	r5,0x0(r4)		#Get bl Instruction
rlwinm	r5,r5,0,6,29		#Mask Bits 6-29 (the offset)
add	r4,r4,r5		#Gets ASCII Address in r4

#Store Pointer to Text
stw	r4,0x5C(r24)

#Change New Event Text Colors
cmpwi	r27,3
blt	Original
load	r3,0xFFFFFFFF
stw	r3,0x8C(r24)

b	Original

PlaceHolder:
.long 0x16182019
.long 0x202f2024
.long 0x20262028
.long 0x202b2032
.long 0x202f2027
.long 0x20282035
.long 0x19000000
JP_PlaceHolder:


Event4:
#L-Cancel Training
.long 0x16182015
.long 0x20fc200c
.long 0x20242031
.long 0x20262028
.long 0x202f1a20
.long 0x1d203520
.long 0x24202c20
.long 0x31202c20
.long 0x31202a19
.long 0x00000000

Event5:
#Ledgedash Training
.long 0x16182015
.long 0x20282027
.long 0x202a2028
.long 0x20272024
.long 0x2036202b
.long 0x1a201d20
.long 0x35202420
.long 0x2c203120
.long 0x2c203120
.long 0x2a190000

Event6:
#Eggs-ercise
.long 0x1618200e
.long 0x202a202a
.long 0x203620fc
.long 0x20282035
.long 0x2026202c
.long 0x20362028
.long 0x19000000

Event7:
#SDI Training
.long 0x1618201c
.long 0x200d2012
.long 0x1a201d20
.long 0x35202420
.long 0x2c203120
.long 0x2c203120
.long 0x2a190000

Event8:
#Reversal Training
.long 0x1618201b
.long 0x20282039
.long 0x20282035
.long 0x20362024
.long 0x202f1a20
.long 0x1d203520
.long 0x24202c20
.long 0x31202c20
.long 0x31202a19
.long 0x00000000

Event9:
#Powershield Training
.long 0x16182019
.long 0x2032203a
.long 0x20282035
.long 0x2036202b
.long 0x202c2028
.long 0x202f2027
.long 0x1a201d20
.long 0x35202420
.long 0x2c203120
.long 0x2c203120
.long 0x2a190000

Event10:
#Shield Drop Training
.long 0x1618201c
.long 0x202b202c
.long 0x2028202f
.long 0x20271a20
.long 0x0d203520
.long 0x3220331a
.long 0x201d2035
.long 0x2024202c
.long 0x2031202c
.long 0x2031202a
.long 0x19000000

Event11:
#Attack On Shield
.long 0x1618200a
.long 0x20372037
.long 0x20242026
.long 0x202e1a20
.long 0x1820311a
.long 0x201c202b
.long 0x202c2028
.long 0x202f2027
.long 0x19000000

Event12:
#Ledge-Tech Training
.long 0x16182015
.long 0x20282027
.long 0x202a2028
.long 0x20fc201d
.long 0x20282026
.long 0x202b1a20
.long 0x1d203520
.long 0x24202c20
.long 0x31202c20
.long 0x31202a19
.long 0x00000000

Event13:
#Amsah-Tech Training
.long 0x1618200a
.long 0x20302036
.long 0x2024202b
.long 0x20fc201d
.long 0x20282026
.long 0x202b1a20
.long 0x1d203520
.long 0x24202c20
.long 0x31202c20
.long 0x31202a19
.long 0x00000000

Event14:
#Combo Training
.long 0x1618200c
.long 0x20322030
.long 0x20252032
.long 0x1a201d20
.long 0x35202420
.long 0x2c203120
.long 0x2c203120
.long 0x2a190000

Event15:
#Waveshine SDI
.long 0x16182020
.long 0x20242039
.long 0x20282036
.long 0x202b202c
.long 0x20312028
.long 0x1a201c20
.long 0x0d201219
.long 0x00000000



Original:
lmw	r23, 0x009C (sp)
