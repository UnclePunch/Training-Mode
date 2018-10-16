#To be inserted at 8024d838
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
.set playerdata,31

backup
mr	r21,r3

#Get Event ID
lbz	r8,0x0(r31)
lwz	r9,0x4(r31)
add	r20,r8,r9

#Check for Custom Event
cmpwi	r20,3
blt	Original
cmpwi	r20,14
bgt	Original

#Store Size
lfs	f0, -0x3844 (rtoc)
stfs	f0, 0x0024 (r3)
stfs	f0, 0x0028 (r3)

#Store Original Text First
branchl	r12,0x803a6368

#Store Text
bl	SkipJumpTable
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



SkipJumpTable:
mflr	r4		#Jump Table Start in r4
subi	r5,r20,0x3		#Start at Event 3, so 0-Index
mulli	r5,r5,0x4		#Each Pointer is 0x4 Long
add	r4,r4,r5		#Get Event's Pointer Address
lwz	r5,0x0(r4)		#Get bl Instruction
rlwinm	r5,r5,0,6,29		#Mask Bits 6-29 (the offset)
add	r4,r4,r5		#Gets ASCII Address in r4

stw	r4,0x5C(r21)

Exit:
restore
branch	r12,0x8024d84c

Event4:
.long 0x160CAAAA
.long 0xAA0E00B3 
.long 0x00B31820
.long 0x19203520
.long 0x24202620
.long 0x37202c20
.long 0x2620281a
.long 0x201520fc
.long 0x200c2024
.long 0x20312026
.long 0x2028202f
.long 0x202f202c
.long 0x2031202a
.long 0x1a203220
.long 0x31032024
.long 0x1a203620
.long 0x37202420
.long 0x37202c20
.long 0x32203120
.long 0x24203520
.long 0x3c1a200c
.long 0x2019201e
.long 0x20e71900

Event5:
.long 0x160CAAAA
.long 0xAA0E00B3 
.long 0x00B31820
.long 0x19203520
.long 0x24202620
.long 0x37202c20
.long 0x2620281a
.long 0x20152028
.long 0x2027202a
.long 0x20282027
.long 0x20242036
.long 0x202b2028
.long 0x203620ec
.long 0x03201e20
.long 0x3620281a
.long 0x200d20fc
.long 0x20192024
.long 0x20271a20
.long 0x3720321a
.long 0x2026202b
.long 0x20242031
.long 0x202a2028
.long 0x1a202f20
.long 0x28202720
.long 0x2a202820
.long 0xe7190000

Event6:
.long 0x160CAAAA
.long 0xAA0E00B3 
.long 0x00B31820
.long 0x0b203520
.long 0x28202420
.long 0x2e1a2037
.long 0x202b2028
.long 0x1a202820
.long 0x2a202a20
.long 0x3620ec1a
.long 0x20182031
.long 0x202f203c
.long 0x1a203620
.long 0x37203520
.long 0x32203120
.long 0x2a1a202b
.long 0x202c2037
.long 0x20361a20
.long 0x3a202c20
.long 0x2f202f1a
.long 0x03202520
.long 0x35202820
.long 0x24202e1a
.long 0x2037202b
.long 0x20282030
.long 0x20e71a20
.long 0x0d201920
.long 0x2420271a
.long 0x20272032
.long 0x203a2031
.long 0x1a20fe1a
.long 0x20292035
.long 0x20282028
.long 0x1a203320
.long 0x35202420
.long 0x26203720
.long 0x2c202620
.long 0x2820e719
.long 0x

Event7:
.long 0x160CAAAA
.long 0xAA0E00B3 
.long 0x00B31820
.long 0x19203520
.long 0x24202620
.long 0x37202c20
.long 0x2620281a
.long 0x201c2030
.long 0x20242036
.long 0x202b1a20
.long 0x0d201220
.long 0xf3202c20
.long 0x31202a03
.long 0x200f2032
.long 0x203b20f3
.long 0x20361a20
.long 0x38203320
.long 0xfc202420
.long 0x2c203520
.long 0xec031900

Event8:
.long 0x160CAAAA
.long 0xAA0E00B3 
.long 0x00B31820
.long 0x19203520
.long 0x24202620
.long 0x37202c20
.long 0x2620281a
.long 0x20182032
.long 0x201c1a20
.long 0x33203820
.long 0x31202c20
.long 0x36202b20
.long 0x28203620
.long 0xec1a201b
.long 0x20fb200d
.long 0x20192024
.long 0x20271a20
.long 0x26202b20
.long 0x24203120
.long 0x2a202820
.long 0x361a2029
.long 0x20242026
.long 0x202c2031
.long 0x202a0320
.long 0x27202c20
.long 0x35202820
.long 0x26203720
.long 0x2c203220
.long 0x3120e61a
.long 0x200d2019
.long 0x20242027
.long 0x1a202f20
.long 0x28202920
.long 0x3720f020
.long 0x35202c20
.long 0x2a202b20
.long 0x371a2030
.long 0x20322039
.long 0x20282036
.long 0x1a202620
.long 0x2b202420
.long 0x35202420
.long 0x26203720
.long 0x28203520
.long 0x361a2024
.long 0x20332024
.long 0x20352037
.long 0x20e70319
.long 0x00000000

Event9:
.long 0x160CAAAA
.long 0xAA0E00B3 
.long 0x00B31820
.long 0x19201c1a
.long 0x20352028
.long 0x2029202f
.long 0x20282026
.long 0x20371a20
.long 0x0f202420
.long 0x2f202620
.long 0x3220f320
.long 0x361a202f
.long 0x20242036
.long 0x20282035
.long 0x20ec0320
.long 0x1b20fb20
.long 0x0d201920
.long 0x2420271a
.long 0x2026202b
.long 0x20242031
.long 0x202a2028
.long 0x20361a20
.long 0x29202c20
.long 0x35202820
.long 0xfc203520
.long 0x24203720
.long 0x2820e700

Event10:
.long 0x160CAAAA
.long 0xAA0E00B3 
.long 0x00B31820
.long 0x0c203220
.long 0x38203120
.long 0x37202820
.long 0x351a203a
.long 0x202c2037
.long 0x202b1a20
.long 0x241a2036
.long 0x202b202c
.long 0x2028202f
.long 0x202720fc
.long 0x20272035
.long 0x20322033
.long 0x1a202420
.long 0x28203520
.long 0x2c202420
.long 0x2f20ec1a
.long 0x201b20fb
.long 0x200d2019
.long 0x20242027
.long 0x1a202620
.long 0x2b202420
.long 0x31202a20
.long 0x2820361a
.long 0x20292024
.long 0x2026202c
.long 0x2031202a
.long 0x03202720
.long 0x2c203520
.long 0x28202620
.long 0x37202c20
.long 0x32203120
.long 0xe61a200d
.long 0x20192024
.long 0x20271a20
.long 0x2f202820
.long 0x29203720
.long 0xf0203520
.long 0x2c202a20
.long 0x2b20371a
.long 0x20302032
.long 0x20392028
.long 0x20361a20
.long 0x26202b20
.long 0x24203520
.long 0x24202620
.long 0x37202820
.long 0x3520361a
.long 0x20242033
.long 0x20242035
.long 0x203720e7
.long 0x03190000


Event11:
.long 0x160CAAAA
.long 0xAA0E00B3 
.long 0x00B31820
.long 0x19203520
.long 0x24202620
.long 0x37202c20
.long 0x2620281a
.long 0x20362033
.long 0x20242026
.long 0x202c2031
.long 0x202a1a20
.long 0x24203720
.long 0x37202420
.long 0x26202e20
.long 0x361a2032
.long 0x20311a20
.long 0x241a2036
.long 0x202b202c
.long 0x2028202f
.long 0x2027202c
.long 0x2031202a
.long 0x1a032032
.long 0x20332033
.long 0x20322031
.long 0x20282031
.long 0x203720e7
.long 0x1a201b20
.long 0xfb200d20
.long 0x19202420
.long 0x271a2026
.long 0x202b2024
.long 0x2031202a
.long 0x20282036
.long 0x1a203720
.long 0x2b202820
.long 0x2c20351a
.long 0x20182032
.long 0x201c1a20
.long 0x32203320
.long 0x37202c20
.long 0x32203120
.long 0xe7190000


Event12:
.long 0x160CAAAA
.long 0xAA0E00B3 
.long 0x00B31820
.long 0x19203520
.long 0x24202620
.long 0x37202c20
.long 0x2620281a
.long 0x202f2028
.long 0x2027202a
.long 0x202820fc
.long 0x20372028
.long 0x2026202b
.long 0x202c2031
.long 0x202a0320
.long 0x0f202420
.long 0x2f202620
.long 0x3220f320
.long 0x361a2027
.long 0x2032203a
.long 0x203120fc
.long 0x20362030
.long 0x20242036
.long 0x202b20ec
.long 0x19000000

Event13:
.long 0x160CAAAA
.long 0xAA0E00B3 
.long 0x00B31820
.long 0x1d202420
.long 0x38203120
.long 0x371a2037
.long 0x20321a20
.long 0x2b202420
.long 0x3920281a
.long 0x20162024
.long 0x20352037
.long 0x202b1a20
.long 0x1e203320
.long 0xfc200b20
.long 0xe6032037
.long 0x202b2028
.long 0x20311a20
.long 0x0a201c20
.long 0x0d201220
.long 0xfc202720
.long 0x32203a20
.long 0x311a2024
.long 0x20312027
.long 0x1a203720
.long 0x28202620
.long 0x2b20ec19
.long 0x00000000


Event14:
.long 0x160CAAAA
.long 0xAA0E00B3 
.long 0x00B31820
.long 0x1520fb20
.long 0x0d201920
.long 0x2420271a
.long 0x2026202b
.long 0x20242031
.long 0x202a2028
.long 0x20361a20
.long 0x33202820
.long 0x35202620
.long 0x28203120
.long 0x3720f020
.long 0x1b20fb20
.long 0x0d201920
.long 0x2420271a
.long 0x2026202b
.long 0x20242031
.long 0x202a2028
.long 0x20361a20
.long 0x0d201220
.long 0xfb201c20
.long 0x0d201203
.long 0x200d2019
.long 0x20242027
.long 0x200d2032
.long 0x203a2031
.long 0x1a203020
.long 0x32203920
.long 0x2820361a
.long 0x200c2019
.long 0x201e20f0
.long 0x200d2019
.long 0x20242027
.long 0x201b202c
.long 0x202a202b
.long 0x20371a20
.long 0x36202420
.long 0x39202820
.long 0x361a2033
.long 0x20322036
.long 0x202c2037
.long 0x202c2032
.long 0x20312036
.long 0x19000000

Event15:
.long 0x160CAAAA
.long 0xAA0E00B3 
.long 0x00B31820
.long 0x1e203620
.long 0x281a201c
.long 0x20302024
.long 0x2036202b
.long 0x1a200d20
.long 0x121a2037
.long 0x20321a20
.long 0x2a202820
.long 0x371a2032
.long 0x20382037
.long 0x03203220
.long 0x291a200f
.long 0x2032203b
.long 0x20f32036
.long 0x1a203a20
.long 0x24203920
.long 0x28203620
.long 0x2b202c20
.long 0x31202820
.long 0xec190000


Original:
restore
mr	r4, r30


